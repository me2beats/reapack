-- @description Set time selection to nearest project or tempo markers from cursor
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local cur = r.GetCursorPosition()

local m_start_i = r.GetLastMarkerAndCurRegion(0, cur)
local _,_, m_start = r.EnumProjectMarkers(m_start_i)
local _,_, m_end = r.EnumProjectMarkers(m_start_i+1)
if m_end<m_start then m_end = nil end

local t_start_i = r.FindTempoTimeSigMarker(0, cur)
local _, t_start = r.GetTempoTimeSigMarker(0, t_start_i)
local _, t_end = r.GetTempoTimeSigMarker(0, t_start_i+1)
if t_end<t_start then t_end = nil end

if not (m_end or t_end) then bla() return end
local x,y
if cur-m_start < cur-t_start then x = m_start else x = t_start end
if m_end and m_end-cur < t_end-cur then y = m_end else y = t_end end
if not (x or y) or x == y then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)
r.GetSet_LoopTimeRange(1, 0, x,y, 0)
r.PreventUIRefresh(-1) r.Undo_EndBlock('Set time selection to nearest markers from cursor', -1)
