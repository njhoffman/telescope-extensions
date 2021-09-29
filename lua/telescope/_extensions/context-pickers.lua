local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

local finder = finders.new_table {
  results = { { "red", "#ff0000" }, { "green", "#00ff00" }, { "blue", "#0000ff" } },
  entry_maker = function(entry) return { value = entry, display = entry[1], ordinal = entry[1] } end,
}

local colors = function(opts)
  pickers.new(opts, {
    prompt_title = "colors",
    -- finder = finders.new_table { results = { "red", "green", "blue" } },
    finder = finder,
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        -- print(vim.inspect(selection))
        vim.api.nvim_put({ selection[1] }, "", false, true)
      end)
      return true
    end,
  }):find()
end

colors()
-- colors(require("telescope.themes").get_dropdown{})

-- actions holds all actions that can be mapped by a user and we need it to access the default action so we can replace it. Also see :help telescope.actions
-- action_state gives us a few utility functions we can use to get the current picker, current selection or current line. Also see :help telescope.actions.state
-- In this new function we first close the picker with actions.close and then get the selection with action_state. It's important to notice that you can still get the selection and current prompt input (action_state.get_current_line()) with action_state even after the picker is closed.

-- entry_maker is a function that will receive each table and then we can set the values we need. It's best practice to have a value reference to the original entry, that way we will always have access to the complete table in our action.
-- With the new snippet we no longer have an array of strings but an array of tables. Each table has a color name and the color's hex value.
-- The display key is required and is either a string or a function(tbl), where tbl is the table returned by entry_maker. So in this example tbl would give our display function access to value and ordinal.
-- If our picker will have a lot lot of values it's suggested to use a function for display especially if you are modifying the text to display. This way the function will only be executed for the entries being displayed. For an examples of an entry maker take a look at lua/telescope/make_entry.lua.
-- A good way to make your display more like a table is to use a displayer which can be found in lua/telescope/entry_display.lua. A simpler example of displayer is the function gen_from_git_commits in make_entry.lua.
-- The ordinal is also required, which is used for sorting. As already mentioned this allows us to have different display and sorting values. This allows display to be more complex with icons and special indicators but ordinal could be a simpler sorting key.
-- There are other important keys which can be set but do not make sense in the current context as we are not dealing wiht files:
-- path: to set the absolute path of the file to make sure its always found
-- lnum: to specify a line number in the file. This will allow the conf.grep_previewer to show that line and the default action to jump to that line.

-- Previewer
-- We will not write a previewer for this picker because it isn't required for basic colors and is a more advanced topic. It's already well documented in :help telescope.previewers so you can read this section if you want to write your own previewer. If you want a file previewer without columns you should default to conf.file_previewer or conf.grep_previewer.

-- Oneshot Job
-- The oneshot_job finder can be used to have an asynchronous external process which will find results and call entry_maker for each entry. An example usage would be find.
-- finder = finders.new_oneshot_job { "find", opts },
