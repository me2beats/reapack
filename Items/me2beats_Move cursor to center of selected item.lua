-- @description Move cursor to center of selected item
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local item = r.GetSelectedMediaItem(0,0)
if not item then bla() return end
local pos = r.GetMediaItemInfo_Value(item, 'D_POSITION')
local len = r.GetMediaItemInfo_Value(item, 'D_LENGTH')

r.Undo_BeginBlock()

r.SetEditCurPos2(0, len/2+pos, 0, 0)

r.Undo_EndBlock('Move cursor to center of selected item', -1)
