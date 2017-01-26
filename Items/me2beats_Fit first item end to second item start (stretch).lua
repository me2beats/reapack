-- @description Fit first item end to second item start (stretch)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end

function SaveLoopTimesel()
  init_start_timesel, init_end_timesel = reaper.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
  init_start_loop, init_end_loop = reaper.GetSet_LoopTimeRange(0, 1, 0, 0, 0)
end

function RestoreLoopTimesel()
  reaper.GetSet_LoopTimeRange(1, 0, init_start_timesel, init_end_timesel, 0)
  reaper.GetSet_LoopTimeRange(1, 1, init_start_loop, init_end_loop, 0)
end

init_sel_items = {}
local function SaveSelectedItems (table)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do table[i+1] = reaper.GetSelectedMediaItem(0, i) end
end

local function RestoreSelectedItems (table)
  reaper.Main_OnCommand(40289, 0) -- Unselect all items
  for _, item in ipairs(table) do reaper.SetMediaItemSelected(item, true) end
end

item_1 = reaper.GetSelectedMediaItem(0,0)
item_2 = reaper.GetSelectedMediaItem(0,1)
if item_1 and item_2 then
  reaper.Undo_BeginBlock(); reaper.PreventUIRefresh(111)
  sel_it_tb = {}
  SaveLoopTimesel(); SaveSelectedItems (sel_it_tb)
  reaper.Main_OnCommand(40289, 0) -- Unselect all items
  item_1_start = reaper.GetMediaItemInfo_Value(item_1,'D_POSITION')
  item_2_start = reaper.GetMediaItemInfo_Value(item_2,'D_POSITION')
  reaper.GetSet_LoopTimeRange(1, 0, item_1_start, item_2_start, 0)
  reaper.GetSet_LoopTimeRange(1, 1, item_1_start, item_2_start, 0)
  reaper.SetMediaItemSelected(sel_it_tb[1], true)
  reaper.Main_OnCommand(41206, 0) -- move and stretch items to fit time selection
  RestoreSelectedItems (sel_it_tb); RestoreLoopTimesel()
  reaper.PreventUIRefresh(-111)
  reaper.UpdateArrange()
  reaper.Undo_EndBlock('Fit first item end to second item start (stretch)', -1)
else reaper.defer(nothing) end
