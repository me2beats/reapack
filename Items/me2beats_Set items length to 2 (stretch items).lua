-- @description Set items length to 2 (stretch items)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function SaveLoopTimesel()
  init_start_timesel, init_end_timesel = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
  init_start_loop, init_end_loop = r.GetSet_LoopTimeRange(0, 1, 0, 0, 0)
end

function RestoreLoopTimesel()
  r.GetSet_LoopTimeRange(1, 0, init_start_timesel, init_end_timesel, 0)
  r.GetSet_LoopTimeRange(1, 1, init_start_loop, init_end_loop, 0)
end

local items = r.CountSelectedMediaItems(0)
if items > 0 then
  SaveLoopTimesel()
  r.Undo_BeginBlock(); r.PreventUIRefresh(1)
  tb = {}
  for i = 0, items-1 do tb[#tb+1] = r.GetSelectedMediaItem(0,i) end
  for i = 1, #tb do
    r.Main_OnCommand(40289,0) -- unselect items
    r.SetMediaItemSelected(tb[i], 1)
    r.Main_OnCommand(40290,0) -- set ts to item
    ts_start, ts_end = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
    r.GetSet_LoopTimeRange(1, 0, ts_start, 2*ts_end-ts_start, 0)
    r.Main_OnCommand(41206,0) -- move and stretch item to fit time selection
  end
  for i = 1, #tb do r.SetMediaItemSelected(tb[i], 1) end
  RestoreLoopTimesel()
  r.PreventUIRefresh(-1); r.Undo_EndBlock('set items length to 2 (stretch)', -1)

else bla() end
