-- @description Select only note under mouse
-- @version 1.02
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then bla() return end
local _,notes = r.MIDI_CountEvts(take)
local window, segment, details = r.BR_GetMouseCursorContext()
local _,_,noteRow = r.BR_GetMouseCursorContext_MIDI()

if noteRow == -1 then bla() return end

local mouse_time = r.BR_GetMouseCursorContext_Position()
local mouse_ppq_pos = r.MIDI_GetPPQPosFromProjTime(take, mouse_time)


r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 0, notes - 1 do
  local _, sel, muted, start_note, end_note, chan, pitch, vel = r.MIDI_GetNote(take, i)
  if start_note < mouse_ppq_pos and end_note > mouse_ppq_pos and noteRow == pitch then
    note = i
    break
  end
end

if not note then bla() return end
r.MIDIEditor_LastFocused_OnCommand(40214, 0)
r.MIDI_SetNote(take, note, 1, nil, nil, nil, nil, nil, nil)

r.PreventUIRefresh(-1) r.Undo_EndBlock('Select only note under mouse', -1)