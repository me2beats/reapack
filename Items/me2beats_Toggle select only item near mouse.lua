-- @description Toggle select only item near mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local window, segment, details = r.BR_GetMouseCursorContext()
local mouse = r.BR_GetMouseCursorContext_Position()
if not mouse then bla() return end

local mouse_tr = r.BR_TrackAtMouseCursor()
if not mouse_tr then bla() return end

local items = r.CountTrackMediaItems(mouse_tr)

local min_d = math.huge

local item_c

for i = 0, items - 1 do
  local item = r.GetTrackMediaItem(mouse_tr,i)
  local it_x = r.GetMediaItemInfo_Value(item, 'D_POSITION')
  local it_y = r.GetMediaItemInfo_Value(item, 'D_LENGTH')+it_x
  
  
  if it_x < mouse and it_y > mouse then
    item_c = item
    break
  else
    local min = math.min(math.abs(it_x-mouse),math.abs(it_y-mouse))
    if min_d > min then
      min_d = min
      item_c = item
    end
  end
end

if not item_c then bla() return end
r.Undo_BeginBlock() r.PreventUIRefresh(1)

local sel = r.IsMediaItemSelected(item_c)
if r.CountSelectedMediaItems() > 0 then
  r.Main_OnCommand(40289,0) -- Item: Unselect all items
end

r.SetMediaItemSelected(item_c,not sel)
r.UpdateItemInProject(item_c)

r.PreventUIRefresh(-1) r.Undo_EndBlock('Toggle select only item near mouse', -1)

