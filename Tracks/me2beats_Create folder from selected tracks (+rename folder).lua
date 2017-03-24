-- @description Create folder from selected tracks (+rename folder)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function last_tr_in_folder (folder_tr)
  last = nil
  local dep = r.GetTrackDepth(folder_tr)
  local num = r.GetMediaTrackInfo_Value(folder_tr, 'IP_TRACKNUMBER')
  local tracks = r.CountTracks()
  for i = num+1, tracks do
    if r.GetTrackDepth(r.GetTrack(0,i-1)) <= dep then last = r.GetTrack(0,i-2) break end
  end
  if last == nil then last = r.GetTrack(0, tracks-1) end
  return last
end

sel_tracks = r.CountSelectedTracks()
if sel_tracks == 0 then bla() end

first_sel = r.GetSelectedTrack(0,0)
tr_num = r.GetMediaTrackInfo_Value(first_sel, 'IP_TRACKNUMBER')

last_sel = r.GetSelectedTrack(0,sel_tracks-1)
last_sel_dep = r.GetMediaTrackInfo_Value(last_sel, 'I_FOLDERDEPTH')
if last_sel_dep == 1 then last_tr = last_tr_in_folder(last_sel) else last_tr = last_sel end

r.Undo_BeginBlock()
r.PreventUIRefresh(1)

r.InsertTrackAtIndex(tr_num-1, 1)
r.TrackList_AdjustWindows(0)
tr = r.GetTrack(0, tr_num-1)

r.SetMediaTrackInfo_Value(tr, 'I_FOLDERDEPTH', 1)
r.SetMediaTrackInfo_Value(last_tr, 'I_FOLDERDEPTH', last_sel_dep-1)
r.SetOnlyTrackSelected(tr)
r.Main_OnCommand(40914,0) -- Track: Set first selected track as last touched track

r.PreventUIRefresh(-1)

r.Main_OnCommand(40913,0) -- Track: Vertical scroll selected tracks into view
r.Main_OnCommand(40696,0) -- Track: Rename last touched track

r.Undo_EndBlock('Create folder from selected tracks', -1)
