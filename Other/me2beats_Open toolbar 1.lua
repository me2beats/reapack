-- @description Open toolbar 1
-- @version 0.5
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local id = 41679-- Toolbar: Open/close toolbar 1
local state = r.GetToggleCommandState(id)==1 
if state then bla() return end

r.Undo_BeginBlock()
r.Main_OnCommand(id,0)
r.Undo_EndBlock('Open toolbar 1', 2)
