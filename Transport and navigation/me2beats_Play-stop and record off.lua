-- @description Play-stop and record off
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper


r.Undo_BeginBlock() r.PreventUIRefresh(1)

local play_st = r.GetPlayState()
if play_st == 4 or play_st == 5  then -- (record)
  r.Main_OnCommand(1013,0) -- record
  r.Main_OnCommand(1016,0) -- stop
  local items = r.CountSelectedMediaItems()
  for i = 0, items-1 do
  
    local item = r.GetSelectedMediaItem(0,i)
    local takes= r.GetMediaItemNumTakes(item)
  
    for j = 0, takes-1 do
      local take = r.GetActiveTake(item)
  
      if r.TakeIsMIDI(take) then
        r.MIDI_SetNote(take, 1, 0, nil, nil, nil, nil, nil, nil) -- unselect first note
      end
    end
  end
else
  r.Main_OnCommand(40044,0) -- Transport: Play/stop
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Play/stop and recoff', -1)
