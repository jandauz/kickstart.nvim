return {
  {
    'nvim-lua/plenary.nvim',
    event = 'VeryLazy',
    config = function()
      local go_group = vim.api.nvim_create_augroup('GoSettings', { clear = true })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'go',
        group = go_group,
        callback = function()
          vim.bo.tabstop = 4
          vim.bo.shiftwidth = 4
          vim.bo.softtabstop = 4
        end,
      })
    end,
  },
}
