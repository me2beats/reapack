-- @description Edit nearest envelope point from mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local _, segment = r.BR_GetMouseCursorContext()
mouse = r.BR_GetMouseCursorContext_Position()

if not mouse or mouse == -1 then bla() return end

env = r.BR_GetMouseCursorContext_Envelope()

if not env then bla() return end

local points = r.CountEnvelopePoints(env)
if points == 0 then bla() return end

local cur = r.GetCursorPosition()

r.Undo_BeginBlock()
--r.PreventUIRefresh(1)

local closest_d = 100000

for i = 0, points-1 do
  _, time = r.GetEnvelopePoint(env,i)
  new_closest_d = math.min(math.abs(time-mouse), closest_d)
  if new_closest_d ~= closest_d then
    closest = time
    closest_d = new_closest_d
  end
end

r.SetEditCurPos2(0, closest, 0, 0)

r.SetCursorContext(2, env)

r.Main_OnCommand(41987,0)--Envelope: Edit envelope point value at cursor

r.SetEditCurPos2(0, cur, 0, 0)

--r.PreventUIRefresh(-1)
r.Undo_EndBlock('Edit nearest envelope point', -1)
