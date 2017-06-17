-- @description Select only items on track at mouse (obey region)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function items_in_area(x,y,tracks_tb)
  local t = {}
  for i = 1, #tracks_tb do
    local tr = tracks_tb[i]
    local tr_items = r.CountTrackMediaItems(tr)
    for j = 0, tr_items-1 do
      local item = r.GetTrackMediaItem(tr, j)
      local pos0 = r.GetMediaItemInfo_Value(item, 'D_POSITION')
      local len0 = r.GetMediaItemInfo_Value(item, 'D_LENGTH')
      local end0 = pos0+len0
      if pos0 <= x and end0 >= x+0.00001 or
         pos0 <= y-0.00001 and end0 >= y or
         pos0 >= x and end0 <= y then
         t[#t+1] = item
      end
    end
  end
  return t
end

local window, segment, details = r.BR_GetMouseCursorContext()
local mouse = r.BR_GetMouseCursorContext_Position()
if not mouse then bla() return end

local _, regionidx = r.GetLastMarkerAndCurRegion(0, mouse)
if regionidx == -1 then bla() return end

local mouse_tr = r.BR_TrackAtMouseCursor()
if not mouse_tr then bla() return end


local tracks_tb = {mouse_tr}

local _, _, x, y = r.EnumProjectMarkers3(0,regionidx)

local items_tb = items_in_area(x,y,tracks_tb)
if #items_tb == 0 then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

r.SelectAllMediaItems(0, 0) -- unselect all items
for i = 1, #items_tb do r.SetMediaItemSelected(items_tb[i],1) r.UpdateItemInProject(items_tb[i]) end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Select items on track at mouse', -1)
