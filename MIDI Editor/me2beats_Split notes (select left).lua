-- @description Split notes (select left)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then bla() return end

local _, notes = r.MIDI_CountEvts(take)
if notes == 0 then bla() return end

local cur_ppq = r.MIDI_GetPPQPosFromProjTime(take, r.GetCursorPosition())

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = notes-1,0,-1 do
  local _, sel, muted, start_note, end_note, chan, pitch, vel = r.MIDI_GetNote(take, i)
  if sel then
    if start_note < cur_ppq and end_note > cur_ppq then
      r.MIDI_SetNote(take, i, nil, nil,nil,cur_ppq,nil,nil,nil)
      r.MIDI_InsertNote(take, 0, muted, cur_ppq, end_note, chan, pitch, vel, 0)
    end
  end
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Split notes (select left)', -1)
