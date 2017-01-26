-- @description Duplicate items (fill time selection)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

x,y = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
if x == y then bla() return end

item = r.GetSelectedMediaItem(0,0)
if not item then bla() return end

it_len = r.GetMediaItemInfo_Value(item, 'D_LENGTH')

r.Undo_BeginBlock() r.PreventUIRefresh(1)

r.SetMediaItemInfo_Value(item, 'D_POSITION',x)
copies = math.floor((y-x)/it_len)
r.ApplyNudge(0, 0, 5, 20, 1, 0, copies)
item = r.GetSelectedMediaItem(0,0)
it_start = r.GetMediaItemInfo_Value(item, 'D_POSITION')

if it_start >= y-0.0000001 then
  tr = r.GetMediaItem_Track(item)
  del = r.DeleteTrackMediaItem(tr, item)
else
  r.SetMediaItemInfo_Value(item, 'D_LENGTH',y-it_start)
  r.SetMediaItemSelected(item,0)
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Duplicate items (fill time selection)', -1)
