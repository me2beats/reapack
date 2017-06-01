-- @description Select items from start of project to mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

t = {}
local window, segment, details = r.BR_GetMouseCursorContext()
local mouse = r.BR_GetMouseCursorContext_Position()
if not mouse or mouse ==-1 then bla() return end
local items = r.CountMediaItems()

for i = 0, items-1 do
  local item = r.GetMediaItem(0, i)
  local it_start = r.GetMediaItemInfo_Value(item, 'D_POSITION')
  if it_start+0.000001 < mouse then t[#t+1] = item end
end
if #t == 0 then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 1,#t do r.SetMediaItemSelected(t[i],1); r.UpdateItemInProject(t[i]) end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Select items from start of project to mouse', -1)
