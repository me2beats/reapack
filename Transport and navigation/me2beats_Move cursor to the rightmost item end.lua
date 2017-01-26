-- @description Move cursor to the rightmost item end
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end


local items = r.CountMediaItems()
if items == 0 then bla() return end

local cur = r.GetCursorPosition()

local z = 0

for i = 0, items-1 do
  local item = r.GetMediaItem(0,i)
  local it_start = r.GetMediaItemInfo_Value(item, 'D_POSITION')
  local it_len = r.GetMediaItemInfo_Value(item, 'D_LENGTH')
  local it_end = it_start + it_len
  if it_end > z then z = it_end end
end

if cur == z then bla() return end
r.Undo_BeginBlock()
r.SetEditCurPos(z, 0, 0)
r.Undo_EndBlock('Move cursor to the rightmost item end', 2)
