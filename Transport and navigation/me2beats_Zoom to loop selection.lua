-- @description Zoom to loop selection
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

x_l, y_l = r.GetSet_LoopTimeRange(0, 1, 0, 0, 0)
if x_l == y_l then bla() return end

r.Undo_BeginBlock()

r.BR_SetArrangeView(0, x_l-(y_l-x_l)/50, y_l+(y_l-x_l)/50)
--r.BR_SetArrangeView(0, x_l, y_l+(y_l-x_l)/50)

r.Undo_EndBlock('Zoom to loop selection', 2)
