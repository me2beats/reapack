-- @description Duplicate region at mouse (with items, insert time)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local function UnselectAllTracks()
  local first_track = r.GetTrack(0, 0)
  r.SetOnlyTrackSelected(first_track)
  r.SetTrackSelected(first_track, 0)
end

local function SaveSelTracks()
  sel_tracks = {}
  for i = 0, r.CountSelectedTracks()-1 do
    sel_tracks[i+1] = r.GetSelectedTrack(0, i)
  end
end

local function RestoreSelTracks()
  UnselectAllTracks()
  for _, track in ipairs(sel_tracks) do
    r.SetTrackSelected(track, 1)
  end
end

function UnselectAllItems()
  for  i = 0, r.CountMediaItems()-1 do
    r.SetMediaItemSelected(r.GetMediaItem(0, i), 0)
  end
end

local function SaveSelItems()
  sel_items = {}
  for i = 0, r.CountSelectedMediaItems()-1 do
    sel_items[i+1] = r.GetSelectedMediaItem(0, i)
  end
end

local function RestoreSelItems()
  UnselectAllItems() -- Unselect all items
  for _, item in ipairs(sel_items) do
    if item then r.SetMediaItemSelected(item, 1) end
  end
end


x,y = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)

local _, segment = r.BR_GetMouseCursorContext()
mouse = r.BR_GetMouseCursorContext_Position()

local _, regionidx = r.GetLastMarkerAndCurRegion(0, mouse)
if regionidx == -1 then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

local _, _, x_r, y_r, name, num, color = r.EnumProjectMarkers3(0, regionidx)

SaveSelTracks() SaveSelItems()

r.GetSet_LoopTimeRange(1, 0, y_r, 2*y_r-x_r, 0)

r.Main_OnCommand(40200,0) -- insert empty space at time selection (moving later items)

r.GetSet_LoopTimeRange(1, 0, x_r, y_r, 0)

r.AddProjectMarker2(0, 1, y_r, 2*y_r-x_r, name, -1, color)

r.Main_OnCommand(40296,0) -- select all tracks
r.Main_OnCommand(40182,0) -- select all items

r.Main_OnCommand(41296,0) -- item: Duplicate selected area of items

r.GetSet_LoopTimeRange(1, 0, x, y, 0)

RestoreSelItems() RestoreSelTracks()
--]]
r.PreventUIRefresh(-1) r.Undo_EndBlock('Duplicate region at mouse', -1)


