local M = {}

local timer = nil
local end_time = nil
local task_name = ""

local function now_ms()
  return vim.uv.now()
end

local function set_status(text)
  vim.g.focus_task_status = text
  vim.cmd("redrawstatus")
end

local function clear_status()
  vim.g.focus_task_status = nil
  vim.cmd("redrawstatus")
end

local function format_remaining(ms)
  if ms < 0 then
    ms = 0
  end
  local total = math.floor(ms / 1000)
  local mins = math.floor(total / 60)
  local secs = total % 60
  return ("%02d:%02d"):format(mins, secs)
end

local function stop_timer()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
  end_time = nil
  task_name = ""
  clear_status()
end

local function tick()
  if not end_time then
    return
  end
  local remaining = end_time - now_ms()
  if remaining <= 0 then
    stop_timer()
    vim.schedule(function()
      vim.notify("⏰ Task finished" .. (task_name ~= "" and (": " .. task_name) or ""), vim.log.levels.INFO)
    end)
    return
  end
  local label = task_name ~= "" and task_name or "Timer"
  set_status((" ⏳ %s (%s)"):format(label, format_remaining(remaining)))
end

function M.start(minutes, name)
  if timer then
    vim.notify("A task timer is already running. Use :Fc first.", vim.log.levels.WARN)
    return
  end
  if not minutes or minutes <= 0 then
    vim.notify("Usage: Ft {minutes} [task name...]", vim.log.levels.ERROR)
    return
  end
  task_name = name or ""
  end_time = now_ms() + (minutes * 60 * 1000)

  timer = vim.uv.new_timer()
  timer:start(0, 1000, function()
    vim.schedule(tick)
  end)
end

function M.cancel()
  if not timer then
    vim.notify("No task timer running.", vim.log.levels.INFO)
    return
  end
  stop_timer()
end

function M.setup()
  vim.api.nvim_create_user_command("Ft", function(opts)
    local args = opts.fargs
    local mins = tonumber(args[1])
    local name = ""
    if #args > 1 then
      name = table.concat(vim.list_slice(args, 2), " ")
    end
    M.start(mins, name)
  end, { nargs = "+", desc = "Start focus task timer" })

  vim.api.nvim_create_user_command("Fc", function()
    M.cancel()
  end, { nargs = 0, desc = "Cancel focus task timer" })

  vim.api.nvim_create_user_command("AddTask", function(opts)
    vim.cmd("Ft " .. opts.args)
  end, { nargs = "+", desc = "Alias for :Ft" })

  vim.api.nvim_create_user_command("CancelTask", function()
    M.cancel()
  end, { nargs = 0, desc = "Alias for :Fc" })
end

return M

