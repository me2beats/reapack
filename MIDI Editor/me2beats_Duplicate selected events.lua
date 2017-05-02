-- @description Duplicate selected events
-- @version 1.1
-- @author me2beats
-- @changelog
--  some updates

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function SaveLoopTimesel()
  init_start_timesel, init_end_timesel = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
  init_start_loop, init_end_loop = r.GetSet_LoopTimeRange(0, 1, 0, 0, 0)
end

function RestoreLoopTimesel()
  r.GetSet_LoopTimeRange(1, 0, init_start_timesel, init_end_timesel, 0)
  r.GetSet_LoopTimeRange(1, 1, init_start_loop, init_end_loop, 0)
end

function nothing() end

take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then bla() return end

_, notes = r.MIDI_CountEvts(take)

for k = 0, notes-1 do
  _, sel = r.MIDI_GetNote(take, k); if sel then x = 1 break end
end

if x ~= 1 then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

SaveLoopTimesel()
r.MIDIEditor_LastFocused_OnCommand(40752, 0) -- set time selection to selected notes
r.MIDIEditor_LastFocused_OnCommand(40883, 0) -- duplicate events within time selection
RestoreLoopTimesel()

r.PreventUIRefresh(-1) r.Undo_EndBlock("Duplicate events", -1)
