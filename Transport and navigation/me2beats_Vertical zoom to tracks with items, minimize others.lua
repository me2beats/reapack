-- @description Vertical zoom to tracks with items, minimize others
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
  for i = 0, r.CountSelectedTracks(0)-1 do
    sel_tracks[i+1] = r.GetSelectedTrack(0, i)
  end
end

local function RestoreSelTracks()
  UnselectAllTracks()
  for _, track in ipairs(sel_tracks) do
    r.SetTrackSelected(track, 1)
  end
end

SaveSelTracks()

r.Undo_BeginBlock(); r.PreventUIRefresh(1)
UnselectAllTracks()

for i = 0, r.CountTracks()-1 do
  tr = r.GetTrack(0,i)
  if r.CountTrackMediaItems(tr) > 0 then r.SetTrackSelected(tr,1) end
end

r.Main_OnCommand(r.NamedCommandLookup('_SWS_VZOOMFITMIN'),0)

RestoreSelTracks()

r.PreventUIRefresh(-1) r.Undo_EndBlock('Vertical zoom to tracks with items', -1)



