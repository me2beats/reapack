-- @description Delete tracks (don't delete unselected children)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local tracks = r.CountSelectedTracks()

if tracks == 0 then bla() return end

t = {}

for i = 0, tracks-1 do local tr = r.GetSelectedTrack(0,i) t[#t+1] = tr end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 1, #t do r.DeleteTrack(t[i]) end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Delete tracks', -1)
