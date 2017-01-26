-- @description Delete all notes in time selection
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local x_ts, y_ts = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
if x_ts and y_ts and x_ts ~= y_ts then
  local editor = r.MIDIEditor_GetActive()
  local take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
  if take then
    local _, notes = r.MIDI_CountEvts(take)
    if notes > 0 then
      x_ts = r.MIDI_GetPPQPosFromProjTime(take, x_ts)
      y_ts = r.MIDI_GetPPQPosFromProjTime(take, y_ts)
      r.Undo_BeginBlock(); r.PreventUIRefresh(111)
      for n = notes-1, 0, -1 do
        local _, _, _, x, y = r.MIDI_GetNote(take, n)
        if (x < y_ts and x > x_ts) or (y > x_ts and y < y_ts) or (x <= x_ts and y >= y_ts) then
          r.MIDI_DeleteNote(take, n)
        end
      end
      r.PreventUIRefresh(-111); r.Undo_EndBlock("delete all notes in time selection", -1)
    else bla() end
  else bla() end
else bla() end
