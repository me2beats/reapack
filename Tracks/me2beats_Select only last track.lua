-- @description Select only last track
-- @version 1.01
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

n = r.CountTracks()
if n == 0 then bla() return end

r.Undo_BeginBlock()
r.SetOnlyTrackSelected(r.GetTrack(0,n-1))
r.Undo_EndBlock('Select only last track', -1)