-- @description Delete muted items from selected items
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local items = r.CountSelectedMediaItems()
if items == 0 then bla() return end

local t = {}

for i = 0, items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  if r.GetMediaItemInfo_Value(item, 'B_MUTE')==1 then
    t[#t+1]=item
  end
end

if #t == 0 then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 1, #t do
  local it = t[i]
  local tr = r.GetMediaItem_Track(it)
  r.DeleteTrackMediaItem(tr, it)
end

r.UpdateArrange()

r.PreventUIRefresh(-1) r.Undo_EndBlock('Delete muted items from selected items', -1)
