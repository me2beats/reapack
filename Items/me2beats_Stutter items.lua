-- @description Stutter items
-- @version 1.2
-- @author me2beats
-- @changelog
--  + init
--  + some bugs fixed
--  + item selection bug fixed, smarter snap

undo = -1
min_len = 0.01

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function sel_tr_items_in_area (tr,x,y)

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

  SaveSelTracks()
  local ts_start, ts_end = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
  r.GetSet_LoopTimeRange(1, 0, x, y, 0)

  r.SetOnlyTrackSelected(tr,1)
  r.Main_OnCommand(40718,0) -- Select all items on selected tracks in current time selection

  RestoreSelTracks()
  r.GetSet_LoopTimeRange(1, 0, ts_start, ts_end, 0)

end

function sel_items_area()

  min_pos = math.huge
  max_pos = 0
  for i = 1, items do
    item = r.GetSelectedMediaItem(0, i-1)

    item_pos = r.GetMediaItemInfo_Value(item, "D_POSITION")
    item_len = r.GetMediaItemInfo_Value(item, "D_LENGTH")
    min_pos = math.min(min_pos,item_pos)
    max_pos = math.max(max_pos,item_pos+item_len)
  end
  return min_pos,max_pos
end

function quadro_snap(item)
  it_start = r.GetMediaItemInfo_Value(item, 'D_POSITION')
  it_len = r.GetMediaItemInfo_Value(item, 'D_LENGTH')
  it_end = it_start + it_len

  for i = 0,1000 do
    local msr = r.TimeMap_GetMeasureInfo(0, i)
    if msr > it_start then
      msr_start = r.TimeMap_GetMeasureInfo(0, i-1)
      msr_d = msr-msr_start
      iter = i
    break end
  end

  for i = iter,1000 do
    local msr = r.TimeMap_GetMeasureInfo(0, i)
    if msr > it_end then
      msr_end = r.TimeMap_GetMeasureInfo(0, i-1)
    break end
  end

  log2 = function(x) return math.log(x)/math.log(2) end

  esc_div3 = function(x)
    for i = 0, 40 do
      if log2(x) == math.floor(log2(x)) then break end
      x = x+1
    end
    return x
  end


  if it_len < msr_d then
    x = msr_d/esc_div3(math.floor(msr_d/it_len+0.5))
    r.SetMediaItemInfo_Value(it, 'D_LENGTH',x)
  else r.SetMediaItemInfo_Value(item, 'D_LENGTH',msr_d*math.floor((it_len/msr_d)+0.5))
  end

end


items = r.CountSelectedMediaItems()
  
if items == 0 then bla() return end

it = r.GetSelectedMediaItem(0,0)
tr = r.GetMediaItem_Track(it)

it_len = r.GetMediaItemInfo_Value(it, "D_LENGTH")
if it_len < min_len then bla() return end


if items == 1 then
  r.Undo_BeginBlock()
  r.PreventUIRefresh(1)

  quadro_snap(it)

  
  min,max = sel_items_area()

  r.ApplyNudge(0, 0, 3, 20, -0.5, 0, 0)
  
  r.ApplyNudge(0, 0, 5, 20, 1, 0, 0)

  sel_tr_items_in_area (tr,min,max)
--]]
  r.PreventUIRefresh(-1)
  r.Undo_EndBlock('Stutter', -1)
  return

end


local min,max = sel_items_area()

r.Undo_BeginBlock()
r.PreventUIRefresh(1)
r.ApplyNudge(0, 0, 3, 20, -0.5, 0, 0)
r.ApplyNudge(0, 0, 5, 20, 1, 0, 0)

sel_tr_items_in_area (tr,min,max)

r.PreventUIRefresh(-1)
r.Undo_EndBlock('Stutter', undo)
