return {
  -- Text editing
  {
    'echasnovski/mini.ai',
    event = 'VeryLazy',
    opts = {
      n_lines = 500,
    },
  },
  -- {
  --   'echasnovski/mini.comment',
  --   event = 'VeryLazy',
  --   opts = {
  --     hooks = {
  --       pre = function()
  --         local ts_utils = require('mini.comment.utils').get_commentstring_from_treesitter
  --         local ft = vim.bo.filetype
  --
  --         if ft == 'terraform' or ft == 'hcl' or ft == 'tf' then
  --           vim.bo.commentstring = '# %s'
  --           return true
  --         end
  --
  --         local ok = ts_utils()
  --         if ok then
  --           return true
  --         end
  --
  --         return false
  --       end,
  --     },
  --   },
  -- },
  {
    'echasnovski/mini.move',
    event = 'VeryLazy',
    opts = {},
  },
  {
    'echasnovski/mini.pairs',
    event = 'VeryLazy',
    opts = {},
  },
  {
    'echasnovski/mini.surround',
    event = 'VeryLazy',
    opts = {},
  },
  -- General workflow
  {
    'echasnovski/mini.bracketed',
    event = 'VeryLazy',
    opts = {},
  },
  {
    'echasnovski/mini.animate',
    event = 'VeryLazy',
    opts = function()
      local animate = require 'mini.animate'
      return {
        cursor = {
          enable = true,
          timing = animate.gen_timing.linear { duration = 100, unit = 'total' },
        },
        scroll = { enable = false },
        resize = {
          enable = true,
          timing = animate.gen_timing.linear { duration = 100, unit = 'total' },
        },
        open = {
          enable = true,
          timing = animate.gen_timing.linear { duration = 150, unit = 'total' },
        },
        close = {
          enable = true,
          timing = animate.gen_timing.linear { duration = 150, unit = 'total' },
        },
      }
    end,
  },
  {
    'echasnovski/mini.diff',
    event = 'VeryLazy',
    opts = {},
  },
  {
    'echasnovski/mini-git',
    event = 'VeryLazy',
    opts = {},
    main = 'mini.git',
  },
  -- Appearance
  {
    'echasnovski/mini.icons',
    lazy = true,
    opts = {
      file = {
        ['.keep'] = { glyph = '󰊢', hl = 'MiniIconsGrey' },
        ['devcontainer.json'] = { glyph = '', hl = 'MiniIconsAzure' },
      },
      filetype = {
        dotenv = { glyph = '', hl = 'MiniIconsYellow' },
      },
    },
    init = function()
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end
    end,
  },
  {
    'echasnovski/mini.statusline',
    event = 'VeryLazy',
    opts = function()
      local MiniStatusline = require 'mini.statusline'

      -- Return diagnostics highlighted by severity
      local function section_diagnostics()
        local diagnostics = vim.diagnostic.get(0)
        if #diagnostics == 0 then
          return ''
        end

        -- Count diagnostics by severity
        local severity_count = {
          [vim.diagnostic.severity.ERROR] = 0,
          [vim.diagnostic.severity.WARN] = 0,
          [vim.diagnostic.severity.INFO] = 0,
          [vim.diagnostic.severity.HINT] = 0,
        }

        for _, diagnostic in ipairs(diagnostics) do
          severity_count[diagnostic.severity] = severity_count[diagnostic.severity] + 1
        end

        -- Build diagnostic string
        local parts = {}
        if severity_count[vim.diagnostic.severity.ERROR] > 0 then
          table.insert(parts, string.format('%%#DiagnosticSignError#E:%d', severity_count[vim.diagnostic.severity.ERROR]))
        end
        if severity_count[vim.diagnostic.severity.WARN] > 0 then
          table.insert(parts, string.format('%%#DiagnosticSignWarn#W:%d', severity_count[vim.diagnostic.severity.WARN]))
        end
        if severity_count[vim.diagnostic.severity.INFO] > 0 then
          table.insert(parts, string.format('%%#DiagnosticSignInfo#I:%d', severity_count[vim.diagnostic.severity.INFO]))
        end
        if severity_count[vim.diagnostic.severity.HINT] > 0 then
          table.insert(parts, string.format('%%#DiagnosticSignHint#H:%d', severity_count[vim.diagnostic.severity.HINT]))
        end

        return table.concat(parts, ' ')
      end

      -- Return filetype icon with highlight group applied
      local function section_filetype()
        local ft = vim.bo.filetype
        if ft == '' then
          return ''
        end

        local icon = require('mini.icons').get('filetype', ft)
        if not icon then
          return ''
        end

        local hl_group = 'DevIcon' .. ft:gsub('^%l', string.upper)
        if vim.fn.hlexists(hl_group) == 0 then
          hl_group = '@type'
        end

        return '%#' .. hl_group .. '#' .. icon .. '%*'
      end

      -- Return relative filename
      local function section_filename()
        if vim.bo.buftype == 'terminal' then
          return '%t'
        end

        local path = vim.fn.expand '%:~:.'

        if path == '' then
          return '%f %m %r'
        end

        return path .. ' %m %r'
      end

      -- Return Lazy package updates
      local function section_lazy_updates()
        local lazy = require 'lazy.status'

        -- Get updates status using has_updates condition
        if lazy.has_updates() then
          return '' .. lazy.updates() -- Shows available updates
        end
      end

      -- Return simple location
      local function section_location()
        return '%l:%v'
      end

      return {
        content = {
          active = function()
            local mode, mode_hl = MiniStatusline.section_mode { trunc_width = 120 }
            local git = MiniStatusline.section_git { trunc_width = 40 }
            local search = MiniStatusline.section_searchcount { trunc_width = 75 }

            return MiniStatusline.combine_groups {
              { hl = mode_hl, strings = { mode } },
              { hl = 'MiniStatuslineDevinfo', strings = { git } },
              '%<', -- Mark general truncate point
              { hl = 'MiniStatusFilename', strings = { section_diagnostics() } },
              { hl = '', strings = { section_filetype(), section_filename() } },
              '%=', -- End left alignment
              { hl = '', strings = { section_lazy_updates() } },
              { hl = mode_hl, strings = { search, section_location() } },
            }
          end,
        },
        use_icons = vim.g.has_nerd_font,
      }
    end,
  },
}
