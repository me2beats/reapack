-- @description Select all tracks but children
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

r = reaper

r.Undo_BeginBlock()

r.PreventUIRefresh(-1)
for i = 0, r.CountTracks()-1 do
  tr = r.GetTrack(0,i)
  if r.GetTrackDepth(tr) == 0 then
    if r.GetMediaTrackInfo_Value(tr, 'B_SHOWINTCP') == 1 then
      r.SetTrackSelected(tr,1)
    else r.SetTrackSelected(tr,0) end
  else r.SetTrackSelected(tr,0) end
end
r.PreventUIRefresh(1)

r.Undo_EndBlock('select all tracks but children', -1)
