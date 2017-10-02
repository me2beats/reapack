-- @description Toggle open items inline editors (+ zoom)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

local action = r.NamedCommandLookup'_SWS_TOGZOOMIONLY'

local state = r.GetToggleCommandState(action)

if state ~= 1 then

  local items = r.CountSelectedMediaItems()
  if items == 0 then return end

  local f
  for i = 0, items-1 do
    local it = r.GetSelectedMediaItem(0,i)
    local take = r.GetActiveTake(it)
    if not (take and r.TakeIsMIDI(take)) then f = true break end
  end

  if f then return end


  r.Undo_BeginBlock()
--  r.PreventUIRefresh(1)
  r.Main_OnCommand(40847,0) --Item: Open item inline editors
  r.Main_OnCommand(action,0)
--  r.PreventUIRefresh(-1)

  r.Undo_EndBlock('Toggle open inline editors', -1)
  
else

  r.Undo_BeginBlock() r.PreventUIRefresh(1)
  r.Main_OnCommand(action,0)

  r.Main_OnCommand(41887,0) --Item: Close item inline editors
  
  
  r.PreventUIRefresh(-1) r.Undo_EndBlock('Toggle open inline editors', -1)

end
