-- @description Move cursor to closest marker
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local move_view = 1

local r = reaper; local function nothing() end
local function bla() r.defer(nothing) end

local cur = r.GetCursorPosition()

local projects_markers = r.CountProjectMarkers()

local min_pos = 10000

for i = 0, projects_markers-1 do
  local _, reg, m_pos = r.EnumProjectMarkers3(0, i)
  if not reg then
    if min_pos > math.abs(cur-m_pos) then 
      min_pos = math.abs(cur-m_pos)
      cur_ = m_pos
    end
  end
end

if not cur_ or cur == cur_ then bla() return end

r.Undo_BeginBlock()
r.SetEditCurPos2(0, cur_, move_view, 0)
r.Undo_EndBlock('Move cursor to closest marker', -1)