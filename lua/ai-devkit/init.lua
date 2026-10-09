local cli = require("ai-devkit.cli")
local config = require("ai-devkit.config")
local messages = require("ai-devkit.messages")

local M = {
  selected_agent = nil,
}

local function notify(message, level)
  if config.options.notify then
    vim.notify(message, level or vim.log.levels.INFO, { title = "AIDevKit" })
  end
end

local function command_config()
  return { command = config.options.command }
end

local function decode_json(text)
  local ok, decoded = pcall(vim.json.decode, text)
  if ok then
    return decoded
  end
  return nil
end

local function normalize_agents(payload)
  if vim.tbl_islist(payload) then
    return payload
  end

  if type(payload) == "table" and type(payload.agents) == "table" and vim.tbl_islist(payload.agents) then
    return payload.agents
  end

  return {}
end

local function agent_label(agent)
  local parts = { agent.name or agent.id or "<unnamed>" }
  if agent.status then
    parts[#parts + 1] = "(" .. agent.status .. ")"
  end
  if agent.projectPath then
    parts[#parts + 1] = agent.projectPath
  end
  return table.concat(parts, " ")
end

local function require_prompt(callback)
  vim.ui.input({ prompt = "Message to agent: " }, function(input)
    if messages.is_blank(input) then
      notify("Message is required", vim.log.levels.WARN)
      return
    end
    callback(input)
  end)
end

function M.setup(opts)
  config.setup(opts)
end

function M.list_agents(callback)
  cli.run(cli.list_command(command_config()), function(result)
    if result.code ~= 0 then
      notify("Failed to list agents: " .. (result.stderr or ""), vim.log.levels.ERROR)
      return
    end

    callback(normalize_agents(decode_json(result.stdout) or {}))
  end)
end

function M.select_agent(callback)
  M.list_agents(function(agents)
    if #agents == 0 then
      notify("No active agents found", vim.log.levels.WARN)
      return
    end

    vim.ui.select(agents, {
      prompt = "Select AI DevKit agent",
      format_item = agent_label,
    }, function(agent)
      if not agent then
        return
      end

      M.selected_agent = agent.name or agent.id
      notify("Selected " .. M.selected_agent)
      if callback then
        callback(M.selected_agent, agent)
      end
    end)
  end)
end

local function with_agent(callback)
  if M.selected_agent then
    callback(M.selected_agent)
    return
  end

  M.select_agent(function(id)
    callback(id)
  end)
end

function M.show_agents()
  M.select_agent(function(id)
    cli.run(cli.detail_command(command_config(), id, config.options.detail_tail), function(result)
      if result.code ~= 0 then
        notify("Failed to load agent detail: " .. (result.stderr or ""), vim.log.levels.ERROR)
        return
      end

      local lines = vim.split(vim.trim(result.stdout), "\n", { plain = true })
      vim.cmd("botright new")
      vim.bo.buftype = "nofile"
      vim.bo.bufhidden = "wipe"
      vim.bo.swapfile = false
      vim.bo.filetype = "json"
      vim.api.nvim_buf_set_name(0, "AIDevKit Agent: " .. id)
      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    end)
  end)
end

function M.send_message()
  with_agent(function(id)
    require_prompt(function(prompt)
      cli.run(cli.send_command(command_config(), id, prompt), function(result)
        if result.code ~= 0 then
          notify("Failed to send message: " .. (result.stderr or ""), vim.log.levels.ERROR)
          return
        end

        notify("Sent to " .. id)
      end)
    end)
  end)
end

function M.send_selection(opts)
  if opts.range == 0 then
    notify("Select lines before running AIDevKitSendSelection", vim.log.levels.WARN)
    return
  end

  local start_line = opts.line1
  local end_line = opts.line2
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local text = table.concat(lines, "\n")
  local path = vim.api.nvim_buf_get_name(0)

  with_agent(function(id)
    require_prompt(function(prompt)
      local message = messages.with_selection({
        prompt = prompt,
        path = path ~= "" and path or "[No Name]",
        start_line = start_line,
        end_line = end_line,
        filetype = vim.bo.filetype,
        text = text,
      })

      cli.run(cli.send_command(command_config(), id, message), function(result)
        if result.code ~= 0 then
          notify("Failed to send selection: " .. (result.stderr or ""), vim.log.levels.ERROR)
          return
        end

        notify(("Sent lines %d-%d to %s"):format(start_line, end_line, id))
      end)
    end)
  end)
end

return M
