-- @description Select take (by number)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end

items = reaper.CountSelectedMediaItems(0)
if items > 0 then
  _, input_take_number = reaper.GetUserInputs("Select take", 1, "Take number:", "")
  if type(tonumber(input_take_number)) == 'number' then 

    reaper.Undo_BeginBlock()
    
    input_take_number = tonumber(input_take_number)
    
    for i = 0, items-1 do
      it = reaper.GetSelectedMediaItem(0, i)
      wanted_take = reaper.GetTake(it, input_take_number-1)
      if wanted_take ~= nil then
        reaper.SetActiveTake(wanted_take)
        reaper.UpdateItemInProject(it)
      end
    end
    reaper.Undo_EndBlock('Select take (by number)', -1)
  else
    reaper.defer(nothing)
  end
else
  reaper.defer(nothing)
end
