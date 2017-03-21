-- @description Edit selected envelope point
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

env = r.GetSelectedEnvelope()
if not env then bla() return end
points = r.CountEnvelopePoints(env)
if points == 0 then bla() return end

local cur = r.GetCursorPosition()

r.Undo_BeginBlock()
--r.PreventUIRefresh(1)

for i = 0, points-1 do
  _, time, _, _, _, sel = r.GetEnvelopePoint(env,i)
  if sel then r.SetEditCurPos2(0, time, 0, 0) found = 1 break end
end

if found then

  r.Main_OnCommand(41987,0)--Envelope: Edit envelope point value at cursor

  r.SetEditCurPos2(0, cur, 0, 0)
end

--r.PreventUIRefresh(-1)
r.Undo_EndBlock('Edit sel envelope point', -1)
