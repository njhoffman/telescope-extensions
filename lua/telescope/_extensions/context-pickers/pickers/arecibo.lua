local util = require "util"

return {
  name = "arecibo",
  title = "Web search with arecibo",
  cmd = "Telescope arecibo websearch",
  visible = function() return util.is_plugin_installed("telescope-arecibo.nvim") end,
}
