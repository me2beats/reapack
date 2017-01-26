-- @description Paste BPM
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper
local bpm = r.GetExtState('me2beats_copy-paste', 'bpm')
if bpm and bpm ~= '' then
  r.Undo_BeginBlock() r.SetCurrentBPM(0, bpm, 1) r.Undo_EndBlock('Paste BPM', -1)
end