return {
  {
    "mammothb/sixel-graphics.nvim",
    dev = true,
    ft = { "markdown" },
    opts = {
      enabled = true,
      sixel_pixel_scale = 0.625,
      popup_render_delay_ms = 16,
      debug = {
        enabled = false,
        level = "debug",
        file_path = "/tmp/sixel-graphics-debug.log",
      },
      hover = {
        diagrams = { enabled = true },
        images = { enabled = true },
        debounce_ms = 150,
        max_screen_fraction = 0.85,
        filetypes = { "markdown" },
      },
      renderer_options = {
        mermaid = {
          renderer = "mmdr",
        },
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    tag = "v8.12.0",
    ft = { "markdown" },
    opts = {
      completions = {
        lsp = { enabled = true },
      },
    },
  },
}
