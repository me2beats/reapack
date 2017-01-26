-- @description Save all unsaved (dirty) projects as new versions
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
  if reaper.IsProjectDirty(p) == 1 then reaper.Main_OnCommand(41895,0) end -- save new version of project
  reaper.Main_OnCommand(40861,0) -- next project tab
end
reaper.PreventUIRefresh(-111)
