-- @description Remove item under mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end

item = reaper.BR_ItemAtMouseCursor()
if item then
  reaper.Undo_BeginBlock()
  tr = reaper.GetMediaItem_Track(item)
  reaper.DeleteTrackMediaItem(tr, item)
  reaper.UpdateArrange()
  reaper.Undo_EndBlock('remove item under mouse', -1)
else reaper.defer(nothing) end
