-- @description Show selected envelope FX
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

r.TrackFX_Show(tr, fx, 3)

r.Undo_EndBlock('Show selected envelope FX', -1)
