/**
 * SearXNG Web Search
 *
 * Registers an LLM-callable `web_search` tool backed by Spencer's self-hosted
 * SearXNG instance (https://search.oak.decent.id). Returns titles, URLs, and
 * snippets as plain text so the model can cite sources without extra fetching.
 *
 * Override the endpoint for testing with the SEARXNG_BASE_URL env var.
 */

import { StringEnum } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type, type Static } from "typebox";

const SEARXNG_BASE_URL = process.env.SEARXNG_BASE_URL ?? "https://search.oak.decent.id";
const MAX_RESULTS = 8;
const TIMEOUT_MS = 30_000;

// Categories are ordered by usefulness; 'files' is omitted because its engines
// are disabled on the instance and it returns irrelevant results.
const CATEGORIES = [
  "general",
  "news",
  "videos",
  "images",
  "it",
  "packages",
  "science",
] as const;

const TIME_RANGES = ["day", "week", "month", "year"] as const;

const parameters = Type.Object({
  query: Type.String({ description: "Search query" }),
  category: Type.Optional(
    StringEnum(CATEGORIES, {
      description:
        "Limit results to a category. Omit for best results ('general' handles most queries). " +
        "'science' searches arXiv/PubMed/journals; 'videos' finds YouTube etc.; " +
        "'packages' only covers dev registries (npm, crates.io, Docker Hub) — NOT distro repos like nixpkgs/apt; " +
        "'it' restricts to Q&A sites (noisy for factual queries); 'images' returns image-hosting pages.",
    }),
  ),
  timeRange: Type.Optional(
    StringEnum(TIME_RANGES, {
      description: "Only include results published within this time range.",
    }),
  ),
  page: Type.Optional(
    Type.Integer({
      minimum: 1,
      description: "Result page number (1-based). Omit for the first page.",
    }),
  ),
});

export type WebSearchToolInput = Static<typeof parameters>;

interface SearxngResult {
  title?: string;
  url?: string;
  content?: string;
}

interface SearxngResponse {
  answers?: Array<string | { answer?: string }>;
  results?: SearxngResult[];
  suggestions?: string[];
}

function collapseWhitespace(text: string): string {
  return text.replace(/\s+/g, " ").trim();
}

export default function searxngExtension(pi: ExtensionAPI) {
  pi.registerTool({
    name: "web_search",
    label: "Web Search",
    description:
      "Search the web via SearXNG. Returns ranked results with title, URL, and " +
      "snippet, plus instant answers and related searches when available.",
    promptSnippet: "Search the web with SearXNG for up-to-date information",
    promptGuidelines: [
      "Use web_search when you need current information beyond your training data:",
      "recent events, documentation, package versions, prices, or facts you are unsure of.",
    ],
    parameters,

    async execute(_toolCallId, params, signal) {
      const url = new URL("/search", SEARXNG_BASE_URL);
      url.searchParams.set("q", params.query);
      url.searchParams.set("format", "json");
      if (params.category) {
        url.searchParams.set("categories", params.category);
      }
      if (params.timeRange) {
        url.searchParams.set("time_range", params.timeRange);
      }
      if (params.page && params.page > 1) {
        url.searchParams.set("pageno", String(params.page));
      }

      const timeout = AbortSignal.timeout(TIMEOUT_MS);
      const response = await fetch(url, {
        headers: { Accept: "application/json" },
        signal: signal ? AbortSignal.any([signal, timeout]) : timeout,
      });

      if (!response.ok) {
        const body = await response.text().catch(() => "");
        throw new Error(
          `SearXNG returned HTTP ${response.status} for ${url.pathname}?${url.searchParams}. ` +
            `Response: ${collapseWhitespace(body).slice(0, 200)}`,
        );
      }

      const data = (await response.json()) as SearxngResponse;

      const sections: string[] = [];
      const page = params.page ?? 1;

      for (const answer of data.answers ?? []) {
        const text = typeof answer === "string" ? answer : answer.answer;
        if (text) {
          sections.push(`Answer: ${collapseWhitespace(text)}`);
          break;
        }
      }

      const results = (data.results ?? [])
        .slice(0, MAX_RESULTS)
        .map((result, index) => {
          const title = collapseWhitespace(result.title ?? "(untitled)");
          const snippet = collapseWhitespace(result.content ?? "");
          return `${index + 1}. ${title}\n   ${result.url ?? "(no URL)"}${
            snippet ? `\n   ${snippet}` : ""
          }`;
        });

      sections.push(
        results.length > 0
          ? `Web results for "${params.query}"${page > 1 ? ` (page ${page})` : ""}:\n\n${results.join("\n\n")}`
          : `No results found for "${params.query}". Try rephrasing or removing filters.`,
      );

      if (data.suggestions?.length) {
        sections.push(`Related searches: ${data.suggestions.slice(0, 5).join(", ")}`);
      }

      return {
        content: [{ type: "text", text: sections.join("\n\n") }],
        details: {
          baseUrl: SEARXNG_BASE_URL,
          category: params.category,
          page,
          query: params.query,
          resultCount: results.length,
          timeRange: params.timeRange,
        },
      };
    },
  });
}
