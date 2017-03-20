-- @description Duplicate items (fill time selection)
-- @version 1.1
-- @author me2beats
-- @changelog
--  + init
--  + Several items duplication

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function delete_sel_items_after_time(time)

  local x,y = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)

  local last_sel = r.GetSelectedMediaItem(0,r.CountSelectedMediaItems()-1)
  local last_sel_end = r.GetMediaItemInfo_Value(last_sel, 'D_POSITION') + r.GetMediaItemInfo_Value(last_sel, 'D_LENGTH')

  r.GetSet_LoopTimeRange(1, 0, time, last_sel_end+1, 0)
  r.Main_OnCommand(40061,0)--Item: Split items at time selection

  local items = r.CountSelectedMediaItems()
  for i = items-1, 0, -1 do
    local it = r.GetSelectedMediaItem(0,i)
    local it_pos = r.GetMediaItemInfo_Value(it, 'D_POSITION')
    if time-it_pos > 0.00001 then r.SetMediaItemSelected(it,0) end
  end

  r.Main_OnCommand(40006,0)--Item: Remove items

  r.GetSet_LoopTimeRange(1, 0, x, y, 0)
end

local x,y = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
if x == y then bla() return end

local first_sel = r.GetSelectedMediaItem(0,0)
if not first_sel then bla() return end

local cur = r.GetCursorPosition()

local last_sel = r.GetSelectedMediaItem(0,r.CountSelectedMediaItems()-1)
local first_sel_pos = r.GetMediaItemInfo_Value(first_sel, 'D_POSITION')
local last_sel_end = r.GetMediaItemInfo_Value(last_sel, 'D_POSITION') + r.GetMediaItemInfo_Value(last_sel, 'D_LENGTH')
local len = last_sel_end-first_sel_pos

r.Undo_BeginBlock() r.PreventUIRefresh(1)

local ret = r.ApplyNudge(0, 0, 0, 1, x-first_sel_pos, 0, 0)
for i = 1, math.floor((y-x)/len) do
  r.Main_OnCommand(41295,0)--Item: Duplicate items
end

delete_sel_items_after_time(y)

r.SetEditCurPos2(0, cur, 0, 0)

r.PreventUIRefresh(-1) r.Undo_EndBlock('Duplicate items', -1)
