-- @description Enable swing grid
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

function ToggleActionOnOff(id,on,undo_name,undo_flag)

  local state = r.GetToggleCommandState(id)
  if on == 1 and state == 0 or on == 0 and state ~= 0 then
    r.Undo_BeginBlock()
    r.Main_OnCommand(id,0)
    r.Undo_EndBlock(undo_name, undo_flag)
  end
end


ToggleActionOnOff(42304,1,'Enable swing grid',-1)
