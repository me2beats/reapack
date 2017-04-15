-- @description Select only chord under mouse
-- @version 1.1
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then bla() return end

_,notes = r.MIDI_CountEvts(take)
if notes == 0 then bla() return end

window, segment, details = r.BR_GetMouseCursorContext()
_, noteRow = r.BR_GetMouseCursorContext_MIDI()

if noteRow == -1 then bla() return end

r.Undo_BeginBlock(); r.PreventUIRefresh(111)

mouse_time = r.BR_GetMouseCursorContext_Position()
mouse_ppq_pos = r.MIDI_GetPPQPosFromProjTime(take, mouse_time)

for i = 0, notes - 1 do
  _, sel, muted, start_note, end_note, chan, pitch, vel = r.MIDI_GetNote(take, i)
  if start_note < mouse_ppq_pos and end_note > mouse_ppq_pos then
    r.MIDI_SetNote(take, i, 1, muted, start_note, end_note, chan, pitch, vel)
  else r.MIDI_SetNote(take, i, 0, muted, start_note, end_note, chan, pitch, vel) end
end

r.PreventUIRefresh(-111); r.Undo_EndBlock('select chord under mouse', 0)
