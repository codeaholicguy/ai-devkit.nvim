local M = {}

M.defaults = {
  command = "auto",
  notify = true,
  detail_tail = 20,
}

M.options = vim.deepcopy and vim.deepcopy(M.defaults) or {
  command = "auto",
  notify = true,
  detail_tail = 20,
}

function M.setup(opts)
  opts = opts or {}
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts)
  return M.options
end

return M
