-- @description Send track under mouse to selected tracks
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

mouse_tr = r.BR_TrackAtMouseCursor()
if mouse_tr then
  sel_tracks = r.CountSelectedTracks(0)
  if sel_tracks > 0 then
    r.Undo_BeginBlock()

    for i = 0, sel_tracks-1 do
      tr = r.GetSelectedTrack(0,i); r.SNM_AddReceive(mouse_tr, tr, -1)
    end

    r.Undo_EndBlock('Send track under mouse to sel tracks', -1)
  else bla() end
else bla() end
