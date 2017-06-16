-- @description Create folder from each selected track
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local t = {}

local tracks = r.CountSelectedTracks()
if tracks == 0 then bla() return end


function create_folder(tr,last)

  local dep, new_tr,tr_num
  tr_num = r.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER')

  dep = r.GetMediaTrackInfo_Value(tr, 'I_FOLDERDEPTH')
  if dep == 1 then return end

  r.InsertTrackAtIndex(tr_num-1, 1)
  r.TrackList_AdjustWindows(0)
  new_tr = r.GetTrack(0, tr_num-1)

  r.SetMediaTrackInfo_Value(new_tr, 'I_FOLDERDEPTH', 1)
  r.SetMediaTrackInfo_Value(tr, 'I_FOLDERDEPTH', dep-1)

end

for i = 1, tracks do t[i] = r.GetSelectedTrack(0,i-1) end


r.Undo_BeginBlock()r.PreventUIRefresh(1)
for i = 1, #t do create_folder(t[i]) end
r.PreventUIRefresh(-1) r.Undo_EndBlock('Create folder from selected tracks', -1)
