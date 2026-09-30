return {
  {
    'saghen/blink.cmp',
    dependencies = {
      'rafamadriz/friendly-snippets',
      'folke/lazydev.nvim',
    },
    version = '*',
    opts = {
      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = 'mono',
      },
      completion = {
        ghost_text = {
          enabled = true,
        },
        documentation = {
          window = {
            border = 'rounded',
          },
        },
        menu = {
          border = 'rounded',
        },
      },
      keymap = { preset = 'default' },
      signature = {
        enabled = true,
        window = { border = 'rounded' },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' },
        providers = {
          lsp = {
            min_keyword_length = 2,
            score_offset = 0,
          },
          path = {
            min_keyword_length = 0,
          },
          snippets = {
            min_keyword_length = 2,
          },
          buffer = {
            min_keyword_length = 5,
          },
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
        },
      },
      fuzzy = {
        implementation = 'prefer_rust_with_warning',
      },
    },
    opts_extend = { 'sources.default', 'sources.providers', 'sources.completion.enabled_providers', 'appearance.kind_icons' },
  },
}
