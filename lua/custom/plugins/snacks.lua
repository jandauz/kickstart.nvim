return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      image = { enabled = true },
      dashboard = {
        preset = {
          header = [[
                                                                            
              ████ ██████           █████      ██                     
             ███████████             █████                             
             █████████ ███████████████████ ███   ███████████   
            █████████  ███    █████████████ █████ ██████████████   
           █████████ ██████████ █████████ █████ █████ ████ █████   
         ███████████ ███    ███ █████████ █████ █████ ████ █████  
        ██████  █████████████████████ ████ █████ █████ ████ ██████ 
        ]],
        },
      },
      indent = {
        enabled = true,
        animate = {
          duration = {
            step = 10,
            total = 250,
          },
        },
        indent = {
          enabled = false,
        },
        scope = {
          only_current = true,
        },
      },
      input = { enabled = true },
      lazygit = {
        enabled = true,
        win = {
          backdrop = 90,
          width = 0.95,
          height = 0.95,
        },
      },
      notifier = { enabled = true },
      picker = {
        matcher = {
          frecency = true,
        },
        previewers = {
          -- delta styling lives in ~/.gitconfig [delta], so both paths inherit it
          diff = { style = 'terminal', cmd = { 'delta' } },
          git = { args = { '-c', 'core.pager=delta' } },
        },
        win = {
          input = {
            keys = {
              ['J'] = { 'preview_scroll_down', mode = { 'n' } },
              ['K'] = { 'preview_scroll_up', mode = { 'n' } },
              ['H'] = { 'preview_scroll_left', mode = { 'n' } },
              ['L'] = { 'preview_scroll_right', mode = { 'n' } },
            },
          },
        },
      },
      quickfile = { enabled = true },
      scroll = {
        enabled = true,
        animate = {
          fps = 120,
          duration = { step = 15, total = 150 },
          easing = 'linear',
        },
        animate_repeat = {
          delay = 50,
          duration = { step = 5, total = 50 },
          easing = 'linear',
        },
      },
      scope = { enabled = true },
      statuscolumn = { enabled = true },
      terminal = {
        enabled = true,
        win = {
          backdrop = 90,
          border = 'rounded',
          position = 'float',
          style = 'terminal',
          wo = { winhighlight = 'NormalFloat:Normal' },
          zindex = 20,
        },
      },
      words = { enabled = true },
    },
    keys = function()
      local Snacks = require 'snacks'

      local function get_root_dir()
        local cwd = vim.fn.getcwd()
        local root = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(cwd) .. ' rev-parse --show-toplevel 2>/dev/null')[1]
        return vim.v.shell_error == 0 and root and root ~= '' and root or cwd
      end

      local function toggle_terminal()
        Snacks.terminal(nil, { cwd = get_root_dir() })
      end

      -- Function to handle optional layout configuration
      -- without overriding default layout behavior when not needed
      local function with_config(base_opts, extra_opts)
        return vim.tbl_deep_extend('force', {}, base_opts or {}, extra_opts or {})
      end

      -- Special layout for buffers, lsp references, etc that should use a custom vscode layout
      local function with_vscode_preview(opts)
        return with_config(opts, {
          layout = {
            hidden = { 'input' },
            preview = 'main',
            preset = 'vscode',
            layout = {
              row = 0,
              width = 0.2,
              min_width = 70,
              border = 'rounded',
            },
          },
          on_show = function()
            vim.cmd.stopinsert()
          end,
        })
      end

      return {
        -- Terminal
        {
          '<C-/>',
          toggle_terminal,
          desc = 'Toggle Terminal',
          mode = { 'n', 't' },
        },
        {
          '<C-_>',
          toggle_terminal,
          desc = 'Toggle Terminal',
          mode = { 'n', 't' },
        },
        -- Picker - standard pickers with default layout
        {
          '<leader><space>',
          function()
            Snacks.picker.smart(with_config { cwd = get_root_dir(), multi = { 'recent', 'buffers' } })
          end,
          desc = '[ ] Smart find files',
        },
        {
          '<leader>sh',
          function()
            Snacks.picker.help()
          end,
          desc = '[S]earch [H]elp',
        },
        {
          '<leader>sk',
          function()
            Snacks.picker.keymaps()
          end,
          desc = '[S]earch [K]eymaps',
        },
        {
          '<leader>sf',
          function()
            Snacks.picker.files(with_config { cwd = get_root_dir() })
          end,
          desc = '[S]earch [F]iles',
        },
        {
          '<leader>sw',
          function()
            Snacks.picker.grep_word(with_config { cwd = get_root_dir() })
          end,
          desc = '[S]earch current [W]ord',
          mode = { 'n', 'x' },
        },
        {
          '<leader>sg',
          function()
            Snacks.picker.grep(with_config { cwd = get_root_dir() })
          end,
          desc = '[S]earch by [G]rep',
        },
        {
          '<leader>sd',
          function()
            Snacks.picker.diagnostics()
          end,
          desc = '[S]earch [D]iagnostics',
        },
        {
          '<leader>sr',
          function()
            Snacks.picker.resume()
          end,
          desc = '[S]earch [R]esume',
        },
        {
          '<leader>s.',
          function()
            Snacks.picker.recent()
          end,
          desc = '[S]earch Recent Files ("." for repeat)',
        },
        -- Pickers with vscode layout and main preview
        {
          '<leader>sb',
          function()
            Snacks.picker.buffers(with_vscode_preview {
              current = true,
              hidden = false,
              sort_lastused = true,
              unloaded = true,
              win = {
                input = {
                  keys = {
                    ['d'] = 'bufdelete',
                  },
                },
                list = {
                  keys = {
                    ['d'] = 'bufdelete',
                  },
                },
              },
            })
          end,
          desc = '[S]earch existing [B]uffers',
        },
        {
          '<leader>sn',
          function()
            Snacks.picker.files(with_config { cwd = vim.fn.stdpath 'config' })
          end,
          desc = '[S]earch [N]eovim config',
        },
        -- Lazygit
        {
          '<C-g>',
          function()
            Snacks.lazygit()
          end,
          desc = 'Open Lazygit',
        },
        -- Changed-files list on the left, diff preview on the right; a light
        -- diff reviewer. Move the list with <c-n>/<c-p>, scroll the diff with
        -- J and K, open the file with <cr> to drop a review comment.
        {
          '<leader>gs',
          function()
            Snacks.picker.git_status(with_config {
              cwd = get_root_dir(),
              on_show = function()
                vim.cmd.stopinsert()
              end,
              -- focus opens on the list, so scroll the diff from there with J and K
              win = {
                list = {
                  keys = {
                    ['J'] = { 'preview_scroll_down', mode = { 'n' } },
                    ['K'] = { 'preview_scroll_up', mode = { 'n' } },
                    ['H'] = { 'preview_scroll_left', mode = { 'n' } },
                    ['L'] = { 'preview_scroll_right', mode = { 'n' } },
                  },
                },
              },
              layout = {
                layout = {
                  box = 'horizontal',
                  width = 0.92,
                  height = 0.92,
                  {
                    box = 'vertical',
                    width = 0.28,
                    border = 'rounded',
                    title = 'Changes',
                    title_pos = 'center',
                    { win = 'input', height = 1, border = 'bottom' },
                    { win = 'list', border = 'none' },
                  },
                  { win = 'preview', title = '{preview}', width = 0.72, border = 'rounded' },
                },
              },
            })
          end,
          desc = '[G]it [S]tatus (review changes)',
        },
        -- Unified git diff in a float. The delta config in ~/.gitconfig renders
        -- the hunks inline. This is a read-only glance. Use <leader>gs to open
        -- files and drop review comments.
        {
          '<leader>gd',
          function()
            Snacks.terminal('git diff', { cwd = get_root_dir() })
          end,
          desc = '[G]it [D]iff (unified)',
        },
      }
    end,
  },
}
