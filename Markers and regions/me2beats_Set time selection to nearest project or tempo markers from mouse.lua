-- @description Set time selection to nearest project or tempo markers from mouse
-- @version 1.11
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local t_start,t_end,m_start,m_end,m_start_i,t_start_i,mouse,x,y

local window, segment, details = r.BR_GetMouseCursorContext()
mouse = r.BR_GetMouseCursorContext_Position()
if not mouse or mouse ==-1 then bla() return end

m_start_i, t_start_i = r.GetLastMarkerAndCurRegion(0, mouse), r.FindTempoTimeSigMarker(0, mouse)

if m_start_i ~= -1 then
  _,_, m_start = r.EnumProjectMarkers(m_start_i)
  _,_, m_end = r.EnumProjectMarkers(m_start_i+1)
  if m_end<=m_start then m_end = nil end
end

if t_start_i ~= -1 then
  _, t_start = r.GetTempoTimeSigMarker(0, t_start_i)
  _, t_end = r.GetTempoTimeSigMarker(0, t_start_i+1)
  if t_end<=t_start then t_end = nil end
end

if not ((m_start or t_start) and (m_end or t_end)) then bla() return end

if t_start and m_start then
  if mouse-m_start < mouse-t_start then x = m_start else x = t_start end
elseif t_start then x = t_start else x = m_start end

if t_end and m_end then
  if m_end-mouse < t_end-mouse then y = m_end else y = t_end end
elseif t_end then y = t_end else y = m_end end

if not (x or y) or x == y then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)
r.GetSet_LoopTimeRange(1, 0, x,y, 0)
r.PreventUIRefresh(-1) r.Undo_EndBlock('Set time selection to nearest markers from mouse', -1)
