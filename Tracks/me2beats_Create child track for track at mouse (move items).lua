-- @description Create child track for track at mouse (move items)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local tr = r.BR_TrackAtMouseCursor()
if not tr then bla() return end

local dep = r.GetMediaTrackInfo_Value(tr, 'I_FOLDERDEPTH')

local t = {}

local tr_items = r.CountTrackMediaItems(tr)
for i = 0, tr_items-1 do
  local tr_item = r.GetTrackMediaItem(tr, i)
  t[#t+1] = tr_item
end

r.Undo_BeginBlock(); r.PreventUIRefresh(1)

local num = r.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER')
r.InsertTrackAtIndex(num,1)
local new_tr = r.GetTrack(0, num)
r.TrackList_AdjustWindows(0)
r.UpdateArrange()

if dep ~= 1 then
    r.SetMediaTrackInfo_Value(tr, 'I_FOLDERDEPTH', 1)
    r.SetMediaTrackInfo_Value(new_tr, 'I_FOLDERDEPTH', dep-1)
else end

for i = 1, #t do
  r.MoveMediaItemToTrack(t[i], new_tr)
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Create child track', -1)

