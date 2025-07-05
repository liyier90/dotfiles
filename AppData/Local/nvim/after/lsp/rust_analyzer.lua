return {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        extraEnv = {
          ["RUST_BACKTRACE"] = "0",
        },
      },
    },
  },
}
