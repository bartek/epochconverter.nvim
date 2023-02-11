-- https://jdhao.github.io/2021/09/09/nvim_use_virtual_text/
local vim = vim
local api = vim.api
local lsp = vim.lsp

-- Plugin status
local is_enabled = true

-- Defaults
local year = 365 * 24 * 60 * 60
local date_min = os.time() - (10 * year)
local date_max = os.time()

-- Namespace for virtual text messages
local virtual_types_ns = api.nvim_create_namespace("virtual_types")

local M = {}

function set_virtual_text(buffer_number, ns, start_line, msg)
  if (type(msg[1]) ~= "string") or (msg[2] ~= "TypeAnnot") then
    return
  end
  api.nvim_buf_set_extmark(
    buffer_number,
    ns,
    start_line,
    1,
    { virt_text = { msg }, hl_mode = "combine" }
  )
end

function M.enable()
  is_enabled = true
  M.annotate_timestamps_async()
end

function M.disable()
  api.nvim_buf_clear_namespace(buffer_number, virtual_types_ns, 0, -1)
  is_enabled = false
end

function M.load()
  annotate_timestamps()

   -- Setup autocmd
  api.nvim_exec(
    [[
    augroup epochconverter_refresh
      autocmd! * <buffer>
      autocmd CursorMoved <buffer> lua require'epochconverter'.annotate_timestamps_async()
    augroup END]],
    ""
  )
end

-- From TimeZone tricks: http://lua-users.org/wiki/TimeZone
function default_timezone_offset(ts)
    local utcdate   = os.date("!*t", ts)
    local localdate = os.date("*t", ts)
    localdate.isdst = false
    return os.difftime(os.time(localdate), os.time(utcdate))
end

function annotate_timestamps()
  if is_enabled == false then
    return
  end

  if vim.fn.getcmdwintype() == ":" then
    return
  end

  local buffer_number = api.nvim_get_current_buf()

  -- Clear previous highlighting
  api.nvim_buf_clear_namespace(buffer_number, virtual_types_ns, 0, -1)

  local pos = api.nvim_win_get_cursor(0) -- row, col
  local line = api.nvim_get_current_line()
  if line == "" then
    return
  end

  local ts = find_unix_timestamp(line)
  if ts ~= nil then
    local offset = default_timezone_offset(ts)
    local msg = { os.date("%Y-%m-%d %H:%M:%S", ts + offset), "TypeAnnot" }
    set_virtual_text(buffer_number, virtual_types_ns, pos[1]-1, msg)
  end
end


-- Async wrapper for annotate_timestamps
function M:annotate_timestamps_async()
  cr = vim.schedule(annotate_timestamps)
end

-- Utility
function find_unix_timestamp(str)
  local pattern = "(%d+)"
  local ts = string.match(str, pattern)
  if ts == nil then
    return
  end

  ts = tonumber(ts)
  if ts == nil then
    return
  end

  if ts >= date_min and ts <= date_max then
     return ts
  end
end

return M
