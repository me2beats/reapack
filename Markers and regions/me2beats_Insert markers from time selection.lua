-- @description Insert markers from time selection
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local x,y = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0) if x==y then bla() return end

function m_pos(id) local _,_, m_pos = r.EnumProjectMarkers(id); return m_pos end

function add_marker(time)
  local m = r.GetLastMarkerAndCurRegion(0, time)
  m = -1 or m_pos(m)
  if m ~= time then r.AddProjectMarker(0, 0, time, 0, '', -1) end
end

r.Undo_BeginBlock() r.PreventUIRefresh(1)
add_marker(x); add_marker(y)
r.PreventUIRefresh(-1) r.Undo_EndBlock('Insert markers from time selection', -1)
