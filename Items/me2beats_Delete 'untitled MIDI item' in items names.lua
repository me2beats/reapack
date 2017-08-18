-- @description Delete 'untitled MIDI item' in items names
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

local items = r.CountSelectedMediaItems()
if items == 0 then return end

for i = 0, items-1 do
  local it = r.GetSelectedMediaItem(0,i)
  local takes = r.GetMediaItemNumTakes(it)
  for k = 0, takes-1 do
    local take = r.GetTake(it,k)
    local _, name = r.GetSetMediaItemTakeInfo_String(take, 'P_NAME', '', 0)
    name = name:gsub('untitled MIDI item','')
    r.GetSetMediaItemTakeInfo_String(take, 'P_NAME', name, 1)
  end
end

r.PreventUIRefresh(-1); r.Undo_EndBlock("Delete 'untitled MIDI item' in items names", -1)
