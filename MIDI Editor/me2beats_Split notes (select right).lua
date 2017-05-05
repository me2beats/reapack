-- @description Split notes (select right)
-- @version 1.1
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then bla() return end

local _, notes = r.MIDI_CountEvts(take)
if notes == 0 then bla() return end

local cur_ppq = math.floor(r.MIDI_GetPPQPosFromProjTime(take, r.GetCursorPosition())+0.5)

r.Undo_BeginBlock() r.PreventUIRefresh(1)

local correct
if r.GetToggleCommandStateEx(32060, 40681) == 1 then
  r.MIDIEditor_LastFocused_OnCommand(40681,0)--Options: Correct overlapping notes while editing
  correct = 1
end

for i = notes-1,0,-1 do
  local _, sel, muted, start_note, end_note, chan, pitch, vel = r.MIDI_GetNote(take, i)
  if sel then
    if start_note < cur_ppq and end_note > cur_ppq then      
      r.MIDI_SetNote(take, i, 0, nil,nil,cur_ppq,nil,nil,nil)
      r.MIDI_InsertNote(take, sel, muted, cur_ppq, end_note, chan, pitch, vel, 0)
    end
  end
end

if correct then r.MIDIEditor_LastFocused_OnCommand(40681,0) end--Options: Correct overlapping notes while editing

r.PreventUIRefresh(-1) r.Undo_EndBlock('Split notes (select right)', -1)
