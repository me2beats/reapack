-- @description Show selected track receives fx windows
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing()
end

sel_t_cnt = reaper.CountSelectedTracks(0)
if sel_t_cnt > 0 then
  t = reaper.GetSelectedTrack(0, 0)
  t_send_cnt = reaper.GetTrackNumSends(t, -1)
  if t_send_cnt > 0 then
  
    script_title = "show selected track receives fx window"
    reaper.Undo_BeginBlock()
    
    for x = 0, t_send_cnt-1 do
      t_send = reaper.BR_GetMediaTrackSendInfo_Track(t, -1, x, 0) -- get x recieve of sel track
      reaper.TrackFX_Show(t_send, 0, 1)
    end
    
    reaper.Undo_EndBlock(script_title, -1)
    
  else
    reaper.defer(nothing)
  end
else
  reaper.defer(nothing)
end
