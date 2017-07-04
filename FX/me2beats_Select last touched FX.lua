-- @description Select last touched FX
-- @version 0.9
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local retval, trnum, fxnum, paramnum = r.GetLastTouchedFX()

if not retval then bla() return end

local tr
if trnum == 0 then tr = r.GetMasterTrack() else tr = r.GetTrack(0,trnum-1) end

local _, chunk = r.GetTrackStateChunk(tr, '', 0)

chunk = chunk:gsub('\nLASTSEL .','\nLASTSEL '..fxnum, 1)
-- 1 == don't change input/monitoring/take fx chain (if any)

r.Undo_BeginBlock()
r.SetTrackStateChunk(tr, chunk, 0)
r.Undo_EndBlock('Select last touched FX', -1)

