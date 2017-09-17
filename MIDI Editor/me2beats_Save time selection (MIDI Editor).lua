-- @description Save time selection (MIDI Editor)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

local x,y = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)

local ext_sec, ext_key = 'me2beats_save-restore', 'time_selection'
r.SetExtState(ext_sec, ext_key, x..','..y, 0)
