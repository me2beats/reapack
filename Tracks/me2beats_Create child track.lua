-- @description Create child track
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local tr = r.GetSelectedTrack(0,0)
if not tr then bla() return end

local dep = r.GetMediaTrackInfo_Value(tr, 'I_FOLDERDEPTH')

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

r.PreventUIRefresh(-1) r.Undo_EndBlock('Create child track', -1)

