-- @description Add notes of current measure to selection
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end

take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive())
if take then
  reaper.Undo_BeginBlock(); reaper.PreventUIRefresh(111)
  _, notes = reaper.MIDI_CountEvts(take)
  t = {}
  for k = 0, notes-1 do
    _, sel, muted, startppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote(take, k)
    if sel == true then t[#t+1] = {k, muted, startppq, endppq, chan, pitch, vel} end
  end
  reaper.MIDIEditor_LastFocused_OnCommand(41140, 0) -- select all notes in measure
  for i = 1, #t do
    reaper.MIDI_SetNote(take, t[i][1], 1, t[i][2], t[i][3], t[i][4], t[i][5], t[i][6], t[i][7], 0)
  end
  reaper.PreventUIRefresh(-111); reaper.Undo_EndBlock('Add notes of current measure to selection', -1)
else reaper.defer(nothing) end
