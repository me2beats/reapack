-- @description Set items fade out to default length
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

local function read_only (file)
  local file_open = io.open(file, 'r'); local data = file_open:read('*a'); file_open:close(); return data
end

local items = r.CountSelectedMediaItems()
if items == 0 then return end

local ini = r.get_ini_file()
local data = read_only (ini)
if not data then r.MB("Can't get ini file data",'',0) return end

local len = data:match'\ndeffadelen=(.-)\n'
len = tonumber(len)
if not len then r.MB("conveting error",'',0) return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 0, items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  r.SetMediaItemInfo_Value(item, 'D_FADEOUTLEN',len)
  r.UpdateItemInProject(item)
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Set items fade out to default length', -1)

