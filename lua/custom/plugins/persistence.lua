return {
  'folke/persistence.nvim',
  event = 'BufReadPre',
  opts = {},
  init = function()
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        -- only auto-restore when nvim opened with no file args (bare `nvim` in a project)
        if vim.fn.argc() == 0 then
          require('persistence').load()
        end
      end,
      nested = true,
    })
  end,
  keys = {
    {
      '<leader>qs',
      function()
        require('persistence').load()
      end,
      desc = 'Restore session (cwd)',
    },
    {
      '<leader>ql',
      function()
        require('persistence').load { last = true }
      end,
      desc = 'Restore last session',
    },
    {
      '<leader>qd',
      function()
        require('persistence').stop()
      end,
      desc = "Don't save session",
    },
  },
}
