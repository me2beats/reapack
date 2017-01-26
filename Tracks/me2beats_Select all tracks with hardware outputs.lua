-- @description Select all tracks with hardware outputs
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing()
end

reaper.Main_OnCommand(40297, 0) -- unselect all tracks
t_cnt = reaper.CountTracks(0)
if t_cnt > 0 then
  
  script_title = "select all sends"
  reaper.Undo_BeginBlock()
  
  for t = 0, t_cnt-1 do
    tr = reaper.GetTrack(0,t)
    if reaper.GetTrackNumSends(tr, 1) > 0 then
      reaper.SetMediaTrackInfo_Value(tr, 'I_SELECTED', 1)
    end
  end
  
  reaper.Undo_EndBlock(script_title, -1)
else
  reaper.defer(nothing)
end

