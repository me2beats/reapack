-- @description Set loop selection to bar at play cursor
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper
 
function bar_x_y(time)
  local _, msr = r.TimeMap2_timeToBeats(0, time)
  local msr_start,_,end_qn = r.TimeMap_GetMeasureInfo(0, msr)
  local msr_end = r.TimeMap2_QNToTime(0, end_qn)
  return msr_start, msr_end
end

local play_pos = r.GetPlayPosition()

local x,y = bar_x_y(play_pos)

r.Undo_BeginBlock()
r.GetSet_LoopTimeRange(1, 1, x, y, 0)
r.Undo_EndBlock('Set loop selection to bar at play cursor', -1)
