-- @description Decrease active takes pitch linearly (-1 semitone)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

local items = r.CountSelectedMediaItems()
if items == 0 then return end

local first_take = r.GetActiveTake(r.GetSelectedMediaItem(0,0))
if not first_take then return end

local first_pitch = r.GetMediaItemTakeInfo_Value(first_take, 'D_PITCH')
first_pitch = math.floor(first_pitch+.5)

r.Undo_BeginBlock(); r.PreventUIRefresh(1)

local iter = 0
for i = 1, items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  local take = r.GetActiveTake(item)
  if take then
    iter=iter-1
    local pitch = r.GetMediaItemTakeInfo_Value(take, 'D_PITCH')
    if pitch~= first_pitch+iter then
      r.SetMediaItemTakeInfo_Value(take, 'D_PITCH',first_pitch+iter)
      r.UpdateItemInProject(item)
    end
  end
end

r.PreventUIRefresh(-1); r.Undo_EndBlock('Decrease takes pitch (-1)', -1)
