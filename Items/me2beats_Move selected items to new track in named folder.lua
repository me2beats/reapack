-- @description Move selected items to new track in named folder
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

my_tr_name = 'A'

case = 0

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local items = r.CountSelectedMediaItems() if items == 0 then bla() return end

local tracks = r.CountTracks()
if tracks == 0 then return end

function find_tr_with_name(name)
-- N: case

  for i = 0, tracks-1 do
    local tr = r.GetTrack(0,i)
    _, tr_name = r.GetSetMediaTrackInfo_String(tr, 'P_NAME', '', 0)
    if case == 0 then
      if tr_name:lower() == name:lower() then found = tr break end
    elseif case == 1 then
      if tr_name == name then found = tr break end
    end
  end

  return found
end

function insert_track_in_folder(folder)

  function last_tr_in_folder (folder_tr)
    last = nil
    local dep = r.GetTrackDepth(folder_tr)
    local num = r.GetMediaTrackInfo_Value(folder_tr, 'IP_TRACKNUMBER')
    local tracks = r.CountTracks()
    for i = num+1, tracks do
      if r.GetTrackDepth(r.GetTrack(0,i-1)) <= dep then last = r.GetTrack(0,i-2) break end
    end
    if not last then last = r.GetTrack(0, tracks-1) end
    return last
  end
  
  dep = r.GetMediaTrackInfo_Value(folder, 'I_FOLDERDEPTH')
  if dep == 1 then last_tr = last_tr_in_folder(folder) else last_tr = folder end
  
  last_tr_num = r.GetMediaTrackInfo_Value(last_tr, 'IP_TRACKNUMBER')
  last_tr_dep = r.GetMediaTrackInfo_Value(last_tr, 'I_FOLDERDEPTH')
  
  r.InsertTrackAtIndex(last_tr_num, 1)
  r.TrackList_AdjustWindows(0)
  new_tr = r.GetTrack(0, last_tr_num)

  if dep ~= 1 then
    r.SetMediaTrackInfo_Value(tr, 'I_FOLDERDEPTH', 1)
    r.SetMediaTrackInfo_Value(new_tr, 'I_FOLDERDEPTH', -1)
  else
    r.SetMediaTrackInfo_Value(last_tr, 'I_FOLDERDEPTH', last_tr_dep+1)
    r.SetMediaTrackInfo_Value(new_tr, 'I_FOLDERDEPTH', last_tr_dep)
  end
end


tr = find_tr_with_name(my_tr_name)
if not tr then bla() return end

t = {}

for i = 0, items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  t[#t+1] = item
end

r.Undo_BeginBlock()

insert_track_in_folder(tr)

for i = 1,#t do r.MoveMediaItemToTrack(t[i], new_tr) end
r.UpdateArrange()

r.Undo_EndBlock('Move items to new track in named folder', -1)
