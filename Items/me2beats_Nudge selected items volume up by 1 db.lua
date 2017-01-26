-- @description Nudge selected items volume up by 1 db
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local db = 1

local r = reaper; function nothing() end; function bla() r.defer(nothing) end

local items = r.CountSelectedMediaItems(0)
if items > 0 then
  db = tonumber(db)
  if db then
    r.Undo_BeginBlock(); r.PreventUIRefresh(111)
    for j = 0, items-1 do
      local it = r.GetSelectedMediaItem(0, j)
      it_vol = r.GetMediaItemInfo_Value(it, 'D_VOL')
      r.SetMediaItemInfo_Value(it, 'D_VOL', it_vol*10^(0.05*db))
      r.UpdateItemInProject(it)
    end        
    r.PreventUIRefresh(-111); r.Undo_EndBlock('Nudge sel items volume up by 1 db', -1)
  else bla() end
else bla() end
