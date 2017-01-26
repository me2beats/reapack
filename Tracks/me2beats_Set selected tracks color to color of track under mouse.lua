-- @description Set selected tracks color to color of track under mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

sel_tr_count = reaper.CountSelectedTracks(0)
if sel_tr_count ~= nil then
  window, segment, details = reaper.BR_GetMouseCursorContext()
  if segment == "track" then
    source_tr = reaper.BR_GetMouseCursorContext_Track()
	tr_color = reaper.GetMediaTrackInfo_Value(source_tr, "I_CUSTOMCOLOR")
    for i = 1, sel_tr_count do
      tr = reaper.GetSelectedTrack(0, i-1)
      if tr ~= nil then
        reaper.SetMediaTrackInfo_Value(tr, "I_CUSTOMCOLOR", tr_color)
      end
	end
  end
end