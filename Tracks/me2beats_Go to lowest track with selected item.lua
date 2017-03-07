-- @description Go to lowest track with selected item
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local items = r.CountSelectedMediaItems()
if items == 0 then bla() return end

max = 0

for i = 0, items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  local tr = r.GetMediaItem_Track(item)
  local num = r.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER')
  max = math.max(max,num)
end

r.Undo_BeginBlock()
tr = r.GetTrack(0,max-1)
r.SetOnlyTrackSelected(tr,1)
r.Main_OnCommand(40914,0) -- Track: Set first selected track as last touched track
r.Main_OnCommand(40913,0) -- Track: Vertical scroll selected tracks into view
r.SetMixerScroll(tr)

r.Undo_EndBlock('Selected only the lowest track with sel item', -1)
