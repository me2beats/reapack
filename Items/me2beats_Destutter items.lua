-- @description Destutter items
-- @version 1.01
-- @author me2beats
-- @changelog
--  + init
--  + minor update

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end;

local items = r.CountSelectedMediaItems(0)
if items <= 1 then bla() return end

it = r.GetSelectedMediaItem(0,0)
tr = r.GetMediaItem_Track(it)

r.Undo_BeginBlock(); r.PreventUIRefresh(111)
tb = {}
for i = 0, items-1 do
  if math.fmod (i, 2) ~= 0 then tb[#tb+1] = r.GetSelectedMediaItem(0,i) end
end
if #tb > 0 then
  for i = 1, #tb do r.DeleteTrackMediaItem(tr,tb[i]) end
  r.UpdateArrange()
end

r.ApplyNudge(0, 0, 3, 20, 1, 0, 0)

r.PreventUIRefresh(-111); r.Undo_EndBlock('Destutter', -1)
