-- @description Toggle show selected envelope FX
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local env = r.GetSelectedEnvelope()
if not env then bla() return end

local tr, fx = r.Envelope_GetParentTrack(env)
if not (tr and fx) then bla() return end

r.Undo_BeginBlock()

r.TrackFX_SetOpen(tr, fx, not r.TrackFX_GetOpen(tr, fx ))

r.Undo_EndBlock('Toggle show selected envelope FX', -1)
