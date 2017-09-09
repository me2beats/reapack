-- @description Move cursor to start of loop
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper
r.Undo_BeginBlock()
local x_l = r.GetSet_LoopTimeRange(0, 1, 0, 0, 0)
r.SetEditCurPos2(0, x_l, 0, 0)
r.Undo_EndBlock('Move cursor to start of loop', 2)
