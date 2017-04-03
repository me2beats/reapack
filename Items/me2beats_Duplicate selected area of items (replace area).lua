-- @description Duplicate selected area of items (replace area)
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

local x, y = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
if x == y then bla() return end

if not r.GetSelectedMediaItem(0,0) then bla() return end

local cur = r.GetCursorPosition()

r.Undo_BeginBlock()
r.PreventUIRefresh(1)

SaveSelItems()
SaveSelTracks()

r.GetSet_LoopTimeRange(1, 0, y, 2*y-x, 0)

r.Main_OnCommand(40297,0) -- Unselect all tracks
select_selected_items_tracks()

r.Main_OnCommand(40718,0) -- Item: Select all items on selected tracks in current time selection
r.Main_OnCommand(40307,0) -- Item: Cut selected area of items

RestoreSelItems()

r.GetSet_LoopTimeRange(1, 0, x, y, 0)

r.Main_OnCommand(41296,0) -- Item: Duplicate selected area of items

r.SetEditCurPos2(0, cur, 0, 0)
RestoreSelTracks()

r.PreventUIRefresh(-1)
r.Undo_EndBlock('Duplicate selected area of items (replace area)', -1)
