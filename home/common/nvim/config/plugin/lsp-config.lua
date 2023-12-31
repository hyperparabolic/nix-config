
local nvim_lsp = require("lspconfig")

-- only map keybinds after language server attaches
-- to current buffer
local on_attach = function(client, bufnr)
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  require("illuminate").on_attach(client)

  -- Mappings.
  local opts = { noremap = true, silent = true, buffer = bufnr }
  require("legendary").keymaps({
    { "gD", vim.lsp.buf.declaration, description = "LSP: Go to declaration", opts = opts },
    { "gd", vim.lsp.buf.definition, description = "LSP: Go to definition", opts = opts },
    { "K", vim.lsp.buf.hover, description = "LSP: Hover", opts = opts },
    { "gi", vim.lsp.buf.implementation, description = "LSP: Go to implementation", opts = opts },
    { "<C-s>", vim.lsp.buf.signature_help, description = "LSP: Signature help", mode = { "n", "i" }, opts = opts },
    { ",wa", vim.lsp.buf.add_workspace_folder, description = "LSP: Add workspace folder", opts = opts },
    { ",wr", vim.lsp.buf.remove_workspace_folder, description = "LSP: Remove workspace folder", opts = opts },
    {
      ",wl",
      function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end,
      description = "LSP: List workspaces",
      opts = opts,
    },
    { ",D", vim.lsp.buf.type_definition, description = "LSP: Show type definition", opts = opts },
    { ",rn", vim.lsp.buf.rename, description = "LSP: Rename", opts = opts },
    { ",ca", vim.lsp.buf.code_action, description = "LSP: Code Action", opts = opts },
    { "gr", vim.lsp.buf.references, description = "LSP: Show references", opts = opts },
    {
      ",e",
      function()
        vim.diagnostic.open_float(0, { scope = "line" })
      end,
      description = "Diagnostics: Show window",
      opts = opts,
    },
    {
      "[d",
      function()
        vim.diagnostic.goto_prev({ float = { border = "single" } })
      end,
      description = "Diagnostics: Previous",
      opts = opts,
    },
    {
      "]d",
      function()
        vim.diagnostic.goto_next({ float = { border = "single" } })
      end,
      description = "Diagnostics: Next",
      opts = opts,
    },
    { ",q", vim.diagnostic.setloclist, description = "Diagnostic: Show location list", opts = opts },
    { ",f", vim.lsp.buf.formatting, description = "LSP: Format file", opts = opts },
    {
      "]u",
      function()
        require("illuminate").next_reference({ wrap = true })
      end,
      description = "Illuminate: Next reference",
      opts = opts,
    },
    {
      "[u",
      function()
        require("illuminate").next_reference({ reverse = true, wrap = true })
      end,
      description = "Illuminate: Previous reference",
      opts = opts,
    },
  })
end

local notify = require("notify")
vim.lsp.handlers["window/showMessage"] = function(_, result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  local lvl = ({ "ERROR", "WARN", "INFO", "DEBUG" })[result.type]
  notify({ result.message }, lvl, {
    title = "LSP | " .. client.name,
    timeout = 10000,
    keep = function()
      return lvl == "ERROR" or lvl == "WARN"
    end,
  })
end

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- Enable Language Servers
local function default_lsp_setup(module)
  nvim_lsp[module].setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

-- Bash
default_lsp_setup("bashls")

-- Lua
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")
nvim_lsp.lua_ls.setup({
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
        -- Setup your lua path
        path = runtime_path,
      },
      completion = {
        callSnippet = "Replace",
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { "vim" },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Nix
nvim_lsp.nil_ls.setup({
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)

    -- Let statix format
    client.server_capabilities.document_formatting = false
    client.server_capabilities.document_range_formatting = false
  end,
})

-- Typescript
nvim_lsp.tsserver.setup({
  init_options = require("nvim-lsp-ts-utils").init_options,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)

    -- Let eslint format
    client.server_capabilities.document_formatting = false
    client.server_capabilities.document_range_formatting = false

    local ts_utils = require("nvim-lsp-ts-utils")
    ts_utils.setup({
      enable_import_on_completion = true,
    })
    ts_utils.setup_client(client)

    -- Mappings.
    local opts = { noremap = true, silent = true, buffer = true }
    require("legendary").keymaps({
      { "gto", ":TSLspOrganize<CR>", description = "LSP: Organize imports", opts = opts },
      { "gtr", ":TSLspRenameFile<CR>", description = "LSP: Rename file", opts = opts },
      { "gti", ":TSLspImportAll<CR>", description = "LSP: Import missing imports", opts = opts },
    })
  end,
  capabilities = capabilities,
})

-- Web
-- ESLint
nvim_lsp.eslint.setup({
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    -- Run all eslint fixes on save
    vim.cmd([[
            augroup EslintOnSave
                autocmd! * <buffer>
                autocmd BufWritePre <buffer> EslintFixAll
            augroup END
            ]])
  end,
  capabilities = capabilities,
})

-- CSS
default_lsp_setup("cssls")

-- HTML
default_lsp_setup("html")

-- JSON
default_lsp_setup("jsonls")

-- TODO: lsp driven colors

