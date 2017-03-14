-- @description Copy selected regions to project end (with contents)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function regions_in_area_return_extreme_points(x,y)

  local _, _, regions = r.CountProjectMarkers()
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



function copy_all_items_in_area_to_cursor_moving_later(x,y)
  --W: items and track selection changes!

  local function UnselectAllTracks()
    local first_track = r.GetTrack(0, 0)
    r.SetOnlyTrackSelected(first_track)
    r.SetTrackSelected(first_track, 0)
  end
  
  local function SaveSelTracks()
    sel_tracks = {}
    for i = 0, r.CountSelectedTracks()-1 do
      sel_tracks[i+1] = r.GetSelectedTrack(0, i)
    end
  end
  
  local function RestoreSelTracks()
    UnselectAllTracks()
    for _, track in ipairs(sel_tracks) do
      r.SetTrackSelected(track, 1)
    end
  end
  
  function UnselectAllItems()
    for  i = 0, r.CountMediaItems()-1 do
      r.SetMediaItemSelected(r.GetMediaItem(0, i), 0)
    end
  end
  
  local function SaveSelItems()
    sel_items = {}
    for i = 0, r.CountSelectedMediaItems()-1 do
      sel_items[i+1] = r.GetSelectedMediaItem(0, i)
    end
  end
  
  local function RestoreSelItems()
    UnselectAllItems() -- Unselect all items
    for _, item in ipairs(sel_items) do
      if item then r.SetMediaItemSelected(item, 1) end
    end
  end
  
  function insert_space(val,pos)
    --W: time selection changes!
    r.GetSet_LoopTimeRange(1, 0, pos, pos+val, 0)
    r.Main_OnCommand(40200,0) -- insert empty space at time selection (moving later items)
  end
  
  function set_tr_with_top_item_in_ts_as_last_touched()
    --W: items selection changes!
    --N: UnselectAllItems()
    UnselectAllItems()
    r.Main_OnCommand(40717,0) -- select all items in current time selection
  
    local items = r.CountSelectedMediaItems()
  
    local min = 1000
  
    for i = 0, items-1 do
      local item = r.GetSelectedMediaItem(0,i)
      local tr = r.GetMediaItem_Track(item)
      local num = r.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER')
      min = math.min(min,num)
    end
  
    local tr = r.GetTrack(0,min-1)
    r.SetOnlyTrackSelected(tr,1)
    r.Main_OnCommand(40914,0) -- Track: Set first selected track as last touched track
  end
  
  function paste_items_moving_later()


    r.Main_OnCommand(40058,0) -- paste items/tracks
    r.GetSet_LoopTimeRange(1, 0, x, y, 0)
  
    r.SetOnlyTrackSelected(last_touched_tr,1)
    r.Main_OnCommand(40914,0) -- set first selected track as last touched track
    
    RestoreSelItems() RestoreSelTracks() r.SetEditCurPos2(0, cur_0, 0, 0)

  end
  
  cur = r.GetCursorPosition()
  local len = max-min
  
  SaveSelTracks() SaveSelItems()  
  
  r.GetSet_LoopTimeRange(1, 0, min, max, 0)  
  
  r.Main_OnCommand(40296,0) -- select all tracks
  r.Main_OnCommand(40182,0) -- select all items
  r.Main_OnCommand(40060,0) -- copy selected area of items

  last_touched_tr = r.GetLastTouchedTrack()
  set_tr_with_top_item_in_ts_as_last_touched()

  insert_space(len,cur)
  r.GetSet_LoopTimeRange(1, 0, min, max, 0)
  paste_items_moving_later()

end


function split_regions(time)

  local t = {}

  local _, _, regions = r.CountProjectMarkers()

  for i = 0, regions-1 do
    local _, _, x_r, y_r, name, num, color = r.EnumProjectMarkers3(0, i)
    if x_r < cur and y_r > cur then
      t[#t+1] = {x_r, y_r, name, color, num}
    end
  end

  for i = 1, #t do
    r.SetProjectMarker3(0, t[i][5], 1, t[i][1], time, t[i][3], t[i][4])
    r.AddProjectMarker2(0, 1, time,t[i][2],t[i][3],-1,t[i][4])
  end
end


function copy_regions_in_range(i_min,i_max,min,max)

  t = {}

  for i = i_min,i_max do
    local _, _, x_r, y_r, name, num, color = r.EnumProjectMarkers3(0, i)
    t[#t+1] = {x_r, y_r, name, color}
  end

  return t
end

function paste_regions_to_cursor(t)
  -- N: cur

  local d = cur-min
  for i = 1, #t do r.AddProjectMarker2(0, 1, t[i][1]+d,t[i][2]+d,t[i][3],-1,t[i][4]) end

end


x_ts,y_ts = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
if x_ts == y_ts then bla() return end

x_l,y_l = r.GetSet_LoopTimeRange(0, 1, 0, 0, 0)

local _, _, regions = r.CountProjectMarkers()
if regions == 0 then bla() return end

local items = r.CountMediaItems()
if items == 0 then bla() return end

min_old,max_old,i_min,i_max = regions_in_area_return_extreme_points(x_ts,y_ts)
if max == 0 then bla() return end

cur_0 = r.GetCursorPosition()
cur = r.GetProjectLength()

r.SetEditCurPos2(0, cur, 0, 0)

min_cur,max_cur = regions_in_area_return_extreme_points(cur,cur)

t_r = copy_regions_in_range(i_min,i_max,min,max)

r.Undo_BeginBlock() r.PreventUIRefresh(1)

split_regions(cur)

min,max,i_min,i_max = regions_in_area_return_extreme_points(min_old,max_old)

copy_all_items_in_area_to_cursor_moving_later(min,max)

paste_regions_to_cursor(t_r)

--r.GetSet_LoopTimeRange(1, 0, x_ts, y_ts, 0)

if x_l > cur then
  r.GetSet_LoopTimeRange(1, 1, x_l+(max-min),y_l+(max-min), 0)
elseif x_l < cur and y_l > cur then 
  r.GetSet_LoopTimeRange(1, 1, cur,cur+max-min, 0)
end

if x_ts > cur then
  r.GetSet_LoopTimeRange(1, 0, x_ts+(max-min),y_ts+(max-min), 0)
elseif x_ts < cur and y_ts > cur then 
  r.GetSet_LoopTimeRange(1, 0, cur,cur+max-min, 0)
else
  r.GetSet_LoopTimeRange(1, 0, x_ts,y_ts, 0)  
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Copy regions to project end', -1)
