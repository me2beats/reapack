-- @description Set time selection to nearest markers from mouse
-- @version 1.02
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local _, markers = r.CountProjectMarkers(); if markers<2 then bla() return end

local window, segment, details = r.BR_GetMouseCursorContext()
local mouse = r.BR_GetMouseCursorContext_Position()
if not mouse then bla() return end

local m_start_i = r.GetLastMarkerAndCurRegion(0, mouse)
if m_start_i == -1 then bla() return end
local _,_, m_start = r.EnumProjectMarkers(m_start_i)
local _,_, m_end = r.EnumProjectMarkers(m_start_i+1)
if m_end and (m_end<m_start or m_end==m_start) then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)
r.GetSet_LoopTimeRange(1, 0, m_start, m_end, 0)
r.PreventUIRefresh(-1) r.Undo_EndBlock('Set time selection to nearest markers from mouse', -1)
