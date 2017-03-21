-- @description Move cursor to selected envelope selected point
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

env = r.GetSelectedEnvelope()
if not env then bla() return end
points = r.CountEnvelopePoints(env)
if not points == 0 then bla() return end

r.Undo_BeginBlock()

for i = 0, points-1 do
  _, time, _, _, _, sel = r.GetEnvelopePoint(env,i)
  if sel then r.SetEditCurPos2(0, time, 0, 0) break end
end

r.Undo_EndBlock('Move cursor to sel point', -1)
