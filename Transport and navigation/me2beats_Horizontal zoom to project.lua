-- @description Horizontal zoom to project
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end; reaper.defer(nothing)
reaper.BR_SetArrangeView(0, 0, reaper.GetProjectLength(0)+reaper.GetProjectLength(0)/50)

