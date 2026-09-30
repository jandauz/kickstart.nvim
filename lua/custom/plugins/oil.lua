return {
  {
    'stevearc/oil.nvim',
    lazy = false,
    opts = {
      win_options = {
        wrap = true,
      },
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      keymaps = {
        ['<C-c>'] = false,
        ['q'] = 'actions.close',
      },
      view_options = {
        show_hidden = true,
        natural_order = true,
        is_always_hidden = function(name, _)
          return name == '..' or name == '.git'
        end,
      },
      float = {
        padding = 2,
        max_width = 90,
        max_height = 0,
      },
    },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '-', '<CMD>Oil --float<CR>', desc = 'Open parent directory' },
    },
  },
}
