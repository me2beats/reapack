-- @description Move item one measure left
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local items = r.CountSelectedMediaItems()
if items == 0 then bla() return end

r.Undo_BeginBlock()

r.ApplyNudge(0, 0, 0, 16, -1, 0, 0)

r.Undo_EndBlock('Move time selection left one measure', -1)
