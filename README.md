# ai-devkit.nvim

Manage and message active AI DevKit agents from Neovim.

This plugin focuses on a small, editor-native v1 workflow:

- list active agents from `ai-devkit agent list --json`
- choose and remember an agent for the current Neovim session
- send a prompted message
- send a prompted message with the current visual selection attached as context

## Requirements

- Neovim 0.10+
- `ai-devkit` on `PATH`, or `npx` for the automatic `npx ai-devkit@latest` fallback

## Installation

Use your preferred plugin manager.

```lua
{
  "Codeaholicguy/ai-devkit.nvim",
  config = function()
    require("ai-devkit").setup({
      command = "auto",
      notify = true,
    })
  end,
}
```

## Commands

| Command | Description |
| --- | --- |
| `:AIDevKitAgents` | Pick an active agent and open its detail output |
| `:AIDevKitSelectAgent` | Pick and remember an agent |
| `:AIDevKitSend` | Prompt for a message and send it to the selected agent |
| `:'<,'>AIDevKitSendSelection` | Prompt for a message and send it with the selected lines |

Selection sends include file metadata:

```text
User request:
Review this selection.

Context:
File: /absolute/path/to/file.lua
Lines: 12-34
Filetype: lua

<selected text>
```

## Configuration

```lua
require("ai-devkit").setup({
  command = "auto",
  notify = true,
  detail_tail = 20,
})
```

`command = "auto"` prefers `ai-devkit` when available and falls back to `npx ai-devkit@latest`.

You can also pin a command:

```lua
require("ai-devkit").setup({
  command = "ai-devkit",
})
```

## Development

Run the test suite with Neovim:

```sh
nvim --headless -u NONE -l tests/run.lua
```

## Notes

The plugin uses `vim.ui.select` and `vim.ui.input`, so picker plugins such as Telescope, snacks.nvim, fzf-lua, or dressing.nvim can improve the UI without becoming hard dependencies.
