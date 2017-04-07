-- @description Toggle open items inline editors
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

local items = r.CountSelectedMediaItems()
if items == 0 then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 0, items-1 do

  local item = r.GetSelectedMediaItem(0,i)
  if not item then goto cnt end

  local take = r.GetActiveTake(item)
  if not take then goto cnt end
  
  if not r.TakeIsMIDI(take) then goto cnt end
  
  SaveSelItems()
  r.Main_OnCommand(40289,0) -- Unselect all items
  r.SetMediaItemSelected(item,1)
  
  local inline = r.BR_IsMidiOpenInInlineEditor(take)
  if not inline then
    r.Main_OnCommand(40847,0) --Item: Open item inline editors
  else
    r.Main_OnCommand(41887,0) --Item: Close item inline editors
  end

  RestoreSelItems()

  ::cnt::
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Toggle open items inline editors', 2)
