-- @description Set crossfade shape to type 2
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local items = r.CountSelectedMediaItems()
if items ~= 2 then bla() return end


local item1 = r.GetSelectedMediaItem(0,0)
local item2 = r.GetSelectedMediaItem(0,1)

r.Undo_BeginBlock()

r.SetMediaItemInfo_Value(item1, 'C_FADEOUTSHAPE', 1)
r.SetMediaItemInfo_Value(item2, 'C_FADEINSHAPE', 1)

r.UpdateItemInProject(item1)
r.UpdateItemInProject(item2)

r.Undo_EndBlock('set crossfade shape to type 2', -1)
