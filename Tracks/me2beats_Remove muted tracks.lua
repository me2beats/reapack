-- @description Remove muted tracks
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

r = reaper

r.Undo_BeginBlock()

r.PreventUIRefresh(-1)
for i = 0, r.CountTracks()-1 do
  tr = r.GetTrack(0,i)
  if r.GetMediaTrackInfo_Value(tr, 'B_MUTE') == 1 then
    if r.GetMediaTrackInfo_Value(tr, 'B_SHOWINTCP') == 1 then
      r.SetTrackSelected(tr,1)
    else r.SetTrackSelected(tr,0) end
  else r.SetTrackSelected(tr,0) end
end

r.Main_OnCommand(40005,0) -- remove tracks

r.PreventUIRefresh(1)

r.Undo_EndBlock('remove muted tracks', -1)
