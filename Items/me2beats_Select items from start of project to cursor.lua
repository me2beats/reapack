-- @description Select items from start of project to cursor
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

t = {}
local cur = r.GetCursorPosition()
local items = r.CountMediaItems()

for i = 0, items-1 do
  local item = r.GetMediaItem(0, i)
  local it_start = r.GetMediaItemInfo_Value(item, 'D_POSITION')
  if it_start+0.000001 < cur then t[#t+1] = item end
end
if #t == 0 then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 1,#t do r.SetMediaItemSelected(t[i],1); r.UpdateItemInProject(t[i]) end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Select items from start of project to cursor', -1)
