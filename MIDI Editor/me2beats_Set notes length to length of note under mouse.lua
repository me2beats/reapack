-- @description Set notes length to length of note under mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then bla() return end

function mouse_note_len(notes)

  local window, segment, details = r.BR_GetMouseCursorContext()
  local _,_,noteRow = r.BR_GetMouseCursorContext_MIDI()

  if noteRow == -1 then return end

  local mouse_time = r.BR_GetMouseCursorContext_Position()
  local mouse_ppq_pos = r.MIDI_GetPPQPosFromProjTime(take, mouse_time)

  for i = 0, notes - 1 do
    local _, sel, muted, start_note, end_note, chan, pitch, vel = r.MIDI_GetNote(take, i)
    if start_note < mouse_ppq_pos and end_note > mouse_ppq_pos and noteRow == pitch then
      note_len = end_note-start_note
      break
    end
  end
  return note_len
end

local notes = r.MIDI_CountEvts(take)
if notes == 0 then bla() return end

local start_note_len = mouse_note_len(notes)
if not start_note_len then bla() return end

r.Undo_BeginBlock()

for i = 0, notes - 1 do
  local _, sel, muted, start_note, end_note, chan, pitch, vel = r.MIDI_GetNote(take, i)
  if sel then r.MIDI_SetNote(take, i, nil, nil,nil,start_note+note_len,nil,nil,nil) end
end

r.Undo_EndBlock('Set notes length to length of note under mouse', -1)
