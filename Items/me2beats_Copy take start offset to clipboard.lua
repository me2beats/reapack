-- @description Copy take start offset to clipboard
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

local item = r.GetSelectedMediaItem(0,0)
if not item then return end

local take = r.GetActiveTake(item)
if not take then return end

local offs = r.GetMediaItemTakeInfo_Value(take, 'D_STARTOFFS')

if offs ~= 0 then offs = round(offs, 3) end

r.CF_SetClipboard(offs)
