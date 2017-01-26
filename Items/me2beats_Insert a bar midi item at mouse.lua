-- @description Insert a bar midi item at mouse
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

cur = r.GetCursorPosition()

window, segment, details = r.BR_GetMouseCursorContext()
mouse = r.BR_GetMouseCursorContext_Position()
if mouse == -1 then bla() return end

msr_cnt = 0
for i = 0, 999 do
  msr = r.TimeMap_GetMeasureInfo(0, i)
  if msr > mouse then
    first = r.TimeMap_GetMeasureInfo(0, i-4)
    msr_cnt = msr_cnt+1
  elseif msr == mouse then
    first = r.TimeMap_GetMeasureInfo(0, i-4)
    msr_cnt = msr_cnt
  end
  if msr_cnt == 1 then break end
end

r.Undo_BeginBlock()

r.PreventUIRefresh(1)

SaveLoopTimesel()
r.GetSet_LoopTimeRange(1, 0, first, msr, 0)
r.Main_OnCommand(40214,0) -- insert new midi
RestoreLoopTimesel()

r.SetEditCurPos(cur, 0, 0)

r.PreventUIRefresh(-1)


r.Undo_EndBlock('Insert 4 bars midi item at mouse', -1)
