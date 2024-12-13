return {
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install && cd - && git restore .",
    setup = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },
}
