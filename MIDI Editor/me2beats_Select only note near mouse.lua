-- @description Select only note near mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then bla() return end

function mouse_note(notes)

  local window, segment, details = r.BR_GetMouseCursorContext()
  local _,_,noteRow = r.BR_GetMouseCursorContext_MIDI()

  if noteRow == -1 then return end

  local mouse_time = r.BR_GetMouseCursorContext_Position()
  local mouse_ppq_pos = r.MIDI_GetPPQPosFromProjTime(take, mouse_time)

  local min_d = math.huge

  for i = 0, notes - 1 do
    local _, sel, muted, start_note, end_note, chan, pitch, vel = r.MIDI_GetNote(take, i)
    if start_note < mouse_ppq_pos and end_note > mouse_ppq_pos and noteRow == pitch then
      iter = i
      break
    else
      local min = math.min(math.abs(start_note-mouse_ppq_pos),math.abs(end_note-mouse_ppq_pos))
      if noteRow == pitch and min_d > min then
        min_d = min
        iter = i
      end
    end
  end
  return iter
end

local notes = r.MIDI_CountEvts(take)
if notes == 0 then bla() return end

local note = mouse_note(notes)
if not note then bla() return end


r.Undo_BeginBlock() r.PreventUIRefresh(1)

r.MIDIEditor_LastFocused_OnCommand(40214, 0) -- unselect all notes

r.MIDI_SetNote(take, note, 1,nil,nil,nil,nil,nil,nil)

r.PreventUIRefresh(-1) r.Undo_EndBlock('Select only note near mouse', -1)
