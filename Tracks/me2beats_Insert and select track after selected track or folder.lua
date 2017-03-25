-- @description Insert and select track after selected track or folder
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function last_tr_in_folder(folder_tr)
  last = nil
  local dep = r.GetTrackDepth(folder_tr)
  local num = r.GetMediaTrackInfo_Value(folder_tr, 'IP_TRACKNUMBER')
  local tracks = r.CountTracks()
  for i = num+1, tracks do
    if r.GetTrackDepth(r.GetTrack(0,i-1)) <= dep then last = r.GetTrack(0,i-2) last_num = i-2 break end
  end
  if last == nil then last = r.GetTrack(0, tracks-1) last_num = tracks-1 end
  return last, last_num 
end


local tr = r.GetSelectedTrack(0,0)
if not tr then bla() return end

local tr_is_folder = r.GetMediaTrackInfo_Value(tr, 'I_FOLDERDEPTH')==1

r.Undo_BeginBlock()
r.PreventUIRefresh(1)

if tr_is_folder then
  _,num = last_tr_in_folder(tr)
  num = num+1
else
  num = r.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER')
end

r.InsertTrackAtIndex(num,1)
tr = r.GetTrack(0, num)
r.SetOnlyTrackSelected(tr,1)
r.TrackList_AdjustWindows(0)
r.UpdateArrange()

r.Main_OnCommand(40914,0) -- Track: Set first selected track as last touched track

r.PreventUIRefresh(-1)
r.Undo_EndBlock('Insert track after selected track or folder', -1)
