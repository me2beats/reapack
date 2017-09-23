-- @description Go to measure
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

local retval, msr = r.GetUserInputs("Go to measure", 1, "Go to measure:", "")
if not retval then return end
msr = tonumber(msr)
if not msr or msr < 0 then return end

msr = math.floor(msr+.5)

local time = r.TimeMap_GetMeasureInfo(0, msr)

local play_st = r.GetPlayState()
if (play_st == 0 or play_st == 2) and r.GetCursorPosition() == time then return end

r.Undo_BeginBlock()
r.SetEditCurPos2(0, time, 0, 1)
r.Undo_EndBlock('Go to measure'..' '..msr, 2)
