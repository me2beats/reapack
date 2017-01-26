-- @description Split items in half
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end
items = r.CountSelectedMediaItems()
if items > 0 then
  r.Undo_BeginBlock()
  for i = items-1, 0, -1 do
    item = r.GetSelectedMediaItem(0,i)
    item_start = r.GetMediaItemInfo_Value(item, 'D_POSITION')
    it_len = r.GetMediaItemInfo_Value(item, 'D_LENGTH')
    r.SplitMediaItem(item, item_start+it_len/2)
  end
  r.UpdateArrange()
  r.Undo_EndBlock('slit items in half', -1)

else bla() end
