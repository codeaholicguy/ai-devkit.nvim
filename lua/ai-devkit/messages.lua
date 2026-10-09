local M = {}

function M.is_blank(value)
  return value == nil or value:match("^%s*$") ~= nil
end

function M.with_selection(ctx)
  return table.concat({
    "User request:",
    ctx.prompt,
    "",
    "Context:",
    "File: " .. ctx.path,
    ("Lines: %d-%d"):format(ctx.start_line, ctx.end_line),
    "Filetype: " .. (ctx.filetype or ""),
    "",
    ctx.text,
  }, "\n")
end

return M
