-- @description Save selected tracks
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

sel_tracks_str = ''
for i = 0, r.CountSelectedTracks()-1 do
  sel_tracks_str = sel_tracks_str..r.GetTrackGUID(r.GetSelectedTrack(0,i))
end

r.DeleteExtState('me2beats_save-restore', 'sel_tracks', 0)
r.SetExtState('me2beats_save-restore', 'sel_tracks', sel_tracks_str, 0)
