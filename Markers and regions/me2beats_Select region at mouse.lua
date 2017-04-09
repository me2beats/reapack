-- @description Select region at mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local window, segment, details = r.BR_GetMouseCursorContext()
local mouse = r.BR_GetMouseCursorContext_Position()
if not mouse then bla() return end

local _, regionidx = r.GetLastMarkerAndCurRegion(0, mouse)
if regionidx == -1 then bla() return end

r.Undo_BeginBlock()
local _, _, x, y = r.EnumProjectMarkers3(0,regionidx)
r.GetSet_LoopTimeRange(1, 0, x, y, 0)
r.Undo_EndBlock("Select region at mouse", -1)

