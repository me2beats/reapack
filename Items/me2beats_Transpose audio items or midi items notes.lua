-- @description Transpose audio items or midi items notes
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing()
end

items = reaper.CountSelectedMediaItems(0)
if items > 0 then
  retval, transpose = reaper.GetUserInputs("Transpose", 1, "Transpose, semitones:", "")
  if retval == true then 
  
    script_title = 'transpose audio items or midi items notes'
    reaper.Undo_BeginBlock()
    
    for i = 0, items-1 do
      it = reaper.GetSelectedMediaItem(0, i)
      takes = reaper.CountTakes(it)
      for t = 0, takes-1 do
        take = reaper.GetTake(it, t)
        midi = reaper.TakeIsMIDI(take)
        if midi == true then
          _, notes = reaper.MIDI_CountEvts(take)
          for n = 0, notes-1 do
            retval, sel, muted, startppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote(take, n)
            reaper.MIDI_SetNote(take, n, sel, muted, startppq, endppq, chan, pitch + transpose, vel)
          end
        else
          t_pitch = reaper.GetMediaItemTakeInfo_Value(take, 'D_PITCH')
          reaper.SetMediaItemTakeInfo_Value(take, 'D_PITCH', t_pitch + transpose)
        end
      end
      reaper.UpdateItemInProject(it)
    end

    reaper.Undo_EndBlock(script_title, -1)
  else
    reaper.defer(nothing)
  end
else
  reaper.defer(nothing)
end
