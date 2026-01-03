-- ============================================================================
-- Treesitter Configuration
-- ============================================================================
-- Better syntax highlighting and code understanding using tree-sitter parsers

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    -- Install language parsers
    local parsers = {
      "bash",
      "c",
      "css",
      "dockerfile",
      "go",
      "html",
      "javascript",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "php",
      "python",
      "rust",
      "toml",
      "typescript",
      "vim",
      "yaml",
    }

    -- Install parsers asynchronously
    require("nvim-treesitter").install(parsers)

    -- Enable treesitter highlighting for all file types
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })

    -- Enable treesitter-based folding
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function()
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo[0][0].foldmethod = "expr"
        vim.wo[0][0].foldenable = false  -- Don't fold by default
      end,
    })

    -- Enable treesitter-based indentation
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function()
        vim.bo.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
      end,
    })
  end,
}
