local actions = require "telescope.actions"
local actions_set = require "telescope.actions.set"
local conf = require"telescope.config".values
local entry_display = require "telescope.pickers.entry_display"
local finders = require "telescope.finders"
local from_entry = require "telescope.from_entry"
local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"
local utils = require "telescope.utils"
local Path = require "plenary.path"

local os_home = vim.loop.os_homedir()

-- local function gen_from_notifications(opts)
--   local displayer = entry_display.create {
--     separator = " ",
--     items = {
--       {}, -- level
--       {}, -- time
--       {}, -- message
--     },
--   }

--   local function make_display(entry)
--     return displayer {
--       entry.level,
--       { "(" .. entry.time .. ")", "TelescopeResultsIdentifier" },
--       { entry.message and "[" .. entry.message .. "]" or "", "TelescopeResultsComment" },
--     }
--   end

--   return function(result)
--     return { display = make_display, level = result.level, title = result.title, message = result.message }
--   end
-- end

-- local function gen_from_ghq(opts)
--   local displayer = entry_display.create{
--     items = {{}},
--   }

--   local function make_display(entry)
--     local dir = (function(path)
--       if path == Path.path.root() then return path end

--       local p = Path:new(path)
--       if opts.tail_path then
--         local parts = p:_split()
--         return parts[#parts]
--       end

--       if opts.shorten_path then return p:shorten() end

--       if vim.startswith(path, opts.cwd) and path ~= opts.cwd then
--         return Path:new(p):make_relative(opts.cwd)
--       end

--       if vim.startswith(path, os_home) then
--         return (Path:new'~' / p:make_relative(os_home)).filename
--       end
--       return path
--     end)(entry.path)

--     return displayer{dir}
--   end

--   return function(line)
--     return {
--       value = line,
--       ordinal = line,
--       path = line,
--       display = make_display,
--     }
--   end
-- end

local M = {}

M.parse_time_diff = function(diff_s)
  local secs = { minute = 60, ten_minutes = 600, hour = 3600, day = 86400 }
  if (diff_s < secs.minute) then
    return diff_s .. "s"
  elseif (diff_s < secs.ten_minutes) then
    local m = math.floor(diff_s / secs.minute)
    local s = (diff_s - m * secs.minute) % secs.minute
    return m .. "m " .. s .. "s"
  elseif (diff_s < secs.hour) then
    local m = math.floor(diff_s / secs.minute)
    return m .. "m"
  elseif (diff_s < secs.day) then
    local h = math.floor(diff_s / secs.hour)
    local m = (diff_s - h * secs.hour) % secs.minute
    return h .. "h " .. m .. "m"
  else
    local d = math.floor(diff_s / secs.day)
    local h = tonumber(string.format("%.0f", (diff_s - d * secs.day) / secs.hour))
    return d .. "d " .. h .. "h"
  end
end

M.list = function(opts)
  opts = opts or {}
  local notify_history = require("notify").history()
  local results = {}
  for i = #notify_history, 1, -1 do table.insert(results, notify_history[i]) end

  if not results then return end

  local displayer = entry_display.create({
    separator = " ",
    items = { { width = 5 }, { width = 12 }, { remaining = true } },
  })

  local function make_display(entry)
    local val = entry.value
    -- Notify
    local level_hl = "Notify" .. string.upper(val.level) .. "Title"
    local message_hl = "Notify" .. string.upper(val.level) .. "Body"

    return displayer({
      { val.level, level_hl },
      { val.time and " (-" .. M.parse_time_diff(val.time) .. ")" or "--", "TelescopeResultsComment" },
      { val.message[1] and val.message[1] or "--", message_hl },
    })
  end

  return pickers.new(opts, {
    prompt_title = "Notifications",
    sorter = conf.generic_sorter(opts),
    -- previewer = previewers.cat.new(opts),
    previewer = false,
    finder = finders.new_table {
      results = results,
      entry_maker = function(entry)
        local abstime = entry.time
        entry.time = os.time() - tonumber(entry.time)
        return { display = make_display, value = entry, ordinal = abstime }
      end,
    },
  }):find()
end

return M.list
