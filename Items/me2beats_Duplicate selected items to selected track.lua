-- @description Duplicate selected items to selected track
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local items = r.CountSelectedMediaItems(0)
if items > 0 then
  local tracks = r.CountSelectedTracks(0)
  
  r.Undo_BeginBlock(); r.PreventUIRefresh(1)
  
  for y = 0, tracks-1 do
    local tr = r.GetSelectedTrack(0,y)
    local tr_num = r.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER')
    local more = 0
    local less = 0
    
    for i_0 = 0, items-1 do
      local it_0 = r.GetSelectedMediaItem(0, i_0)
      local tr_0 = r.GetMediaItemTrack(it_0)
      local tr_0_num = r.GetMediaTrackInfo_Value(tr_0, 'IP_TRACKNUMBER')
      if tr_num > tr_0_num then more = 1 end
      if tr_num < tr_0_num then less = 1 end
    end
    if more == 1 and less == 1 then
      r.MB("Can't do this. My coder will fix this later.", '', 0)
    elseif more+less == 1 then 
      ok = 1
      if r.GetToggleCommandState(41117) == 1 then  -- check 'trim behind items'
        local trim = 1
        r.Main_OnCommand(41117, 0)
      end
      r.ApplyNudge(0, 0, 5, 0, 1, 0, 0)
      for i = 0, items-1 do
        if more == 0 then x = i else x = 0 end
        local it = r.GetSelectedMediaItem(0, x)
        r.MoveMediaItemToTrack(it, tr)
      end
      r.ApplyNudge(0, 0, 0, 0, -1, 0, 0)
      if trim == 1 then r.Main_OnCommand(41117, 0) end
    end
  end
  if ok then
    r.Main_OnCommand(40289, 0)-- unselect all items
    r.UpdateArrange()
    ok = nil
  end
  
  r.PreventUIRefresh(-1); r.Undo_EndBlock('Duplicate selected items to selected track', -1)
else bla() end
