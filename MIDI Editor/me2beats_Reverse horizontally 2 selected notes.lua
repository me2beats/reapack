-- @description Reverse horizontally 2 selected notes
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function bool_to_num(bool)
  if bool == true then return 1 elseif bool == false then return 0 end
end

take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then bla() return end

_, notes = r.MIDI_CountEvts(take)

sel_notes = 0
for k = 0, notes-1 do
  _, sel = r.MIDI_GetNote(take, k)
  if sel == true then sel_notes = sel_notes+1 end
  if sel_notes == 3 then break end
end

if sel_notes ~= 2 then bla() return end

r.Undo_BeginBlock(); r.PreventUIRefresh(1)

for k = 0, notes-1 do
  _, sel, _, start_ppq, end_ppq = r.MIDI_GetNote(take, k)
  if sel == true then
    if not note_1 then
      note_1 = {start_ppq,end_ppq, k}
    else note_2 = {start_ppq,end_ppq, k} end
    if note_1 and note_2 then break end
  end
end

_, _, muted, _, _, chan, pitch, vel = r.MIDI_GetNote(take, note_1[3])
r.MIDI_SetNote(take, note_1[3], 1, bool_to_num(muted), note_2[1], note_2[1]+(note_1[2]-note_1[1]), chan, pitch, vel)

_, _, muted, _, _, chan, pitch, vel = r.MIDI_GetNote(take, note_2[3])
r.MIDI_SetNote(take, note_2[3], 1, bool_to_num(muted), note_1[1], note_1[1]+(note_2[2]-note_2[1]), chan, pitch, vel)
r.PreventUIRefresh(-1); r.Undo_EndBlock('reverse horizontally 2 selected notes', -1)
