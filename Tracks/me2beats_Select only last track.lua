-- @description Select only last track
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

n = reaper.CountTracks(0)
if n>0 then
  script_title = "select only last track"
  reaper.Undo_BeginBlock()
  tr = reaper.GetTrack(0, n-1)
  reaper.SetOnlyTrackSelected(tr)
  reaper.Undo_EndBlock(script_title, -1)
else
  function nothing()
  end
  reaper.defer(nothing)
end
