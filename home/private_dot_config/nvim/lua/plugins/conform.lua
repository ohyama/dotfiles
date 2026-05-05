return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      -- "*" は全ファイルタイプにマッチ
      ["*"] = { "trim_whitespace", "trim_newlines" },
    },
  },
}
