-- @description Move selected items to next track
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local items = r.CountSelectedMediaItems()
if items == 0 then bla() return end

local item0 = r.GetSelectedMediaItem(0,0)
it_tr0 = r.GetMediaItem_Track(item0)

t = {}

for i = 0, items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  t[#t+1] = item
  it_tr = r.GetMediaItem_Track(item)
  if it_tr ~= it_tr0 then oops = 1 break end
end

if oops then bla() return end

tr = r.GetTrack(0,r.GetMediaTrackInfo_Value(it_tr0, 'IP_TRACKNUMBER'))
if not tr then bla() return end

r.Undo_BeginBlock()

for i = 1, #t do r.MoveMediaItemToTrack(t[i],tr) end

r.UpdateArrange()

r.Undo_EndBlock('Move selected items to next track', -1)
