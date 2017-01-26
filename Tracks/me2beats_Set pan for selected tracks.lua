-- @description Set pan for selected tracks
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end; function bla() reaper.defer(nothing) end
retval, pan = reaper.GetUserInputs("Pan", 1, "Set track pan, percents:", "")
if retval == true then
  pan = tonumber(pan)
  if pan >=-100 and pan <=100 then
    reaper.Undo_BeginBlock()
    for i = 0, reaper.CountSelectedTracks(0)-1 do
      tr = reaper.GetSelectedTrack(0,i)
      reaper.SetMediaTrackInfo_Value(tr, 'D_PAN', 0.01*pan)
    end
    reaper.Undo_EndBlock('Set pan for selected tracks', -1)
  else bla() end
else bla() end
