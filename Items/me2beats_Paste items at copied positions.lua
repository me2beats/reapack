-- @description Paste items at copied positions
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local sec, key = 'me2beats_copy-paste', 'items_positions'

item_positions = r.GetExtState(sec, key)
if not item_positions then bla() return end

items = r.CountSelectedMediaItems()
if items == 0 then return end

t = {}

for i = 0, items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  t[#t+1] = item
end

i = 1

r.Undo_BeginBlock()

for pos in item_positions:gmatch'(.-),' do
  if t[i] then r.SetMediaItemInfo_Value(t[i], 'D_POSITION',pos) end
  i = i+1
end

r.Undo_EndBlock('paste items at copied positions', -1)
