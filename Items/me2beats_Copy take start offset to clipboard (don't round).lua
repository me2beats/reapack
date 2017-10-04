-- @description Copy take start offset to clipboard (don't round)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

local item = r.GetSelectedMediaItem(0,0)
if not item then return end

local take = r.GetActiveTake(item)
if not take then return end

local offs = r.GetMediaItemTakeInfo_Value(take, 'D_STARTOFFS')

r.CF_SetClipboard(offs)
