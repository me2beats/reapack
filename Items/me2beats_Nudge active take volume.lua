-- @description Nudge active take volume
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end

items = reaper.CountSelectedMediaItems(0)
if items > 0 then
  retval, delta_db = reaper.GetUserInputs("Nudge volume", 1, "Nudge volume, dB:", "")
  if retval == true then 
    reaper.Undo_BeginBlock()
    for i = 0, items-1 do
      it = reaper.GetSelectedMediaItem(0, i)
      takes = reaper.CountTakes(it)
      for t = 0, takes-1 do
        take = reaper.GetTake(it, t)
        vol = reaper.GetMediaItemTakeInfo_Value(take, 'D_VOL')
        norm = 10^(0.05*delta_db)
        reaper.SetMediaItemTakeInfo_Value(take, 'D_VOL', vol*norm)
      end
      reaper.UpdateItemInProject(it)
    end
    reaper.Undo_EndBlock('Nudge active take volume', -1)
  else reaper.defer(nothing) end
else reaper.defer(nothing) end
