-- @description Move cursor to start of project
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper
r.Undo_BeginBlock()
r.SetEditCurPos2(0, 0, 0, 0)
r.Undo_EndBlock('Move cursor to start of project', 2)
