-- @description Remove items and select next item
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

local items = r.CountSelectedMediaItems()
if items == 0 then return end

local t = {}
items_to_del = {}

for i = 0, items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  local tr = r.GetMediaItem_Track(item)
  local tr_it_num = r.GetMediaItemInfo_Value(item, 'IP_ITEMNUMBER')
  items_to_del[#items_to_del+1] = {item,tr}
  t[tr] = tr_it_num
end

local t_items_to_sel = {}

for tr,i in pairs(t) do
  local item = r.GetTrackMediaItem(tr, i+1)
  if item then t_items_to_sel[#t_items_to_sel+1] = item end
end

if t_items_to_sel == 0 then return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 1, #items_to_del do
  local item,tr = items_to_del[i][1],items_to_del[i][2]
  r.DeleteTrackMediaItem(tr, item)
end

for i = 1, #t_items_to_sel do
  local item = t_items_to_sel[i]
  r.SetMediaItemSelected(item,1)
end

r.UpdateArrange()

r.PreventUIRefresh(-1) r.Undo_EndBlock('Remove items and select next item', -1)
