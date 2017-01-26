-- @description Set name of track at mouse to selected tracks
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end
mouse_tr = r.BR_TrackAtMouseCursor()
if mouse_tr then
  sel_tracks = r.CountSelectedTracks(0)
  if sel_tracks > 0 then
    r.Undo_BeginBlock(); r.PreventUIRefresh(1)
    _, mouse_tr_name = r.GetSetMediaTrackInfo_String(mouse_tr, 'P_NAME', '', 0)
    for i = 0, sel_tracks-1 do
      tr = r.GetSelectedTrack(0,i)
      r.GetSetMediaTrackInfo_String(tr, 'P_NAME',  mouse_tr_name, 1)
    end
    r.PreventUIRefresh(-1); r.Undo_EndBlock('set name of track at mouse to sel tracks', -1)
  else bla() end
else bla() end
