-- @description Set take notes to one random channel
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

function GetAndDelNotes(take)

  local t = {}

  for i = 0, 1000 do
    local ret, sel, mute, start_note, end_note, chan, pitch, vel = r.MIDI_GetNote(take, 0)
    if not ret then  break end
    t[#t+1] = {sel, mute, start_note, end_note, chan, pitch, vel}
    r.MIDI_DeleteNote(take, 0)
  end
  return t
end

local take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then return end

local _, notes = r.MIDI_CountEvts(take)
if notes == 0 then return end

r.Undo_BeginBlock(); r.PreventUIRefresh(1)

local state = r.GetToggleCommandStateEx(32060, 40681) -- check overlaps auto corection
if state == 1 then r.MIDIEditor_LastFocused_OnCommand(40681, 0) end

local t_all = GetAndDelNotes(take)

local new_chan = math.random(1,16)

for i = 1,#t_all do
  local sel, mute, start_note, end_note, chan, pitch, vel = table.unpack(t_all[i])
  r.MIDI_InsertNote(take, sel, mute, start_note, end_note, new_chan, pitch, vel, 0)
end

r.PreventUIRefresh(-1); r.Undo_EndBlock('Set notes to one random channel', -1)
