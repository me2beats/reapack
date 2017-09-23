-- @description Go to measure 8
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

--------------user area-----------------------------
local msr = 8
local moveview = 0 -- set 1 if you want to move view
----------------------------------------------------

local r = reaper

local time = r.TimeMap_GetMeasureInfo(0, msr)

local play_st = r.GetPlayState()
if (play_st == 0 or play_st == 2) and r.GetCursorPosition() == time then return end

r.Undo_BeginBlock()
r.SetEditCurPos2(0, time, moveview, 1)
r.Undo_EndBlock('Go to measure'..' '..msr, 2)
