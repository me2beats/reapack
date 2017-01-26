-- @description Invert item selection on selected track
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end

tr = reaper.GetSelectedTrack(0,0)
if tr then
  tr_items = reaper.CountTrackMediaItems(tr)
  if tr_items > 0 then
    reaper.Undo_BeginBlock()
    
    for i = 0, tr_items-1 do
      item = reaper.GetTrackMediaItem(tr, i)
      selected = reaper.IsMediaItemSelected(item)
      reaper.SetMediaItemSelected(item, not selected)
    end
    reaper.UpdateArrange()
    reaper.Undo_EndBlock('invert item selection on sel tr', -1)
  else reaper.defer(nothing) end
else reaper.defer(nothing) end
