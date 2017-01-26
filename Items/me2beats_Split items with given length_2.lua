-- @description Split items with given length_2
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end;

function split_2(old_item,item)
  r.SetMediaItemSelected(old_item,0)

  local pos = r.GetMediaItemInfo_Value(item, 'D_POSITION')
  local len = r.GetMediaItemInfo_Value(item, 'D_LENGTH')
  
  r.ApplyNudge(0, 1, 1, 1, pos+silence, 0, 0)
  
  local pos = r.GetMediaItemInfo_Value(item, 'D_POSITION')
  local len = r.GetMediaItemInfo_Value(item, 'D_LENGTH')
  if wanted_len >= len then
    tr = r.GetMediaItem_Track(old_item)
    r.DeleteTrackMediaItem(tr, item)
  return end
  old_item = item
  item = r.SplitMediaItem(item, wanted_len+pos)
  if not item then
    tr = r.GetMediaItem_Track(old_item)
    r.DeleteTrackMediaItem(tr, item)
  return end
  split_2(old_item,item)
end

local items = r.CountSelectedMediaItems()
if items == 0 then bla() return end

local retval, retvals_csv = r.GetUserInputs("Split items", 2, "Length (ms):,Silence (ms):", ",")
wanted_len, silence = retvals_csv:match('(.*),(.*)')

if retval == false then bla() return end

wanted_len,silence = tonumber(wanted_len), tonumber(silence)
if not (wanted_len and silence) then bla() return end

wanted_len, silence = wanted_len/1000, silence/1000

r.Undo_BeginBlock()

r.PreventUIRefresh(1)

for i = 0, items-1 do
  old_item = r.GetSelectedMediaItem(0,i)
  
  local pos = r.GetMediaItemInfo_Value(old_item, 'D_POSITION')
  local len = r.GetMediaItemInfo_Value(old_item, 'D_LENGTH')
  if wanted_len >= len then return end
  item = r.SplitMediaItem(old_item, wanted_len+pos)
  
  split_2(old_item,item)
end

r.UpdateArrange()

r.PreventUIRefresh(-1)
r.Undo_EndBlock('Split items with given length_2', -1)

