-- @description Stop all projects
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

for p = 0, 1000 do
  proj = r.EnumProjects(p, 0)
  if not proj then break
  else
    play_st = r.GetPlayStateEx(proj)
    if play_st == 1 then r.OnStopButtonEx(proj) end
  end
end
