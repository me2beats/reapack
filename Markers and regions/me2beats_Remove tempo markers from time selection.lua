-- @description Remove tempo markers from time selection
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local x,y = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
if x==y then bla() return end

local t_start_i = r.FindTempoTimeSigMarker(0, x)

local _, t_start

if not t_start_i or t_start_i == -1 then bla() return end
_, t_start = r.GetTempoTimeSigMarker(0, t_start_i)
if t_start < x then
  _, t_start = r.GetTempoTimeSigMarker(0, t_start_i+1)
  if t_start == 0 or t_start > y then bla() return end
end

local t_end_i = r.FindTempoTimeSigMarker(0, y)

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = t_end_i,t_start_i,-1 do
  r.DeleteTempoTimeSigMarker(0, i)
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Remove tempo markers from time selection', -1)
