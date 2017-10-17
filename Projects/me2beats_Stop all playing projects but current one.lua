-- @description Stop all playing projects but current one
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

local cur = r.EnumProjects(-1, '')

for p = 0, 1000 do
  local proj = r.EnumProjects(p, 0)
  if not proj then break end
  local play_st = r.GetPlayStateEx(proj)
  if play_st == 1 and proj ~= cur then
    r.OnStopButtonEx(proj)
  end
end
