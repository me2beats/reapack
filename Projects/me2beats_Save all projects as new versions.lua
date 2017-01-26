-- @description Save all projects as new versions
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

for p = 1, 100 do -- if you have more then 100 project tabs you can change this
  retval = reaper.EnumProjects(p, '')
  if retval == nil then x = p break end
end

reaper.PreventUIRefresh(111)
for p = 1, x do
  reaper.Main_OnCommand(41895,0) -- save new version of project
  reaper.Main_OnCommand(40861,0) -- next project tab
end
reaper.PreventUIRefresh(-111)
