-- @description Unselect items less than 1%32 grid size
-- @version 1.02
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local items = r.CountSelectedMediaItems()
if items == 0 then bla() return end

t = {}

for i = 0, items-1 do
  local it = r.GetSelectedMediaItem(0,i)
  local it_len = r.GetMediaItemInfo_Value(it, 'D_LENGTH')
  
  local it_start = r.GetMediaItemInfo_Value(r.GetSelectedMediaItem(0,0), 'D_POSITION')
  local next_gr = r.BR_GetNextGridDivision(it_start+0.000003)
  local prev_gr = r.BR_GetPrevGridDivision(it_start+0.000003)
  local grid = next_gr-prev_gr
  
  if it_len<grid/32 then t[#t+1]=it end
end

if #t ==0 then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 1, #t do
  r.SetMediaItemSelected(t[i],0)
  r.UpdateItemInProject(t[i])
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Unselect items less than 1/32 grid size', -1)
