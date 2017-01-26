-- @description Set selected tracks name to name of track under mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

sel_tr_count = reaper.CountSelectedTracks(0)
if sel_tr_count ~= nil then
  window, segment, details = reaper.BR_GetMouseCursorContext()
  if segment == "track" then
    source_tr = reaper.BR_GetMouseCursorContext_Track()
    retval, source_tr_name = reaper.GetSetMediaTrackInfo_String(source_tr, "P_NAME", "", false)
    for i = 1, sel_tr_count do
      tr = reaper.GetSelectedTrack(0, i-1)
      if tr ~= nil then
        reaper.GetSetMediaTrackInfo_String(tr, "P_NAME", source_tr_name, true)
	  end
    end
  end
end