-- @description Copy track name to clipboard
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper
local tr = r.GetSelectedTrack(0,0)
if not tr then return end
local _, tr_name = r.GetSetMediaTrackInfo_String(tr, 'P_NAME', '', 0)

r.Undo_BeginBlock()
r.CF_SetClipboard(tr_name)
r.Undo_EndBlock('Copy track name', 2)
