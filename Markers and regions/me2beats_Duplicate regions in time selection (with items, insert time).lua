-- @description Duplicate regions in time selection (with items, insert time)
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

function regions_in_area_return_extreme_points(x,y)

  local _, _, regions = r.CountProjectMarkers()
  local min, max = math.huge, 0
  local i_min, i_max = -1, -1

  for i = 0, regions-1 do
    local _, _, x_r, y_r = r.EnumProjectMarkers(i)

    if x_r < y and y_r > x then
      if math.max(max,y_r) == y_r then max = y_r i_max = i end
    end

    if y_r > x and x_r < y then
      if math.min(min,x_r) == x_r then min = x_r i_min = i end
    end
  end
  return min, max, i_min, i_max
end

function min_max(x,y) return math.min(x,y),math.max(x,y) end


x,y = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
if x == y then bla() return end

min,max,i_min,i_max = regions_in_area_return_extreme_points(x,y)
if max == 0 then bla() return end

i_min,i_max = min_max(i_min,i_max)

t = {}
for i = i_min,i_max do
  local _, _, x_r, y_r, name, num, color = r.EnumProjectMarkers3(0, i)
  t[#t+1] = {x_r, y_r, name, color}
end

len = max-min

r.Undo_BeginBlock() r.PreventUIRefresh(1)

SaveSelTracks() SaveSelItems()

r.GetSet_LoopTimeRange(1, 0, max, 2*max-min, 0)

r.Main_OnCommand(40200,0) -- insert empty space at time selection (moving later items)

r.GetSet_LoopTimeRange(1, 0, min, max, 0)

for i = 1, #t do
  r.AddProjectMarker2(0, 1, t[i][1]+len,t[i][2]+len,t[i][3],-1,t[i][4])
end

r.Main_OnCommand(40296,0) -- select all tracks
r.Main_OnCommand(40182,0) -- select all items

r.Main_OnCommand(41296,0) -- item: Duplicate selected area of items

r.GetSet_LoopTimeRange(1, 0, x, y, 0)

RestoreSelItems() RestoreSelTracks()

r.PreventUIRefresh(-1) r.Undo_EndBlock('Duplicate regions in time selection', -1)
