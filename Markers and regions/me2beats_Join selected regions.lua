-- @description Join selected regions
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function del_regions_in_range(regions, i_a,i_z)
-- N: regions
  for i = i_z, i_a, -1 do
    local _, _, _, _, _, idx = r.EnumProjectMarkers3(0,i)
    r.DeleteProjectMarker(0, idx, 1)
  end
end


function regions_in_area_return_extreme_points(x,y,regions)
--N: regions
  local min, max = math.huge, 0
  local i_min, i_max = -1, -1

  for i = 0, regions-1 do
    local _, _, x_r, y_r = r.EnumProjectMarkers(i)

    if x_r < y and y_r > x then
      if math.max(max,y_r) == y_r then max = y_r i_max = i end
    end

    if y_r > x and x_r < y then
      if math.min(min,x_r) == x_r then min = x_r i_min = i end
    end
  end
  return min, max, i_min, i_max
end

function min_max(x,y) return math.min(x,y),math.max(x,y) end

local _, _, regions = r.CountProjectMarkers()
if regions == 0 then bla() return end

x,y = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
if x == y then bla() return end

min,max,i_min,i_max = regions_in_area_return_extreme_points(x,y,regions)
if max == 0 then bla() return end
if i_min == i_max then bla() return end

i_min,i_max = min_max(i_min,i_max)

local _, _, x_r, y_r, name, num, color = r.EnumProjectMarkers3(0, i_min)

r.Undo_BeginBlock(); r.PreventUIRefresh(1)

del_regions_in_range(regions, i_min,i_max)
r.AddProjectMarker2(0, 1, min, max, name, -1, color)

r.PreventUIRefresh(-1); r.Undo_EndBlock('Join sel regions', -1)
