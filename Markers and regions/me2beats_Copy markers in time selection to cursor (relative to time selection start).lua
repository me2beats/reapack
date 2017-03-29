-- @description Copy markers in time selection to cursor (relative to time selection start)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function Elem_in_tb(elem,tb)
  _found = nil
  for eit = 1, #tb do if math.abs(tb[eit] - elem) < 0.000001 then _found = 1 break end end
  if _found then return 1 end
end


local x, y = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)

markers_tb = {}
all_markers_tb = {}

local projects_markers = r.CountProjectMarkers()

cur = r.GetCursorPosition()

min_pos = 10000

for i = 0, projects_markers-1 do
  local _, reg, m_pos, _, name, _, color = r.EnumProjectMarkers3(0, i)
  if not reg then
    all_markers_tb[#all_markers_tb+1] = m_pos
    if x-m_pos<=0.000001 and m_pos-y <= 0.000001 then
      min_pos = math.min(min_pos,m_pos)
      markers_tb[#markers_tb+1] = {cur+m_pos-x,name,color}
    end
  end
end

r.Undo_BeginBlock()

for i = 1, #markers_tb do
  if not Elem_in_tb(markers_tb[i][1],all_markers_tb) then
    r.AddProjectMarker2(0, 0, markers_tb[i][1],0,markers_tb[i][2], -1, markers_tb[i][3])
  end
end

r.Undo_EndBlock('Copy markers in time selection to cursor', -1)
