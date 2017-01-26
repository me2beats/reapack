-- @description Copy items positions
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end
bla()

local items = r.CountSelectedMediaItems()
if items == 0 then return end

local t = {}

for i = 0, items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  local item_start = r.GetMediaItemInfo_Value(item, 'D_POSITION')
  t[#t+1] = item_start
end

table:sort(t)

local s = ''

for i = 1, #t do s = s..t[i]..',' end

local sec, key = 'me2beats_copy-paste', 'items_positions'
if r.HasExtState(sec, key) then r.DeleteExtState(sec, key, 0) end
r.SetExtState(sec, key, s, 0)
