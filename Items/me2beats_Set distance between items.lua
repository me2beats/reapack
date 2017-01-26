-- @description Set distance between items
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local d = 5000

local r = reaper

local items = r.CountSelectedMediaItems()
local t = {}

for i = 1, items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  local it_len = r.GetMediaItemInfo_Value(item, 'D_LENGTH')
  t[#t+1] = {item,it_len}
end

local item = r.GetSelectedMediaItem(0,0)
local it_start = r.GetMediaItemInfo_Value(item, 'D_POSITION')
local it_len = r.GetMediaItemInfo_Value(item, 'D_LENGTH')
x = it_start + it_len + d/1000

r.Undo_BeginBlock(); r.PreventUIRefresh(1)

for i = 1, #t do
  r.SetMediaItemInfo_Value(t[i][1], 'D_POSITION', x)
  x = x+t[i][2]+d/1000
end

r.PreventUIRefresh(-1); r.Undo_EndBlock('Set distance between items', -1)
