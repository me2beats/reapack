-- @description Trim sel items edges to nearest measure (increase items length)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end
function hello()
  start_pos = reaper.GetMediaItemInfo_Value(it, 'D_POSITION')
  len = reaper.GetMediaItemInfo_Value(it, 'D_LENGTH')
  end_pos = start_pos + len
  i = 0
  start_pos_measure_end = 0
  while start_pos > start_pos_measure_end do
    start_pos_measure_end = reaper.TimeMap_GetMeasureInfo(0, i)
    i = i+1
  end
  if start_pos_measure_end ~= 0 then
    start_pos_measure_start = reaper.TimeMap_GetMeasureInfo(0, i-2)
  elseif start_pos_measure_end == 0 then
    start_pos_measure_start = 0
  end
  
  i = 0
  end_pos_measure_end = 0
  while end_pos > end_pos_measure_end do
    end_pos_measure_end = reaper.TimeMap_GetMeasureInfo(0, i)
    i = i+1
  end
  if end_pos_measure_end ~= 0 then
    end_pos_measure_start = reaper.TimeMap_GetMeasureInfo(0, i-2)
  elseif end_pos_measure_end == 0 then
    end_pos_measure_start = 0
  end
  
  reaper.ApplyNudge(0, 1, 3, 1, end_pos_measure_end, false, 0)
  reaper.ApplyNudge(0, 1, 1, 1, start_pos_measure_start, false, 0)
end


items = reaper.CountSelectedMediaItems(0)
if items > 0 then
  script_title = 'Trim sel items edges to nearest grid divisions'
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  if items == 1 then
    it = reaper.GetSelectedMediaItem(0, 0)
    hello()
  else
----  save selected items---------------
    t = {}
    for i = 0, items-1 do
      it = reaper.GetSelectedMediaItem(0,i)
      guid = reaper.BR_GetMediaItemGUID(it)
      table.insert(t, guid)
    end
---------------------------------------
    reaper.Main_OnCommand(40289, 0)--  unselect all items
    for i = 1, #t do
      it = reaper.BR_GetMediaItemByGUID(0, t[i])
      reaper.SetMediaItemSelected(it, true)
      hello()      
      reaper.SetMediaItemSelected(it, false)
    end
---- restore sel items-------------------
    for i = 1, #t do
      it = reaper.BR_GetMediaItemByGUID(0, t[i])
      reaper.SetMediaItemSelected(it, true)
    end
-----------------------------------------
  end
  reaper.Undo_EndBlock(script_title, -1)
  reaper.PreventUIRefresh(-1)
else
  reaper.defer(nothing)
end
