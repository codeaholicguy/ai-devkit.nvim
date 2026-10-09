local M = {}

local function command_parts(config)
  local command = config.command or config.executable or "auto"

  if type(command) == "table" then
    return command[1], { unpack(command, 2) }
  end

  if command ~= "auto" then
    return command, {}
  end

  if vim.fn.executable("ai-devkit") == 1 then
    return "ai-devkit", {}
  end

  return "npx", { "ai-devkit@latest" }
end

local function build(config, args, stdin)
  local cmd, prefix = command_parts(config or {})
  local full_args = {}

  for _, arg in ipairs(prefix) do
    full_args[#full_args + 1] = arg
  end

  for _, arg in ipairs(args) do
    full_args[#full_args + 1] = arg
  end

  return {
    cmd = cmd,
    args = full_args,
    stdin = stdin,
  }
end

function M.list_command(config)
  return build(config, { "agent", "list", "--json" })
end

function M.detail_command(config, id, tail)
  return build(config, { "agent", "detail", "--id", id, "--json", "--tail", tostring(tail or 20) })
end

function M.send_command(config, id, message)
  return build(config, { "agent", "send", "--id", id, "--stdin" }, message)
end

function M.run(spec, callback)
  local stdout = {}
  local stderr = {}
  local argv = { spec.cmd }

  for _, arg in ipairs(spec.args) do
    argv[#argv + 1] = arg
  end

  vim.system(argv, {
    text = true,
    stdin = spec.stdin,
    stdout = function(_, data)
      if data then
        stdout[#stdout + 1] = data
      end
    end,
    stderr = function(_, data)
      if data then
        stderr[#stderr + 1] = data
      end
    end,
  }, function(result)
    result.stdout = table.concat(stdout)
    result.stderr = table.concat(stderr)
    vim.schedule(function()
      callback(result)
    end)
  end)
end

return M
