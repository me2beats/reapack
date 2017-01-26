-- @description Select only odd items
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end;

local items = r.CountSelectedMediaItems(0)
if items > 1 then
  tb = {}
  for i = 0, items-1 do
    if math.fmod (i, 2) == 0 then tb[#tb+1] = r.GetSelectedMediaItem(0,i) end
  end
  if #tb > 0 then
    r.Undo_BeginBlock(); r.PreventUIRefresh(111)
    r.Main_OnCommand(40289,0) -- unselect all items
    for i = 1, #tb do r.SetMediaItemSelected(tb[i], 1) end
    r.UpdateArrange()
    r.PreventUIRefresh(-111); r.Undo_EndBlock('Select only odd items', -1)
  else bla() end
else bla() end
