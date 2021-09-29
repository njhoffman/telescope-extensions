local pickersMap = require("pickers")

for i, telescopeItem in pairs(pickersMap) do
  local visible = type(telescopeItem.visible) == "boolean" and telescopeItem.visible
  if type(telescopeItem.visible) == "function" then visible = telescopeItem.visible() end

  if visible == true then
    local title = type(telescopeItem.title) == "string" and telescopeItem.title
    if type(telescopeItem.title) == "function" then title = telescopeItem.title() end
    print(i, title);
  end
end
