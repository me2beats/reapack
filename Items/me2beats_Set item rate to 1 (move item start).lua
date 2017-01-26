-- @description Set item rate to 1 (move item start)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local items = r.CountSelectedMediaItems()
if items > 0 then
  r.Undo_BeginBlock()
  for i = 0, items-1 do
    it = r.GetSelectedMediaItem(0,i)
    it_start = r.GetMediaItemInfo_Value(it, 'D_POSITION')
    it_len = r.GetMediaItemInfo_Value(it, 'D_LENGTH')
    it_end = it_start + it_len
    
    takes = r.CountTakes(it)
    rate = r.GetMediaItemTakeInfo_Value(r.GetActiveTake(it), 'D_PLAYRATE')
    for t = 0, takes - 1 do
      take = r.GetTake(it, t)
      r.SetMediaItemTakeInfo_Value(take, 'D_PLAYRATE', 1)
    end

    new_len = it_len*rate
    
    r.SetMediaItemInfo_Value(it, 'D_LENGTH', new_len)
    r.SetMediaItemInfo_Value(it, 'D_POSITION', it_start+it_len-new_len)
    r.UpdateItemInProject(it)

  end

  r.Undo_EndBlock('Set item rate to 1 (move item start)', -1)
else bla() end
