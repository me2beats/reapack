-- @description Set active takes to random pitch (-7..+7)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

----------------------------------
local min = -7
local max = 7
----------------------------------

local r = reaper

local items = r.CountSelectedMediaItems()
if items == 0 then return end


r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 0, items-1 do
  local item = r.GetSelectedMediaItem(0,i)

  local take = r.GetActiveTake(item)
  if take then
    local pitch = r.GetMediaItemTakeInfo_Value(take, 'D_PITCH')
    local new_pitch = math.random(min,max)
    if new_pitch ~= pitch then
      r.SetMediaItemTakeInfo_Value(take, 'D_PITCH',new_pitch)
      r.UpdateItemInProject(item)
    end
  end
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Set active takes to random pitch', -1)
