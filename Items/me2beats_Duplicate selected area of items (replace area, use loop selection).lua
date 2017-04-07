-- @description Duplicate selected area of items (replace area, use loop selection)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local function SaveSelItems()
  sel_items = {}
  for i = 0, r.CountSelectedMediaItems(0)-1 do
    sel_items[i+1] = r.BR_GetMediaItemGUID(r.GetSelectedMediaItem(0, i))
  end
end

local function RestoreSelItems()
  r.Main_OnCommand(40289,0) -- Unselect all items
  for _, guid in ipairs(sel_items) do
    local item = r.BR_GetMediaItemByGUID(0, guid)
    if item then r.SetMediaItemSelected(item, 1) end
  end
end


local function SaveSelTracks()
  sel_tracks = {}
  for i = 0, r.CountSelectedTracks(0)-1 do
    sel_tracks[i+1] = r.GetSelectedTrack(0, i)
  end
end

local function RestoreSelTracks()
  r.Main_OnCommand(40297,0) -- Unselect all tracks
  for _, track in ipairs(sel_tracks) do
    r.SetTrackSelected(track, 1)
  end
end

function select_selected_items_tracks()
  local t = {}
  for i = 0, r.CountSelectedMediaItems()-1 do
    local item = r.GetSelectedMediaItem(0,i)
    local tr = r.GetMediaItem_Track(item)
    if not t[tr] then t[tr] = true r.SetTrackSelected(tr,1) end
  end
end

local x_l, y_l = r.GetSet_LoopTimeRange(0, 1, 0, 0, 0)
if x_l == y_l then bla() return end

local x_t, y_t = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)

local cur = r.GetCursorPosition()



local items = r.CountSelectedMediaItems()
if items ==0 then bla() return end

for i = 0, items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  local item_start = r.GetMediaItemInfo_Value(item, 'D_POSITION')
  local len = r.GetMediaItemInfo_Value(item, 'D_LENGTH')
  local item_end = item_start+len
  if item_start < y_l and item_end > x_l then found = 1 break end
end

if not found then bla() return end

r.Undo_BeginBlock()
r.PreventUIRefresh(1)

SaveSelItems()
SaveSelTracks()

r.GetSet_LoopTimeRange(1, 0, x_l, y_l, 0) -- set time selection to loop selection

r.GetSet_LoopTimeRange(1, 0, y_l, 2*y_l-x_l, 0)
r.GetSet_LoopTimeRange(1, 1, y_l, 2*y_l-x_l, 0)

r.Main_OnCommand(40297,0) -- Unselect all tracks
select_selected_items_tracks()

r.Main_OnCommand(40718,0) -- Item: Select all items on selected tracks in current time selection
r.Main_OnCommand(40307,0) -- Item: Cut selected area of items



RestoreSelItems()

r.GetSet_LoopTimeRange(1, 0, x_l, y_l, 0)
r.GetSet_LoopTimeRange(1, 1, x_l, y_l, 0)

r.Main_OnCommand(41296,0) -- Item: Duplicate selected area of items

r.SetEditCurPos2(0, cur, 0, 0)
RestoreSelTracks()

r.GetSet_LoopTimeRange(1, 1, y_l, y_l*2-x_l, 0)
r.GetSet_LoopTimeRange(1, 0, x_t, y_t, 0)

r.PreventUIRefresh(-1)
r.Undo_EndBlock('Duplicate selected area of items (replace area)', -1)
