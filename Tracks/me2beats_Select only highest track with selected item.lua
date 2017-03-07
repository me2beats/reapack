-- @description Select only highest track with selected item
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local items = r.CountSelectedMediaItems()
if items == 0 then bla() return end

min = 1000

for i = 0, items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  local tr = r.GetMediaItem_Track(item)
  local num = r.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER')
  min = math.min(min,num)
end

r.Undo_BeginBlock()
tr = r.GetTrack(0,min-1)
r.SetOnlyTrackSelected(tr,1)
r.SetMixerScroll(tr)
r.Main_OnCommand(40914,0) -- Track: Set first selected track as last touched track
r.Undo_EndBlock('Selected only highest track with sel item', -1)
