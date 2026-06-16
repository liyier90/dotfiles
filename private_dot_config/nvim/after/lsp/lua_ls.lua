return {
  settings = {
    Lua = {
      hover = { expandAlias = false },
      type = {
        castNumberToInteger = true,
        inferParamType = true,
      },
      diagnostics = {
        groupSeverity = {
          strong = "Warning",
          strict = "Warning",
        },
      },
      groupFileStatus = {
        ["ambiguity"] = "Opened",
        ["await"] = "Opened",
        ["codestyle"] = "None",
        ["duplicate"] = "Opened",
        ["global"] = "Opened",
        ["luadoc"] = "Opened",
        ["redefined"] = "Opened",
        ["strict"] = "Opened",
        ["strong"] = "Opened",
        ["type-check"] = "Opened",
        ["unbalanced"] = "Opened",
        ["unused"] = "Opened",
      },
      unusedLocalExclude = { "_*" },
      format = { enable = false },
    },
  },
}
