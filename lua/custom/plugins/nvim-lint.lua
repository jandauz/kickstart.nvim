return {
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPost', 'BufWritePost', 'InsertLeave' },
    dependencies = {
      'williamboman/mason.nvim', -- Ensure linters are installed
    },
    config = function()
      local M = {}
      local lint = require 'lint'

      -- Configure linters for different filetypes
      lint.linters_by_ft = {
        go = { 'golangcilint' },
        terraform = { 'tflint' },
        tf = { 'tflint' },
        -- Use the "*" filetype to run linters on all filetypes
        -- ['*'] = { 'global linter' },
        -- Use the "_" filetype to run linters on filetypes that don't have other linters configured
        -- ['_'] = { 'fallback linter' },
      }

      -- Configure specific linter options
      lint.linters.golangcilint = vim.tbl_deep_extend('force', lint.linters.golangcilint or {}, {
        args = {
          'run',
          '--out-format=json',
          '--issues-exit-code=0',
          '--sort-results',
          '--new-from-rev=HEAD~1',
          -- Let golangci-lint use its config file (.golangci.yml)
          -- No need to specify linters here as they'll be defined in the project config
        },
        -- Optional: only run when we're in a Go project
        condition = function(ctx)
          return vim.fs.find({ 'go.mod' }, { path = ctx.filename, upward = true })[1] ~= nil
        end,
        ignore_exitcode = true,
      })

      -- Helper function to debounce lint calls
      function M.debounce(ms, fn)
        local timer = vim.loop.new_timer()
        return function(...)
          local argv = { ... }
          timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
          end)
        end
      end

      -- Custom lint function that includes fallback and global linters
      function M.lint()
        -- Use nvim-lint's logic first to resolve linters for the filetype
        local names = lint._resolve_linter_by_ft(vim.bo.filetype)

        -- Create a copy of the names table to avoid modifying the original
        names = vim.list_extend({}, names)

        -- Add fallback linters if no linters found for this filetype
        if #names == 0 then
          vim.list_extend(names, lint.linters_by_ft['_'] or {})
        end

        -- Add global linters that run on all filetypes
        vim.list_extend(names, lint.linters_by_ft['*'] or {})

        -- Filter out linters that don't exist or don't match the condition
        local ctx = { filename = vim.api.nvim_buf_get_name(0) }
        ctx.dirname = vim.fn.fnamemodify(ctx.filename, ':h')
        names = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          if not linter then
            vim.notify('Linter not found: ' .. name, vim.log.levels.WARN, { title = 'nvim-lint' })
            return false
          end
          return not (type(linter) == 'table' and linter.condition and not linter.condition(ctx))
        end, names)

        -- Run linters
        if #names > 0 then
          lint.try_lint(names)
        end
      end

      -- Set up autocommands to trigger linting with debounce
      vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost', 'InsertLeave' }, {
        group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
        callback = M.debounce(100, function()
          -- Only lint if the buffer is modifiable to avoid issues with readonly files
          if vim.bo.modifiable and vim.bo.buftype == '' then
            M.lint()
          end
        end),
      })
    end,
  },
}
