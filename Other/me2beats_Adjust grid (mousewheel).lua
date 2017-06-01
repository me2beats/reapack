-- @description Adjust grid (mousewheel)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper
local _, d = r.GetSetProjectGrid(0, 0)
local _,_,_,_,_,_,val = r.get_action_context()

r.Undo_BeginBlock()

if val < 0 then r.SetProjectGrid(0, d*2) else r.SetProjectGrid(0, d/2) end

r.Undo_EndBlock('Adjust grid', 2)
