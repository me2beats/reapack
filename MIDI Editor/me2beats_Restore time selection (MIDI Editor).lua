-- @description Restore time selection (MIDI Editor)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

local ext_sec, ext_key = 'me2beats_save-restore', 'time_selection'
local str = r.GetExtState(ext_sec, ext_key)
if not str or str == '' then return end

local x,y = str:match'(.*),(.*)'
if not (x and y) then return end

r.Undo_BeginBlock()
r.GetSet_LoopTimeRange(1, 0, x, y, 0)
r.Undo_EndBlock('Restore time selection', -1)
