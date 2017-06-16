-- @description Toggle read-latch for track with focused FX (no undo)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end
local retval, trnum, itnum, fxnum = r.GetFocusedFX()
if retval ~= 1 then bla() return end
r.Undo_BeginBlock(); r.PreventUIRefresh(1)
local tr = r.GetTrack(0,trnum-1)
local automode = r.GetMediaTrackInfo_Value(tr, 'I_AUTOMODE')
if automode ~= 1 then automode = 1 else automode = 4 end
r.SetMediaTrackInfo_Value(tr, 'I_AUTOMODE',automode)  
r.PreventUIRefresh(-1); r.Undo_EndBlock('Toggle read-latch for track with focused FX', 2)
