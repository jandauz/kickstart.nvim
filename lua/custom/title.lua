local M = {}

local cache = { cwd = '', title = '' }

local function get_title()
  local cwd = vim.fn.getcwd()
  if cwd == cache.cwd then
    return cache.title
  end

  local esc = vim.fn.shellescape(cwd)
  local toplevel = vim.fn.systemlist('git -C ' .. esc .. ' rev-parse --show-toplevel 2>/dev/null')[1]
  if vim.v.shell_error ~= 0 or not toplevel or toplevel == '' then
    cache.cwd = cwd
    cache.title = vim.fn.fnamemodify(cwd, ':t')
    return cache.title
  end

  local common_dir = vim.fn.systemlist('git -C ' .. esc .. ' rev-parse --git-common-dir 2>/dev/null')[1]
  local branch = vim.fn.systemlist('git -C ' .. esc .. ' branch --show-current 2>/dev/null')[1]

  -- For bare repo worktrees, common-dir points to the bare repo (e.g. .bare)
  -- Use its parent as the repo name
  local repo_name
  if common_dir and not common_dir:match '%.git$' then
    repo_name = vim.fn.fnamemodify(vim.fn.fnamemodify(common_dir, ':h'), ':t')
  else
    repo_name = vim.fn.fnamemodify(toplevel, ':t')
  end

  local title = repo_name
  if branch and branch ~= '' and branch ~= repo_name then
    title = repo_name .. ' (' .. branch .. ')'
  end

  cache.cwd = cwd
  cache.title = title
  return title
end

function M.__call()
  return get_title()
end

function M.setup()
  vim.api.nvim_create_autocmd({ 'DirChanged', 'BufEnter' }, {
    group = vim.api.nvim_create_augroup('custom-title', { clear = true }),
    callback = function()
      cache.cwd = '' -- invalidate cache
      vim.opt.titlestring = get_title()
    end,
  })
end

return setmetatable(M, M)
