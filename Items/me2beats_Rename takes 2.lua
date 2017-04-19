-- @description Rename takes 2
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local items = r.CountSelectedMediaItems()
if items == 0 then bla() return end

local first_it = r.GetSelectedMediaItem(0,0)
local active_tk = r.GetActiveTake(first_it)
local default_name
if not active_tk then default_name = ''
else _,default_name = r.GetSetMediaItemTakeInfo_String(active_tk, 'P_NAME', '', 0) end


local retval, name = r.GetUserInputs("New selected items takes names", 1, "New name:", default_name)
if retval ~= true then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 0, items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  local takes = r.GetMediaItemNumTakes(item)
  for j = 0, takes-1 do
    local take = r.GetTake(item,j)
    r.GetSetMediaItemTakeInfo_String(take, 'P_NAME', name, 1)
  end
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Rename takes', -1)
