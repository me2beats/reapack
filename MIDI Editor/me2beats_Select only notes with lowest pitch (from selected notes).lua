-- @description Select only notes with lowest pitch (from selected notes)
-- @version 1.11
-- @author me2beats
-- @changelog
--  + smth

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then return end

local notes = r.MIDI_CountEvts(take)
if notes == 0 then bla() return end

local min_pitch = 128

for i = 0, notes - 1 do
  local _, sel, _, _, _, _, pitch = r.MIDI_GetNote(take, i)
  if sel then 
    min_pitch = math.min(min_pitch,pitch)
  end
end

if min_pitch == 128 then bla() return end

local notes_tb = {}

for i = 0, notes - 1 do
  local _, sel, muted, start_note, end_note, chan, pitch, vel = r.MIDI_GetNote(take, i)
  if sel and min_pitch == pitch then 
    notes_tb[#notes_tb+1] = i
  end
end

r.Undo_BeginBlock(); r.PreventUIRefresh(1)

r.MIDIEditor_LastFocused_OnCommand(40214, 0) -- unselect all notes

for i = 1, #notes_tb do
  r.MIDI_SetNote(take, notes_tb[i], 1, nil,nil,nil,nil,nil,nil)
end

r.PreventUIRefresh(-1); r.Undo_EndBlock('Select notes with lowest pitch', -1)