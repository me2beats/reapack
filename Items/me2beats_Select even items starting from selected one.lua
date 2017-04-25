-- @description Select even items starting from selected one
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function Elem_in_tb(elem,tb)
  local found
  for eit = 1, #tb do if tb[eit] == elem then found = 1 break end end
  if found then return 1 end
end

t = {}

local items = r.CountSelectedMediaItems()
if items == 0 then bla() return end

for i = 0, items-1 do
  local it = r.GetSelectedMediaItem(0,i)
  local tr = r.GetMediaItem_Track(it)
  if not Elem_in_tb(tr,t) then t[#t+1] = tr end
  if #t>1 then break end
end

if #t ~= 1 then bla() return end

local first_sel = r.GetSelectedMediaItem(0,0)


local tr = t[1]

local tr_items = r.CountTrackMediaItems(tr)

for i = 0, tr_items-1 do
  local tr_item = r.GetTrackMediaItem(tr, i)
  if first_sel==tr_item then iter = i break end
end

if not iter then bla() return end -- ??

r.Undo_BeginBlock() r.PreventUIRefresh(1)

r.Main_OnCommand(40289,0) -- unselect items


for i = iter, tr_items-2,2 do
  local tr_item = r.GetTrackMediaItem(tr, i+1)
  r.SetMediaItemSelected(tr_item,1)
end

r.UpdateArrange()

r.PreventUIRefresh(-1) r.Undo_EndBlock('Select even items starting from selected one', -1)
