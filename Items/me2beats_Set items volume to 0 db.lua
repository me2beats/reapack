-- @description Set items volume to 0 db
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local items = r.CountSelectedMediaItems()
if items > 0 then
  r.Undo_BeginBlock()
  for i = 0, items-1 do
    local it = r.GetSelectedMediaItem(0,i)
    r.SetMediaItemInfo_Value(it, 'D_VOL', 1)
    r.UpdateItemInProject(it)
  end
  r.Undo_EndBlock('set items volume to 0 dB', -1)
else bla() end
