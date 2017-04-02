-- @description Restore saved project tab
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function get_cur_proj_tab_number()
  retval = nil
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


local ext_sec, ext_key = 'me2beats_save-restore', 'active_proj_tab'
saved_p_str = r.GetExtState(ext_sec, ext_key)
if not saved_p_str or saved_p_str == '' then bla() return end


cur_p_iter, projects = get_cur_proj_tab_number()


for i = 0, projects-1 do
  local p = r.EnumProjects(i, 0)
  if saved_p_str == tostring(p):sub(-16) then iter = i break end
end

if not iter or iter == cur_p_iter then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

d = math.abs(iter-cur_p_iter)-1
d2 = projects-d

if iter > cur_p_iter then if d < d2 then a = 40861 else d = d2 -2 a = 40862 end
else if d < d2 then a = 40862 else d = d2 -2 a = 40861 end end

for i = 0,d do r.Main_OnCommand(a,0) end -- prev/next project tab

r.PreventUIRefresh(-1) r.Undo_EndBlock('Restore saved project tab', 2)
