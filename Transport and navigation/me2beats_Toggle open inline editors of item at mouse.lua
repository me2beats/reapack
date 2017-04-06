-- @description Toggle open inline editors of item at mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local function SaveSelItems()
  sel_items = {}
  for i = 0, r.CountSelectedMediaItems(0)-1 do
    sel_items[i+1] = r.GetSelectedMediaItem(0, i)
  end
end

local function RestoreSelItems()
  r.Main_OnCommand(40289,0) -- Unselect all items
  for _, item in ipairs(sel_items) do
    if item then r.SetMediaItemSelected(item, 1) end
  end
end

local window, segment, details = r.BR_GetMouseCursorContext()
local _, inline = r.BR_GetMouseCursorContext_MIDI()

local item = r.BR_GetMouseCursorContext_Item()
if not item then bla() return end

local take = r.GetActiveTake(item)
if not take or not r.TakeIsMIDI(take) then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)
SaveSelItems()
r.Main_OnCommand(40289,0) -- Unselect all items
r.SetMediaItemSelected(item,1)

if not inline then
  r.Main_OnCommand(40847,0) --Item: Open item inline editors
else
  r.Main_OnCommand(41887,0) --Item: Close item inline editors
end

RestoreSelItems()
r.PreventUIRefresh(-1) r.Undo_EndBlock('Toggle open item inline editors', -1)
