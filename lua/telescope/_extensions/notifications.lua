local has_telescope, telescope = pcall(require, "telescope")
local notifications = require "telescope._extensions.notifications.list"

if not has_telescope then error("This plugins requires nvim-telescope/telescope.nvim") end

return require"telescope".register_extension({ exports = { notifications = notifications } })
