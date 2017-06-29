-- @description Move items left or right by grid size (mousewheel)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

function action(id) r.Main_OnCommand(id, 0) end
local _,_,_,_,_,_,val = r.get_action_context()

r.Undo_BeginBlock()
if val > 0 then r.ApplyNudge(0, 0, 0, 2, -1, 0, 0) else r.ApplyNudge(0, 0, 0, 2, 1, 0, 0) end
r.Undo_EndBlock('Move items', 2)
