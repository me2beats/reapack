-- @description Record
-- @version 1.1
-- @author me2beats
-- @changelog
--  + fix

local r = reaper

r.Undo_BeginBlock()

local play_st = r.GetPlayState()
if play_st == 4 or play_st == 5  then -- (record)

  r.Main_OnCommand(1013,0) -- record
  r.Main_OnCommand(1016,0) -- stop

  local items = r.CountSelectedMediaItems()
  for i = 0, items-1 do

    local item = r.GetSelectedMediaItem(0,i)
    local takes= r.GetMediaItemNumTakes(item)

    for j = 0, takes-1 do
      local take = r.GetTake(item,j)
  
      if r.TakeIsMIDI(take) then
        r.MIDI_SetNote(take, 1, 0, nil, nil, nil, nil, nil, nil) -- unselect first note
      end
    end
  end

else
  r.Main_OnCommand(1013,0) -- record
end

r.Undo_EndBlock('Record', -1)