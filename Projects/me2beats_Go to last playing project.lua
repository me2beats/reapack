-- @description Go to last playing project
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function get_cur_proj_tab_number()
  local retval
  for p = 1, 1000 do
    retval = r.EnumProjects(p, '')
    if not retval then projects = p break end
  end
  local retval_0  = r.EnumProjects(-1, '')
  for p = 1, projects do
    retval  = r.EnumProjects(p-1, '')
    if retval == retval_0 then cur_proj_tab = p break end
  end
  retval = nil; return cur_proj_tab-1, projects
end

local iter

for p = 0, 1000 do
  local proj = r.EnumProjects(p, 0)
  if not proj then break
  else
    local play_st = r.GetPlayStateEx(proj)
    if play_st == 1 then iter = p end
  end
end

local cur_p_iter, projects = get_cur_proj_tab_number()

if not iter or iter == cur_p_iter then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

local d = math.abs(iter-cur_p_iter)-1
local d2 = projects-d

if iter > cur_p_iter then if d < d2 then a = 40861 else d = d2 -2 a = 40862 end
else if d < d2 then a = 40862 else d = d2 -2 a = 40861 end end

for i = 0,d do r.Main_OnCommand(a,0) end -- prev/next project tab

r.PreventUIRefresh(-1) r.Undo_EndBlock('Go to last playing project', 2)

