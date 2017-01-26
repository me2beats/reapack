-- @description Insert 4 bars midi item
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function SaveLoopTimesel()
  init_start_timesel, init_end_timesel = reaper.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
  init_start_loop, init_end_loop = reaper.GetSet_LoopTimeRange(0, 1, 0, 0, 0)
end

function RestoreLoopTimesel()
  reaper.GetSet_LoopTimeRange(1, 0, init_start_timesel, init_end_timesel, 0)
  reaper.GetSet_LoopTimeRange(1, 1, init_start_loop, init_end_loop, 0)
end

cur = r.GetCursorPosition()
msr_cnt = 0
for i = 0, 999 do
  msr = r.TimeMap_GetMeasureInfo(0, i)
  if msr > cur then
    first = r.TimeMap_GetMeasureInfo(0, i-4)
    msr_cnt = msr_cnt+1
  elseif msr == cur then
    first = r.TimeMap_GetMeasureInfo(0, i-4)
    msr_cnt = msr_cnt
  end
  if msr_cnt == 4 then break end
end

r.Undo_BeginBlock()

r.PreventUIRefresh(1)

SaveLoopTimesel()
r.GetSet_LoopTimeRange(1, 0, first, msr, 0)
r.Main_OnCommand(40214,0) -- insert new midi
RestoreLoopTimesel()

r.SetEditCurPos(cur, 0, 0)

r.PreventUIRefresh(-1)


r.Undo_EndBlock('Insert 4 bars midi item', -1)
