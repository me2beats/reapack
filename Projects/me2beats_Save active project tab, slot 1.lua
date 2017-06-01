-- @description Save active project tab, slot 1
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

local cur_p = r.EnumProjects(-1, 0)
local cur_p_str = tostring(cur_p):sub(-16)

local ext_sec, ext_key = 'me2beats_save-restore', 'active_proj_tab_1'

r.Undo_BeginBlock()

r.DeleteExtState(ext_sec, ext_key, 0)
r.SetExtState(ext_sec, ext_key, cur_p_str, 0)

r.Undo_EndBlock('Save active project tab', 2)
