local M = {}
local fnamemodify = _G.vim and _G.vim.fn.fnamemodify or function(name) return name end

function M.inspect(tbl, depth, n)
  n = n or 2;
  depth = depth or 5;

  if (depth == 0) then
    print(string.rep(" ", n) .. "...");
    return;
  end

  if (n == 0) then print(" "); end

  for key, value in pairs(tbl) do
    if (key and type(key) == "number" or type(key) == "string") then
      key = string.format("[\"%s\"]", key);

      if (type(value) == "table") then
        if (next(value)) then
          print(string.rep(" ", n) .. key .. " = {");
          M.inspect(value, depth - 1, n + 4);
          print(string.rep(" ", n) .. "},");
        else
          print(string.rep(" ", n) .. key .. " = {},");
        end
      else
        if (type(value) == "string") then
          value = string.format("\"%s\"", value);
        else
          value = tostring(value);
        end

        print(string.rep(" ", n) .. key .. " = " .. value .. ",");
      end
    end
  end

  if (n == 0) then print(" "); end
end

function M.is_plugin_installed(check_plugin_name)
  if type(_G.vim) == "nil" then return true end
  local _, packer = pcall(require, "packer")
  if type(packer) == "string" then
    -- packer is not installed
    return false
  end

  local plugin_utils = require("packer.plugin_utils")
  local opt_plugins, start_plugins = plugin_utils.list_installed_plugins()

  for _, plugin_list in ipairs({ opt_plugins, start_plugins }) do
    for plugin_path, _ in pairs(plugin_list) do
      local plugin_name = fnamemodify(plugin_path, ":t")
      if (check_plugin_name == plugin_name) then return true end
    end
  end
  return false
end

return M
