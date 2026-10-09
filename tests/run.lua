package.path = table.concat({
  "./lua/?.lua",
  "./lua/?/init.lua",
  "./tests/?.lua",
  package.path,
}, ";")

local total = 0
local failed = 0

local function eq(expected, actual, label)
  total = total + 1
  if expected ~= actual then
    failed = failed + 1
    io.stderr:write(("not ok %d - %s\nexpected: %s\nactual:   %s\n"):format(total, label, vim.inspect(expected), vim.inspect(actual)))
  else
    io.stdout:write(("ok %d - %s\n"):format(total, label))
  end
end

vim = vim or {}
vim.inspect = vim.inspect or function(value)
  if type(value) ~= "table" then
    return tostring(value)
  end

  local parts = {}
  for key, item in pairs(value) do
    parts[#parts + 1] = tostring(key) .. "=" .. tostring(item)
  end
  return "{" .. table.concat(parts, ",") .. "}"
end

local messages = require("ai-devkit.messages")
local cli = require("ai-devkit.cli")

eq(
  "User request:\nReview this selection.\n\nContext:\nFile: /tmp/example.lua\nLines: 3-5\nFiletype: lua\n\nlocal x = 1\nprint(x)",
  messages.with_selection({
    prompt = "Review this selection.",
    path = "/tmp/example.lua",
    start_line = 3,
    end_line = 5,
    filetype = "lua",
    text = "local x = 1\nprint(x)",
  }),
  "formats prompted selection context"
)

eq(true, messages.is_blank(" \t\n"), "detects blank prompts")

local send = cli.send_command({ executable = "ai-devkit" }, "agent-one", "hello")
eq("ai-devkit", send.cmd, "uses configured executable")
eq("agent send --id agent-one --stdin", table.concat(send.args, " "), "builds stdin send command")
eq("hello", send.stdin, "passes message through stdin")

if failed > 0 then
  io.stderr:write(("%d/%d tests failed\n"):format(failed, total))
  os.exit(1)
end

io.stdout:write(("%d tests passed\n"):format(total))
