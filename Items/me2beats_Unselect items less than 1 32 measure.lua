-- @description Unselect items less than 1 32 measure
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local items = r.CountSelectedMediaItems()
if items == 0 then bla() return end

t = {}

for i = 0, items-1 do
  local it = r.GetSelectedMediaItem(0,i)
  local it_len = r.GetMediaItemInfo_Value(it, 'D_LENGTH')
  local it_start = r.GetMediaItemInfo_Value(r.GetSelectedMediaItem(0,0), 'D_POSITION')
  local _, msr = r.TimeMap2_timeToBeats(0, it_start)
  local msr_start,_,end_qn = r.TimeMap_GetMeasureInfo(0, msr)
  local msr_end = r.TimeMap2_QNToTime(0, end_qn)
  local msr_d = msr_end-msr_start
  if it_len<msr_d/32 then t[#t+1]=it end
end

if #t ==0 then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 1, #t do
  r.SetMediaItemSelected(t[i],0)
  r.UpdateItemInProject(t[i])
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Unselect items', -1)
