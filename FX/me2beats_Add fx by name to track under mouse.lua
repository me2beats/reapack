-- @description Add fx by name to track under mouse
-- @version 1.1
-- @author me2beats
-- @changelog
--  + multiple fx

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local track = r.BR_TrackAtMouseCursor()
if not  track then bla() return end

local retval, fx_name = r.GetUserInputs("Add FX to track by name", 1, "FX name:", "")

if not retval then bla() return end

r.Undo_BeginBlock()

if not fx_name:match';' then r.TrackFX_AddByName(track, fx_name, 0, -1)
else
  for name in fx_name:gmatch'(.-);' do r.TrackFX_AddByName(track, name, 0, -1) end
  if fx_name:sub(-1) ~= ';' then r.TrackFX_AddByName(track, fx_name:match'.*;(.*)', 0, -1) end
end

r.Undo_EndBlock('Add fx by name to track under mouse', -1)