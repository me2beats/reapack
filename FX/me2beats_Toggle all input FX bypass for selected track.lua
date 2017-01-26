-- @description Toggle all input FX bypass for selected track
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

tr = r.GetSelectedTrack(0,0)
fx = r.TrackFX_GetRecCount(tr)

for i = 0, fx-1 do
  ii = i+16777216
  local fx_enabled = r.TrackFX_GetEnabled(tr, ii)
  r.TrackFX_SetEnabled(tr, ii, not fx_enabled)
end

