-- @description Nudge selected items volume
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

items = r.CountSelectedMediaItems(0)
if items > 0 then
  retval, delta_db = r.GetUserInputs("Nudge volume", 1, "Nudge volume, dB:", "")
  if retval == true then 
    r.Undo_BeginBlock()
    for i = 0, items-1 do
      it = r.GetSelectedMediaItem(0, i)
      vol = r.GetMediaItemInfo_Value(it, 'D_VOL')
      r.SetMediaItemInfo_Value(it, 'D_VOL', vol*10^(0.05*delta_db))
      r.UpdateItemInProject(it)
    end
    r.Undo_EndBlock('Nudge active take volume', -1)
  else bla() end
else bla() end
