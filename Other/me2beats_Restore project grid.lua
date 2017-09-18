-- @description Restore project grid
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

local ext_sec, ext_key = 'me2beats_save-restore', 'grid'
local str = r.GetExtState(ext_sec, ext_key)
if not str or str == '' then return end

local division, swingmode, swingamt = str:match'(.*),(.*),(.*)'
if not (division and swingmode and swingamt) then return end

r.Undo_BeginBlock()
r.GetSetProjectGrid(0, 1, division, swingmode, swingamt)
r.Undo_EndBlock('Restore project grid', 2)
