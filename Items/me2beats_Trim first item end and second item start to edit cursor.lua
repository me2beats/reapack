-- @description Trim first item end and second item start to edit cursor
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end

init_sel_items = {}
local function SaveSelectedItems (table)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do table[i+1] = reaper.GetSelectedMediaItem(0, i) end
end

local function RestoreSelectedItems (table)
  reaper.Main_OnCommand(40289, 0) -- unselect all items
  for _, item in ipairs(table) do reaper.SetMediaItemSelected(item, true) end
end

item_1 = reaper.GetSelectedMediaItem(0,0); item_2 = reaper.GetSelectedMediaItem(0,1)
if item_1 and item_2 then
  item_1_start = reaper.GetMediaItemInfo_Value(item_1,'D_POSITION')
  item_2_start = reaper.GetMediaItemInfo_Value(item_2,'D_POSITION')
  item_1_len = reaper.GetMediaItemInfo_Value(item_1,'D_LENGTH')
  item_1_end = item_1_start + item_1_len
  item_2_len = reaper.GetMediaItemInfo_Value(item_2,'D_LENGTH')
  item_2_end = item_2_start + item_2_len
  if item_1_start > item_2_start then
    invert = 1
    item_1, item_2 = item_2, item_1
    item_1_start, item_2_start = item_2_start, item_1_start
    item_1_len, item_2_len = item_2_len, item_1_len
    item_1_end, item_2_end = item_2_end, item_1_end
  end
  cur = reaper.GetCursorPosition()
  if cur > item_1_start and cur < item_2_end then
    reaper.Undo_BeginBlock(); reaper.PreventUIRefresh(111)
    sel_it_tb = {}
    SaveSelectedItems (sel_it_tb)
    reaper.Main_OnCommand(40289, 0) -- unselect all items
    if invert == 1 then
      reaper.SetMediaItemSelected(sel_it_tb[2], true)
    else reaper.SetMediaItemSelected(sel_it_tb[1], true) end
    reaper.Main_OnCommand(41311, 0) -- trim right edge of item to edit cursor
    reaper.Main_OnCommand(40289, 0) -- unselect all items
    if invert == 1 then
      reaper.SetMediaItemSelected(sel_it_tb[1], true)
    else reaper.SetMediaItemSelected(sel_it_tb[2], true) end
    reaper.Main_OnCommand(41305, 0) -- trim left edge of item to edit cursor
    RestoreSelectedItems (sel_it_tb)
    reaper.PreventUIRefresh(-111)
    reaper.UpdateArrange()
    reaper.Undo_EndBlock('Trim first item end and second item start to cursor', -1)
  else reaper.defer(nothing) end
else reaper.defer(nothing) end
