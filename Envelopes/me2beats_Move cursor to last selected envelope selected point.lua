-- @description Move cursor to last selected envelope selected point
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local env = r.GetSelectedEnvelope()
if not env then bla() return end
local points = r.CountEnvelopePoints(env)

local max = 0

for i = 0, points-1 do
  local _, time, _, _, _, sel = r.GetEnvelopePoint(env,i)
  if sel then max = math.max(time,max) end
end

if max == 0 or r.GetCursorPosition()==max then bla() return end

r.Undo_BeginBlock()
r.SetEditCurPos2(0, max, 0, 0)
r.Undo_EndBlock('Move cursor to last sel point', 2)
