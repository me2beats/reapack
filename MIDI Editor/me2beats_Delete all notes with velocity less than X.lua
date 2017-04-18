-- @description Delete all notes with velocity less than X
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then bla() return end

local _, notes = r.MIDI_CountEvts(take)
if notes == 0 then bla() return end


local retval, vel_del = r.GetUserInputs("Delete notes", 1, "Delete all notes with velocity less than:", "")
if retval ~= true then bla() return end

vel_del = tonumber(vel_del)
if not vel_del or vel_del < 1 then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = notes-1, 0, -1 do
  local _,_,_,_,_,_,_, vel = r.MIDI_GetNote(take, i)
  if vel < vel_del then r.MIDI_DeleteNote(take, i) end
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Delete notes', -1)
