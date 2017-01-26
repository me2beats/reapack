-- @description Select take (by name)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end

items = reaper.CountSelectedMediaItems(0)
if items > 0 then
  retval, input_take_name = reaper.GetUserInputs("Select take", 1, "Take name:", "")
  if retval == true then 

    reaper.Undo_BeginBlock()

    for i = 0, items-1 do
      it = reaper.GetSelectedMediaItem(0, i)
      takes = reaper.CountTakes(it)
      for t = 0, takes-1 do
        take = reaper.GetTake(it, t)
        retval, take_name = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", '', false) -- get take name
        if take_name == input_take_name then
          reaper.SetActiveTake(take)
          break
        end
      end
      reaper.UpdateItemInProject(it)
    end
    reaper.Undo_EndBlock('Select take (by name)', -1)
  else
    reaper.defer(nothing)
  end
else
  reaper.defer(nothing)
end
