-- @description Move cursor to nearest grid division
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

pos = reaper.GetCursorPosition()
newpos = reaper.BR_GetClosestGridDivision(pos)
reaper.SetEditCurPos(newpos, false, false)