-- @description Save cursor position
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

local ext_sec, ext_key, cur = 'me2beats_save_restore', 'cursor2', r.GetCursorPosition()
r.SetExtState(ext_sec, ext_key, cur, 0)
