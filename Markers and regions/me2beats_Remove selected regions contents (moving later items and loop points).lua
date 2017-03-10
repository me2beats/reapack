-- @description Remove selected regions contents (moving later items and loop points)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function regions_in_area_return_extreme_points_only(x,y,regions)
  --N: regions
  local min, max = math.huge, 0

  for i = 0, regions-1 do
    local _, _, x_r, y_r = r.EnumProjectMarkers(i)
    if x_r < y and y_r > x then max = math.max(max,y_r) end
    if y_r > x and x_r < y then min = math.min(min,x_r) end
  end
  return min, max
end

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


local _, _, regions = r.CountProjectMarkers()
if regions == 0 then bla() return end

x,y = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
x_l,y_l = r.GetSet_LoopTimeRange(0, 1, 0, 0, 0)

min,max = regions_in_area_return_extreme_points_only(x,y,regions)
if max == 0 then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

SaveSelTracks()
r.Main_OnCommand(40296,0) -- select all tracks
r.GetSet_LoopTimeRange(1, 0, min,max, 0)
r.Main_OnCommand(40201,0) -- Remove contents of time selection (moving later items)

r.GetSet_LoopTimeRange(1, 0, x,y, 0)

if y_l < min then
elseif x_l >= max then r.GetSet_LoopTimeRange(1, 1, x_l-(max-min),y_l-(max-min), 0)
elseif y_l > min then r.GetSet_LoopTimeRange(1, 1, x_l,y_l-(max-min), 0) end

RestoreSelTracks()

r.PreventUIRefresh(-1) r.Undo_EndBlock('Remove selected regions contents', -1)
