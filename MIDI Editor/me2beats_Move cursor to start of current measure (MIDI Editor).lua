-- @description Move cursor to start of current measure (MIDI Editor)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

local _, msr = r.TimeMap2_timeToBeats(0, r.GetCursorPosition())
local msr_start = r.TimeMap_GetMeasureInfo(0, msr)

r.Undo_BeginBlock()
r.SetEditCurPos2(0, msr_start, 0, 0)
r.Undo_EndBlock('Move cursor to start of current measure', 2)
