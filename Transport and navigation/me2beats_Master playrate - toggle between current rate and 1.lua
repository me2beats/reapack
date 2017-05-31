-- @description Master playrate - toggle between current rate and 1
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper
local rate = r.Master_GetPlayRate()
local ext_sec, ext_key = 'me2beats_toggle','master_rate'
local new_rate = r.GetExtState(ext_sec, ext_key)

r.Undo_BeginBlock()
r.DeleteExtState(ext_sec, ext_key, 0)
if rate ~= 1 then
  r.CSurf_OnPlayRateChange(1)
  r.SetExtState(ext_sec, ext_key, rate, 0)
else
  r.CSurf_OnPlayRateChange(new_rate)
  r.SetExtState(ext_sec, ext_key, 1, 0)
end
r.Undo_EndBlock('Toggle master playrate', 2)
