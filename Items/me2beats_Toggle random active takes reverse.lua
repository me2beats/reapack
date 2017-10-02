-- @description Toggle random active takes reverse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

local t = {}

local sel_items = {}
local function SaveSelItems()
  for i = 0, r.CountSelectedMediaItems(0)-1 do
    sel_items[i+1] = r.GetSelectedMediaItem(0, i)
  end
end

local function RestoreSelItems()
  r.SelectAllMediaItems(0, 0) -- unselect all items
  for _, item in ipairs(sel_items) do
    if item then r.SetMediaItemSelected(item, 1) end
  end
end



function swap(array, index1, index2)
  array[index1], array[index2] = array[index2], array[index1]
end

function shuffle(array)
  local counter = #array
  while counter > 1 do
    local index = math.random(counter)
    swap(array, index, counter)
    counter = counter - 1
  end
end


function random_numbers_less_than(x)
  local t, t_res = {},{}
  for i = 1, x do t[#t+1] = i end

  shuffle(t)
  local max = math.random(x)
  for i = 1, max do t_res[#t_res+1] = t[i] end
  return t_res

end


local items = r.CountSelectedMediaItems()

local items = r.CountSelectedMediaItems()
if items == 0 then return end

SaveSelItems()

for i = 0, items-1 do
  local it = r.GetSelectedMediaItem(0,i)
  t[#t+1] = it
end

local t_nums = random_numbers_less_than(items)



r.Undo_BeginBlock(); r.PreventUIRefresh(1)


r.SelectAllMediaItems(0, 0) -- unselect all items

for i = 1, #t_nums do
  local it = t[t_nums[i]]
  r.SetMediaItemSelected(it,1)
end

r.Main_OnCommand(41051,0) --Item properties: Toggle take reverse
 
RestoreSelItems()


r.PreventUIRefresh(-1); r.Undo_EndBlock('Toggle random active takes reverse', -1)
