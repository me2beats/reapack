-- @description Set ends of items to cursor (stretch takes)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing()
end

items = reaper.CountSelectedMediaItems(0)
cur_pos = reaper.GetCursorPosition()
if items > 0 then

  script_title = 'Set ends of items to cursor (stretch takes)'
  reaper.Undo_BeginBlock()

  for i = 0, items-1 do
    it = reaper.GetSelectedMediaItem(0,i)
    it_pos = reaper.GetMediaItemInfo_Value(it, 'D_POSITION')
    if cur_pos > it_pos then
      old_it_len = reaper.GetMediaItemInfo_Value(it, 'D_LENGTH')
      new_it_len = cur_pos - it_pos
      takes = reaper.CountTakes(it)
      for t = 0, takes - 1 do
        take = reaper.GetTake(it, t)
        old_take_rate = reaper.GetMediaItemTakeInfo_Value(take, 'D_PLAYRATE')
        new_take_rate = old_it_len * old_take_rate / new_it_len
        reaper.SetMediaItemTakeInfo_Value(take, 'D_PLAYRATE', new_take_rate)
      end
      reaper.SetMediaItemInfo_Value(it, 'D_LENGTH', new_it_len)
      reaper.UpdateItemInProject(it)
    end
  end
  reaper.Undo_EndBlock(script_title, -1)
else
  reaper.defer(nothing)
end
