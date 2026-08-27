/**
 * Gondolin Tool Routing Extension
 *
 * Runs pi's built-in tools inside a local Gondolin micro-VM. The host working
 * directory is mounted at /workspace in the guest. File changes under
 * /workspace write through to the host; other guest filesystem changes are
 * isolated to the VM.
 *
 * Images support workspace-level "inheritance" that `gondolin build` lacks:
 * an optional `gondolin-sandbox.json` in the git root is deep-merged over the
 * shared BASE_IMAGE_CONFIG below before building, so post-build fixes (guest
 * runtime files, env, rootfs sizing, packages) are maintained once here and
 * apply to every git workspace. Workspace specs only carry their deltas;
 * workspaces without a spec get the base image unchanged.
 *
 * The guest runtime files live in ./guest/ so they are packaged (and
 * content-hashed into the image fingerprint) alongside this extension.
 *
 * Requirements:
 *   - Node.js >= 23.6.0 for @earendil-works/gondolin
 *   - cpio, lz4, e2fsprogs (mke2fs) on the host for image builds
 */

import { execFile } from "node:child_process";
import { createHash } from "node:crypto";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { promisify } from "node:util";
import { fileURLToPath } from "node:url";
import {
  buildAssets,
  listImageRefs,
  parseBuildConfig,
  type BuildConfig,
  RealFSProvider,
  ReadonlyProvider,
  VM,
} from "@earendil-works/gondolin";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import {
  type BashOperations,
  createBashTool,
  createEditTool,
  createFindTool,
  createGrepTool,
  createLsTool,
  createReadTool,
  createWriteTool,
  DEFAULT_MAX_BYTES,
  type EditOperations,
  type FindOperations,
  formatSize,
  type GrepToolDetails,
  type GrepToolInput,
  type LsOperations,
  type ReadOperations,
  truncateHead,
  truncateLine,
  type WriteOperations,
} from "@earendil-works/pi-coding-agent";

const GUEST_WORKSPACE = "/workspace";
const HOST_NIX_STORE = "/nix/store";
const GUEST_NIX_STORE = "/nix/.ro-store";
const DEFAULT_GREP_LIMIT = 100;
const FALLBACK_IMAGE_REF = "alpine-nix:latest";
const SANDBOX_DIR_NAME = ".gondolin";
const SANDBOX_SPEC_FILENAME = "gondolin-sandbox.json";
const SPEC_STAMP_FILENAME = "spec.sha256";

/** Absolute host path to a runtime file shipped alongside this extension. */
function guestAssetPath(filename: string): string {
  return fileURLToPath(new URL(`./guest/${filename}`, import.meta.url));
}

/**
 * Shared base image configuration deep-merged under every workspace's
 * optional `gondolin-sandbox.json`.
 *
 * Copy sources point at files packaged beside this extension (absolute paths
 * pass through gondolin's `resolveConfigPath` untouched). Note that a present
 * `alpine.rootfsPackages` overrides gondolin's defaults, so the full list is
 * spelled out here.
 */
const BASE_IMAGE_CONFIG = {
  arch: "x86_64",
  distro: "alpine",
  alpine: {
    version: "3.23.0",
    kernelPackage: "linux-virt",
    kernelImage: "vmlinuz-virt",
    krunfwVersion: "v5.2.1",
    rootfsPackages: [
      "linux-virt",
      "rng-tools",
      "bash",
      "ca-certificates",
      "curl",
      "e2fsprogs",
      "git",
      "nodejs",
      "npm",
      "uv",
      "python3",
      "py3-html2text",
      "openssh",
      "nix",
    ],
  },
  env: {
    HOME: "/root",
    NIX_REMOTE: "", // single-user root; upstream daemon export breaks here
  },
  rootfs: {
    label: "gondolin-root",
    // headroom for a writable nix store upper layer on the ephemeral rootfs
    sizeMb: 8192,
  },
  postBuild: {
    copy: [
      {
        src: guestAssetPath("nix-overlay-profile.sh"),
        dest: "/etc/profile.d/01-gondolin-runtime.sh",
      },
      {
        src: guestAssetPath("etc-nix.conf"),
        dest: "/etc/nix/nix.conf",
      },
      {
        src: guestAssetPath("nix-remote-stub.sh"),
        dest: "/etc/profile.d/nix-remote.sh",
      },
      {
        src: guestAssetPath("etc-gitconfig"),
        dest: "/etc/gitconfig",
      },
    ],
  },
} satisfies BuildConfig;

const execFileAsync = promisify(execFile);

type TextToolResult<TDetails> = {
  content: Array<{ type: "text"; text: string }>;
  details: TDetails | undefined;
};

function stripAtPrefix(value: string): string {
  return value.startsWith("@") ? value.slice(1) : value;
}

function toPosix(value: string): string {
  return value.split(path.sep).join(path.posix.sep);
}

function isInsideHostPath(root: string, value: string): boolean {
  const relativePath = path.relative(root, value);
  return relativePath === "" || (!relativePath.startsWith("..") && !path.isAbsolute(relativePath));
}

function hostPathToGuest(localCwd: string, hostPath: string): string {
  const relativePath = path.relative(localCwd, hostPath);
  if (!isInsideHostPath(localCwd, hostPath)) return toPosix(hostPath);
  return relativePath ? path.posix.join(GUEST_WORKSPACE, toPosix(relativePath)) : GUEST_WORKSPACE;
}

function toGuestPath(localCwd: string, inputPath: string): string {
  const trimmed = stripAtPrefix(inputPath.trim());
  if (!trimmed) return GUEST_WORKSPACE;
  if (path.isAbsolute(trimmed)) {
    if (isInsideHostPath(localCwd, trimmed)) return hostPathToGuest(localCwd, trimmed);
    return path.posix.resolve("/", toPosix(trimmed));
  }
  return path.posix.resolve(GUEST_WORKSPACE, toPosix(trimmed));
}

function createGondolinReadOps(vm: VM, localCwd: string): ReadOperations {
  return {
    readFile: async (filePath) => vm.fs.readFile(toGuestPath(localCwd, filePath)),
    access: async (filePath) => {
      await vm.fs.access(toGuestPath(localCwd, filePath));
    },
    detectImageMimeType: async (filePath) => {
      const ext = path.posix.extname(toGuestPath(localCwd, filePath)).toLowerCase();
      if (ext === ".png") return "image/png";
      if (ext === ".jpg" || ext === ".jpeg") return "image/jpeg";
      if (ext === ".gif") return "image/gif";
      if (ext === ".webp") return "image/webp";
      return null;
    },
  };
}

function createGondolinWriteOps(vm: VM, localCwd: string): WriteOperations {
  return {
    writeFile: async (filePath, content) => {
      await vm.fs.writeFile(toGuestPath(localCwd, filePath), content, { encoding: "utf8" });
    },
    mkdir: async (dirPath) => {
      await vm.fs.mkdir(toGuestPath(localCwd, dirPath), { recursive: true });
    },
  };
}

function createGondolinEditOps(vm: VM, localCwd: string): EditOperations {
  const readOps = createGondolinReadOps(vm, localCwd);
  const writeOps = createGondolinWriteOps(vm, localCwd);
  return {
    readFile: readOps.readFile,
    writeFile: writeOps.writeFile,
    access: readOps.access,
  };
}

function createGondolinLsOps(vm: VM, localCwd: string): LsOperations {
  return {
    exists: async (filePath) => {
      try {
        await vm.fs.access(toGuestPath(localCwd, filePath));
        return true;
      } catch {
        return false;
      }
    },
    stat: async (filePath) => vm.fs.stat(toGuestPath(localCwd, filePath)),
    readdir: async (dirPath) => vm.fs.listDir(toGuestPath(localCwd, dirPath)),
  };
}

async function walkGuestFiles(
  vm: VM,
  root: string,
  visit: (guestPath: string, relativePath: string) => Promise<boolean>,
  signal?: AbortSignal,
): Promise<boolean> {
  if (signal?.aborted) throw new Error("Operation aborted");
  const stat = await vm.fs.stat(root, { signal });
  if (!stat.isDirectory()) return visit(root, path.posix.basename(root));

  const walkDirectory = async (dir: string, relativeDir: string): Promise<boolean> => {
    if (signal?.aborted) throw new Error("Operation aborted");
    const entries = await vm.fs.listDir(dir, { signal });
    for (const entry of entries) {
      if (entry === ".git" || entry === "node_modules") continue;
      const guestPath = path.posix.join(dir, entry);
      const relativePath = relativeDir ? path.posix.join(relativeDir, entry) : entry;
      let entryStat: Awaited<ReturnType<VM["fs"]["stat"]>>;
      try {
        entryStat = await vm.fs.stat(guestPath, { signal });
      } catch {
        continue;
      }
      if (entryStat.isDirectory()) {
        if (!(await walkDirectory(guestPath, relativePath))) return false;
      } else if (!(await visit(guestPath, relativePath))) {
        return false;
      }
    }
    return true;
  };

  return walkDirectory(root, "");
}

function matchesToolGlob(relativePath: string, pattern: string): boolean {
  const normalizedPattern = toPosix(pattern);
  if (normalizedPattern.includes("/")) {
    return (
      path.posix.matchesGlob(relativePath, normalizedPattern) ||
      path.posix.matchesGlob(relativePath, `**/${normalizedPattern}`)
    );
  }
  return path.posix.matchesGlob(path.posix.basename(relativePath), normalizedPattern);
}

function createGondolinFindOps(vm: VM, localCwd: string): FindOperations {
  return {
    exists: async (filePath) => {
      try {
        await vm.fs.access(toGuestPath(localCwd, filePath));
        return true;
      } catch {
        return false;
      }
    },
    glob: async (pattern, cwd, options) => {
      const root = toGuestPath(localCwd, cwd);
      const results: string[] = [];
      await walkGuestFiles(vm, root, async (guestPath, relativePath) => {
        if (results.length >= options.limit) return false;
        if (matchesToolGlob(relativePath, pattern)) results.push(guestPath);
        return results.length < options.limit;
      });
      return results;
    },
  };
}

function createLineMatcher(pattern: string, literal: boolean | undefined, ignoreCase: boolean | undefined) {
  if (literal) {
    const needle = ignoreCase ? pattern.toLowerCase() : pattern;
    return (line: string) => (ignoreCase ? line.toLowerCase() : line).includes(needle);
  }
  const regex = new RegExp(pattern, ignoreCase ? "i" : undefined);
  return (line: string) => regex.test(line);
}

function appendGrepBlock(params: {
  outputLines: string[];
  lines: string[];
  relativePath: string;
  lineIndex: number;
  contextLines: number;
}): boolean {
  let linesTruncated = false;
  const start = params.contextLines > 0 ? Math.max(0, params.lineIndex - params.contextLines) : params.lineIndex;
  const end =
    params.contextLines > 0
      ? Math.min(params.lines.length - 1, params.lineIndex + params.contextLines)
      : params.lineIndex;

  for (let index = start; index <= end; index++) {
    const rawLine = params.lines[index] ?? "";
    const { text, wasTruncated } = truncateLine(rawLine.replace(/\r/g, ""));
    if (wasTruncated) linesTruncated = true;
    const separator = index === params.lineIndex ? ":" : "-";
    params.outputLines.push(`${params.relativePath}${separator}${index + 1}${separator} ${text}`);
  }
  return linesTruncated;
}

async function executeGondolinGrep(
  vm: VM,
  localCwd: string,
  params: GrepToolInput,
  signal?: AbortSignal,
): Promise<TextToolResult<GrepToolDetails>> {
  const root = toGuestPath(localCwd, params.path ?? ".");
  const rootStat = await vm.fs.stat(root, { signal });
  const rootIsDirectory = rootStat.isDirectory();
  const matcher = createLineMatcher(params.pattern, params.literal, params.ignoreCase);
  const contextLines = params.context && params.context > 0 ? params.context : 0;
  const effectiveLimit = Math.max(1, params.limit ?? DEFAULT_GREP_LIMIT);
  const outputLines: string[] = [];
  const details: GrepToolDetails = {};
  let matchCount = 0;
  let matchLimitReached = false;
  let linesTruncated = false;

  await walkGuestFiles(
    vm,
    root,
    async (guestPath, relativePath) => {
      if (matchCount >= effectiveLimit) return false;
      if (params.glob && !matchesToolGlob(relativePath, params.glob)) return true;
      let content: string;
      try {
        content = await vm.fs.readFile(guestPath, { encoding: "utf8", signal });
      } catch {
        return true;
      }
      const lines = content.replace(/\r\n/g, "\n").replace(/\r/g, "\n").split("\n");
      const displayPath = rootIsDirectory ? relativePath : path.posix.basename(guestPath);
      for (let index = 0; index < lines.length; index++) {
        if (signal?.aborted) throw new Error("Operation aborted");
        if (!matcher(lines[index] ?? "")) continue;
        matchCount++;
        if (appendGrepBlock({ outputLines, lines, relativePath: displayPath, lineIndex: index, contextLines })) {
          linesTruncated = true;
        }
        if (matchCount >= effectiveLimit) {
          matchLimitReached = true;
          return false;
        }
      }
      return true;
    },
    signal,
  );

  if (matchCount === 0) return { content: [{ type: "text", text: "No matches found" }], details: undefined };

  const rawOutput = outputLines.join("\n");
  const truncation = truncateHead(rawOutput, { maxLines: Number.MAX_SAFE_INTEGER });
  const notices: string[] = [];
  let output = truncation.content;

  if (matchLimitReached) {
    details.matchLimitReached = effectiveLimit;
    notices.push(`${effectiveLimit} matches limit reached`);
  }
  if (linesTruncated) {
    details.linesTruncated = true;
    notices.push("long lines truncated");
  }
  if (truncation.truncated) {
    details.truncation = truncation;
    notices.push(`${formatSize(DEFAULT_MAX_BYTES)} limit reached`);
  }
  if (notices.length > 0) output += `\n\n[${notices.join(". ")}]`;

  return {
    content: [{ type: "text", text: output }],
    details: Object.keys(details).length > 0 ? details : undefined,
  };
}

/**
 * Resolve a post-build copy source the same way gondolin does: absolute paths
 * pass through, relative paths resolve against the config directory.
 */
function resolveCopySource(src: string, configDir: string): string {
  return path.isAbsolute(src) ? src : path.resolve(configDir, src);
}

/**
 * Copy source reduced for fingerprinting, so transient absolute locations
 * (e.g. nix store hashes after an unrelated extension rebuild) don't
 * invalidate otherwise-identical images.
 */
function fingerprintCopyEntry(entry: { src: string; dest: string }): {
  src: string;
  dest: string;
} {
  return {
    src: path.isAbsolute(entry.src) ? path.basename(entry.src) : entry.src,
    dest: entry.dest,
  };
}

function errorMessage(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}

function isPlainObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/** Deterministic JSON serialization (sorted object keys) for fingerprinting. */
export function stableStringify(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(stableStringify).join(",")}]`;
  if (isPlainObject(value)) {
    const entries = Object.keys(value)
      .sort()
      .map((key) => `${JSON.stringify(key)}:${stableStringify(value[key])}`);
    return `{${entries.join(",")}}`;
  }
  return JSON.stringify(value) ?? "null";
}

/**
 * Deep-merge two JSON-ish configs: objects merge recursively, arrays
 * concatenate with base entries first (primitives deduped; duplicate objects
 * keep both so e.g. a later copy entry clobbers an earlier one at copy time),
 * and scalars prefer the override.
 */
export function mergeConfigs(base: unknown, override: unknown): unknown {
  if (Array.isArray(base) || Array.isArray(override)) {
    const seen = new Set<string>();
    const merged: unknown[] = [];
    for (const entry of [
      ...(Array.isArray(base) ? base : []),
      ...(Array.isArray(override) ? override : []),
    ]) {
      const key = isPlainObject(entry) ? null : JSON.stringify(entry);
      if (typeof key === "string") {
        if (seen.has(key)) continue;
        seen.add(key);
      }
      merged.push(entry);
    }
    return merged;
  }
  if (isPlainObject(base) && isPlainObject(override)) {
    const merged: Record<string, unknown> = {};
    for (const [key, value] of Object.entries(base)) {
      merged[key] = mergeConfigs(value, undefined);
    }
    for (const [key, value] of Object.entries(override)) {
      merged[key] = key in merged ? mergeConfigs(merged[key], value) : value;
    }
    return merged;
  }
  return override !== undefined ? override : base;
}

/**
 * Merge the shared base image config with an optional workspace spec,
 * validate the result through gondolin's parser, and derive a fingerprint
 * covering both the merged config and the contents of every copied file, so
 * stale `.gondolin` dirs rebuild whenever the base or its payloads change.
 * (Exported for testing.)
 */
export async function resolveImageConfig(
  gitRoot: string,
  specContent: string | undefined,
): Promise<{ config: BuildConfig; fingerprint: string }> {
  let specConfig: unknown = {};
  if (specContent !== undefined) {
    try {
      specConfig = JSON.parse(specContent);
    } catch (error) {
      throw new Error(`Invalid ${SANDBOX_SPEC_FILENAME}: ${errorMessage(error)}`);
    }
  }
  const config = parseBuildConfig(stableStringify(mergeConfigs(BASE_IMAGE_CONFIG, specConfig)));
  const copies = config.postBuild?.copy ?? [];
  const parts = [
    stableStringify({
      ...config,
      postBuild: { ...(config.postBuild ?? {}), copy: copies.map(fingerprintCopyEntry) },
    }),
  ];
  for (const entry of copies) {
    const content = await fs.readFile(resolveCopySource(entry.src, gitRoot));
    parts.push(`${entry.dest}:${createHash("sha256").update(content).digest("hex")}`);
  }
  return {
    config,
    fingerprint: createHash("sha256").update(parts.join("\n")).digest("hex").slice(0, 16),
  };
}

async function findGitProjectRoot(cwd: string): Promise<string | undefined> {
  try {
    const { stdout } = await execFileAsync("git", ["rev-parse", "--show-toplevel"], {
      cwd,
    });
    return stdout.trim() || undefined;
  } catch {
    return undefined;
  }
}

/**
 * Build `<gitRoot>/.gondolin` from an already-merged, validated build config
 * using the gondolin build APIs. Returns the output directory on success.
 *
 * Assets are built into a unique temporary directory under the system temp
 * dir and copied into place only after a successful build, together with a
 * stamp of the config fingerprint, so failed builds leave any existing image
 * intact and partial output is never visible at `<gitRoot>/.gondolin`.
 *
 * Throws when the build fails.
 */
async function buildSandboxDirFromSpec(
  gitRoot: string,
  gondolinDir: string,
  config: BuildConfig,
  fingerprint: string,
  log: (message: string) => void,
): Promise<string> {
  const stagingDir = await fs.mkdtemp(path.join(os.tmpdir(), "gondolin-build-"));
  log(`building Gondolin image into ${SANDBOX_DIR_NAME}/ (${fingerprint})`);
  try {
    await buildAssets(config, { outputDir: stagingDir, configDir: gitRoot, verbose: false });
    await fs.writeFile(path.join(stagingDir, SPEC_STAMP_FILENAME), `${fingerprint}\n`, "utf8");
    await fs.rm(gondolinDir, { recursive: true, force: true });
    await fs.cp(stagingDir, gondolinDir, {
      errorOnExist: true,
      recursive: true,
    });
  } catch (error) {
    throw new Error(`Failed to build Gondolin image: ${errorMessage(error)}`);
  } finally {
    await fs.rm(stagingDir, { recursive: true, force: true }).catch(() => { });
  }
  log(`Gondolin image built at ${gondolinDir}`);
  return gondolinDir;
}

/**
 * Resolve optional sandbox image options for VM.create:
 *   1. `<git project root>/.gondolin` when its stamp matches the fingerprint
 *      of the shared base config merged with the workspace's optional
 *      `gondolin-sandbox.json`; built when missing or stale. Workspaces
 *      without a spec get the base image unchanged.
 *   2. the local `${FALLBACK_IMAGE_REF}` image ref if present in the image
 *      store (non-git directories)
 *   3. undefined, letting gondolin use its default image
 */
async function resolveSandboxOptions(
  cwd: string,
  log: (message: string) => void = () => { },
): Promise<{ imagePath: string } | undefined> {
  const gitRoot = await findGitProjectRoot(cwd);
  if (!gitRoot) {
    try {
      const refs = listImageRefs();
      if (refs.some((ref) => ref.reference === FALLBACK_IMAGE_REF)) return { imagePath: FALLBACK_IMAGE_REF };
    } catch {
      // image store unreadable; fall through to defaults
    }
    return undefined;
  }
  const gondolinDir = path.join(gitRoot, SANDBOX_DIR_NAME);
  let specContent: string | undefined;
  try {
    specContent = await fs.readFile(path.join(gitRoot, SANDBOX_SPEC_FILENAME), "utf8");
  } catch (error) {
    if ((error as NodeJS.ErrnoException | undefined)?.code !== "ENOENT") {
      throw new Error(
        `Found ${SANDBOX_SPEC_FILENAME} but could not read it: ${errorMessage(error)}`,
      );
    }
    // no workspace spec; the shared base applies as-is
  }
  log(
    specContent === undefined
      ? `no ${SANDBOX_SPEC_FILENAME}; applying shared base image config`
      : `merging ${SANDBOX_SPEC_FILENAME} with shared base image config`,
  );
  const { config, fingerprint } = await resolveImageConfig(gitRoot, specContent);
  const [stamp, dirStat] = await Promise.all([
    fs.readFile(path.join(gondolinDir, SPEC_STAMP_FILENAME), "utf8").catch(() => ""),
    fs.stat(gondolinDir).catch(() => null),
  ]);
  if (stamp.trim() === fingerprint && dirStat?.isDirectory()) return { imagePath: gondolinDir };
  return {
    imagePath: await buildSandboxDirFromSpec(gitRoot, gondolinDir, config, fingerprint, log),
  };
}

function sanitizeEnv(env: NodeJS.ProcessEnv | undefined): Record<string, string> | undefined {
  if (!env) return undefined;
  const result: Record<string, string> = {};
  for (const [key, value] of Object.entries(env)) {
    if (typeof value === "string") result[key] = value;
  }
  return result;
}

function createGondolinBashOps(vm: VM, localCwd: string, shellPath: string): BashOperations {
  return {
    exec: async (command, cwd, { onData, signal, timeout, env }) => {
      if (signal?.aborted) throw new Error("aborted");
      const guestCwd = toGuestPath(localCwd, cwd);
      const controller = new AbortController();
      const onAbort = () => controller.abort();
      signal?.addEventListener("abort", onAbort, { once: true });

      let timedOut = false;
      const timer =
        timeout && timeout > 0
          ? setTimeout(() => {
            timedOut = true;
            controller.abort();
          }, timeout * 1000)
          : undefined;

      try {
        const proc = vm.exec([shellPath, "-lc", command], {
          cwd: guestCwd,
          env: sanitizeEnv(env),
          signal: controller.signal,
          stdout: "pipe",
          stderr: "pipe",
        });
        for await (const chunk of proc.output()) onData(chunk.data);
        const result = await proc;
        return { exitCode: result.exitCode };
      } catch (error) {
        if (signal?.aborted) throw new Error("aborted");
        if (timedOut) throw new Error(`timeout:${timeout}`);
        throw error;
      } finally {
        if (timer) clearTimeout(timer);
        signal?.removeEventListener("abort", onAbort);
      }
    },
  };
}

export default function(pi: ExtensionAPI) {
  const localCwd = process.cwd();
  const localRead = createReadTool(localCwd);
  const localWrite = createWriteTool(localCwd);
  const localEdit = createEditTool(localCwd);
  const localBash = createBashTool(localCwd);
  const localGrep = createGrepTool(localCwd);
  const localFind = createFindTool(localCwd);
  const localLs = createLsTool(localCwd);

  let vm: VM | undefined;
  let vmStarting: Promise<VM> | undefined;
  let shellPath = "/bin/sh";

  async function startVm(ctx?: ExtensionContext): Promise<VM> {
    ctx?.ui.setStatus("gondolin", ctx.ui.theme.fg("accent", `Gondolin: starting ${GUEST_WORKSPACE}`));
    const sandboxOptions = await resolveSandboxOptions(localCwd, (message) => {
      if (!ctx) return;
      ctx.ui.setStatus("gondolin", ctx.ui.theme.fg("accent", `Gondolin: ${message}`));
    });
    const created = await VM.create({
      sessionLabel: `pi ${path.basename(localCwd)}`,
      ...(sandboxOptions && { sandbox: sandboxOptions }),
      vfs: {
        mounts: {
          [GUEST_WORKSPACE]: new RealFSProvider(localCwd),
          [GUEST_NIX_STORE]: new ReadonlyProvider(new RealFSProvider(HOST_NIX_STORE)),
        },
      },
    });
    const bashProbe = await created.exec(["/bin/sh", "-lc", "command -v bash || true"]);
    shellPath = bashProbe.stdout.trim() || "/bin/sh";
    vm = created;
    ctx?.ui.setStatus(
      "gondolin",
      ctx.ui.theme.fg("accent", `Gondolin: ${created.id.slice(0, 8)} (${GUEST_WORKSPACE})`),
    );
    ctx?.ui.notify(
      `Gondolin VM ready. ${localCwd} is mounted at ${GUEST_WORKSPACE}. Image: ${sandboxOptions?.imagePath ?? "default"}.`,
      "info",
    );
    return created;
  }

  async function ensureVm(ctx?: ExtensionContext): Promise<VM> {
    if (vm) return vm;
    if (!vmStarting) {
      vmStarting = startVm(ctx).finally(() => {
        vmStarting = undefined;
      });
    }
    return vmStarting;
  }

  pi.on("session_start", (_event, ctx) => {
    // Fire and forget so image resolution/builds don't block session startup;
    // ensureVm() dedupes, so the first tool call joins the in-flight start.
    void ensureVm(ctx).catch((error: unknown) => {
      ctx.ui.notify(`Gondolin VM failed to start: ${errorMessage(error)}`, "error");
    });
  });

  pi.on("session_shutdown", async (_event, ctx) => {
    const activeVm = vm;
    vm = undefined;
    vmStarting = undefined;
    if (!activeVm) return;
    ctx.ui.setStatus("gondolin", ctx.ui.theme.fg("muted", "Gondolin: stopping"));
    try {
      await activeVm.close();
    } finally {
      ctx.ui.setStatus("gondolin", undefined);
    }
  });

  pi.registerCommand("gondolin", {
    description: "Show Gondolin VM status",
    handler: async (_args, ctx) => {
      const activeVm = await ensureVm(ctx);
      ctx.ui.notify(
        [
          `Gondolin VM: ${activeVm.id}`,
          `Host workspace: ${localCwd}`,
          `Guest workspace: ${GUEST_WORKSPACE}`,
          `Shell: ${shellPath}`,
        ].join("\n"),
        "info",
      );
    },
  });

  pi.registerTool({
    ...localRead,
    async execute(id, params, signal, onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      const tool = createReadTool(GUEST_WORKSPACE, {
        operations: createGondolinReadOps(activeVm, localCwd),
      });
      return tool.execute(id, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    ...localWrite,
    async execute(id, params, signal, onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      const tool = createWriteTool(GUEST_WORKSPACE, {
        operations: createGondolinWriteOps(activeVm, localCwd),
      });
      return tool.execute(id, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    ...localEdit,
    async execute(id, params, signal, onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      const tool = createEditTool(GUEST_WORKSPACE, {
        operations: createGondolinEditOps(activeVm, localCwd),
      });
      return tool.execute(id, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    ...localBash,
    async execute(id, params, signal, onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      const tool = createBashTool(GUEST_WORKSPACE, {
        operations: createGondolinBashOps(activeVm, localCwd, shellPath),
      });
      return tool.execute(id, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    ...localLs,
    async execute(id, params, signal, onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      const tool = createLsTool(GUEST_WORKSPACE, {
        operations: createGondolinLsOps(activeVm, localCwd),
      });
      return tool.execute(id, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    ...localFind,
    async execute(id, params, signal, onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      const tool = createFindTool(GUEST_WORKSPACE, {
        operations: createGondolinFindOps(activeVm, localCwd),
      });
      return tool.execute(id, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    ...localGrep,
    async execute(_id, params, signal, _onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      return executeGondolinGrep(activeVm, localCwd, params, signal);
    },
  });

  pi.on("user_bash", async (_event, ctx) => {
    const activeVm = await ensureVm(ctx);
    return { operations: createGondolinBashOps(activeVm, localCwd, shellPath) };
  });

  pi.on("before_agent_start", async (event, ctx) => {
    await ensureVm(ctx);
    const localLine = `Current working directory: ${localCwd}`;
    const guestLine = `Current working directory: ${GUEST_WORKSPACE} (Gondolin VM; host workspace mounted from ${localCwd})`;
    const systemPrompt = event.systemPrompt.includes(localLine)
      ? event.systemPrompt.replace(localLine, guestLine)
      : `${event.systemPrompt}\n\n${guestLine}`;
    return { systemPrompt };
  });
}
