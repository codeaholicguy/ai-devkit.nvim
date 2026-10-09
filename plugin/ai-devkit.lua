if vim.g.loaded_ai_devkit_nvim == 1 then
  return
end
vim.g.loaded_ai_devkit_nvim = 1

local ai_devkit = require("ai-devkit")

vim.api.nvim_create_user_command("AIDevKitAgents", function()
  ai_devkit.show_agents()
end, { desc = "List AI DevKit agents and show details for the selected agent" })

vim.api.nvim_create_user_command("AIDevKitSelectAgent", function()
  ai_devkit.select_agent()
end, { desc = "Select an active AI DevKit agent" })

vim.api.nvim_create_user_command("AIDevKitSend", function()
  ai_devkit.send_message()
end, { desc = "Send a prompted message to an AI DevKit agent" })

vim.api.nvim_create_user_command("AIDevKitSendSelection", function(opts)
  ai_devkit.send_selection(opts)
end, {
  desc = "Send a prompt plus selected lines to an AI DevKit agent",
  range = true,
})
