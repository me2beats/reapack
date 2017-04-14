-- @description Split selected items according to first selected track items (delete gaps)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local items = r.CountSelectedMediaItems()
if items == 0 then bla() return end


local min = 1000

for i = 0, items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  local tr = r.GetMediaItem_Track(item)
  local num = r.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER')
  min = math.min(min,num)
end

local first_sel = r.GetTrack(0,min-1)

local first_sel_items = r.CountTrackMediaItems(first_sel)

function item_in_areas(item, ...)

  local pos0 = r.GetMediaItemInfo_Value(item, 'D_POSITION')
  local len0 = r.GetMediaItemInfo_Value(item, 'D_LENGTH')
  local end0 = pos0+len0
  
  local arg={...}
  for i = 1, #arg, 2 do
    local x,y = arg[i],arg[i+1]

    if pos0 <= x and end0 >= x+0.00001 or
       pos0 <= y-0.00001 and end0 >= y or
       pos0 >= x and end0 <= y then
       return 1
    end

  end
end

function Elem_in_tb(elem,tb)
  _found = nil
  for eit = 1, #tb do if tb[eit] == elem then _found = 1 break end end
  if _found then return 1 end
end

split_pos = {}
for i = 0, first_sel_items-1 do
  local tr_item = r.GetTrackMediaItem(first_sel, i)
  if r.IsMediaItemSelected(tr_item) then
    local pos0 = r.GetMediaItemInfo_Value(tr_item, 'D_POSITION')
    local len0 = r.GetMediaItemInfo_Value(tr_item, 'D_LENGTH')
    local end0 = pos0+len0
    split_pos[#split_pos+1] = pos0
    split_pos[#split_pos+1] = end0
  end
end

split_pos_sorted = split_pos
table.sort(split_pos_sorted)

s_tracks = {}

for i = 1, items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  local tr = r.GetMediaItem_Track(item)
  if tr ~= first_sel and not Elem_in_tb(tr,s_tracks) then
    s_tracks[#s_tracks+1] = tr
  end
end

split_items = {}

for i = 1, #s_tracks do
  local tr = s_tracks[i]
  
  local tr_items = r.CountTrackMediaItems(tr)
  for j = 0, tr_items-1 do
    local tr_item = r.GetTrackMediaItem(tr, j)
    split_items[#split_items+1] = tr_item
  end
end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 1, #split_items do
  for j = #split_pos,1,-1 do
    r.SplitMediaItem(split_items[i], split_pos_sorted[j])
  end
end


del = {}

for i = 1, #s_tracks do
  local tr = s_tracks[i]
  
  local tr_items = r.CountTrackMediaItems(tr)
  for j = 0, tr_items-1 do
    local tr_item = r.GetTrackMediaItem(tr, j)
    if not item_in_areas(tr_item, table.unpack(split_pos)) then
      del[tr_item] = tr
    end
  end
end

for item,tr in pairs(del) do r.DeleteTrackMediaItem(tr,item) end

r.UpdateArrange()

r.PreventUIRefresh(-1) r.Undo_EndBlock('Split selected track items according to first selected track items (delete gaps)', -1)
