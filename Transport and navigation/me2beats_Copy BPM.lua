-- @description Copy BPM
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper
local bpm = r.GetProjectTimeSignature2(0)
r.DeleteExtState('me2beats_copy-paste', 'bpm', 0)
r.SetExtState('me2beats_copy-paste', 'bpm', bpm, 0)