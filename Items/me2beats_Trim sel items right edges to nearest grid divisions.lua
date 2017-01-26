-- @description Trim sel items right edges to nearest grid divisions
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end
function hello()
  start_pos = reaper.GetMediaItemInfo_Value(it, 'D_POSITION')
  len = reaper.GetMediaItemInfo_Value(it, 'D_LENGTH')
  end_pos = start_pos + len
  end_grid = reaper.BR_GetClosestGridDivision(end_pos)
  reaper.ApplyNudge(0, 1, 3, 1, end_grid, false, 0)
end

items = reaper.CountSelectedMediaItems(0)
if items > 0 then
  script_title = 'Trim sel items right edges to nearest grid divisions'
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
