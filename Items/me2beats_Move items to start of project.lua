-- @description Move items to start of project
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local items = r.CountSelectedMediaItems()
if items == 0 then bla() return end

local min = math.huge
for i = 0, items-1 do
  local item = r.GetSelectedMediaItem(0,0)
  local it_start = r.GetMediaItemInfo_Value(item, 'D_POSITION')
  min = math.min(min,it_start)
end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

r.ApplyNudge(0, 0, 0, 1, -min, 0, 0)

r.PreventUIRefresh(-1) r.Undo_EndBlock('Move items to start of project', -1)
