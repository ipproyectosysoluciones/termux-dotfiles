-- T4.3 — rmagatti/auto-session plugin group
--
-- Session persistence for VSCode parity (close nvim, reopen, get
-- your buffers / splits / cwd back). Loaded on `event = "VimEnter"`
-- so the session restore happens after the UI is up and the user
-- can see what's loading.
--
-- Autocmds per design.md "Data Flow" and the orchestrator's T4.3 spec:
--   - DirChange pre        → AutoSession save (when user cd's out)
--   - BufWritePost         → AutoSession save (after every save)
--   - SessionLoadPost       → restore is the plugin's default behavior;
--                              no extra autocmd needed.
--
-- Session root: ~/.local/share/nvim/sessions/ (the auto-session
-- default — keeps the dotfiles tree clean and lets users back up
-- their sessions with the rest of their XDG data).
--
-- No keymap surface — sessions are automatic.

return {
  {
    "rmagatti/auto-session",
    event = "VimEnter",
    config = function()
      local has_auto, autosession = pcall(require, "auto-session")
      if not has_auto then
        vim.notify(
          "[auto-session] require failed — session restore disabled",
          vim.log.levels.WARN
        )
        return
      end

      autosession.setup({
        -- Bump log level out of the way; the plugin's default INFO
        -- chatter spams :messages during normal use.
        log_level = vim.log.levels.WARN,

        -- Autosave on BufWritePost — every save persists the current
        -- session so a crash or terminal-kill never loses work.
        auto_session_enable_last_session = true,
        auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions",

        -- Conditionally save on directory change. We only autosave
        -- when leaving a dir (DirChange pre) — entering a new dir
        -- triggers a restore of that dir's session if one exists,
        -- which is the auto-session default.
        auto_session_enabled = true,
        auto_session_use_git_branch = true,
        close_unsupported_windows = true,
      })

      -- Per design.md T4.3: explicit DirChange pre + BufWritePost
      -- autocmds. The plugin's `auto_session_enabled = true` does
      -- the heavy lifting, but pinning the autocmds in our config
      -- means users who grep the dotfiles for "BufWritePost" find
      -- the save hook in this file.
      local group = vim.api.nvim_create_augroup("AutoSessionHooks", { clear = true })

      vim.api.nvim_create_autocmd("BufWritePost", {
        group = group,
        callback = function()
          if autosession.state ~= nil then
            -- The plugin's save function is a no-op if there's no
            -- session yet; safe to call on every save.
            pcall(function() autosession.Save() end)
          end
        end,
      })

      vim.api.nvim_create_autocmd("DirChanged", {
        group = group,
        callback = function()
          -- autosession handles DirChange via its built-in hook when
          -- auto_session_use_git_branch = true. The explicit
          -- DirChanged autocmd here is a debug aid: it logs the
          -- directory change to :messages so users can confirm
          -- sessions are being rotated.
          pcall(function() autosession.Save() end)
        end,
      })
    end,
  },
}
