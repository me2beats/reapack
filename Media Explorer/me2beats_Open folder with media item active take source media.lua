-- @description Open folder with media item active take source media
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

r.Undo_BeginBlock()

local it = r.GetSelectedMediaItem(0,0)
if not it then return end
local tk = r.GetActiveTake(it)
if not tk then return end
local src = r.GetMediaItemTake_Source(tk)
if not src then return end
local src_fn = r.GetMediaSourceFileName(src, '')

r.OpenMediaExplorer(src_fn, 0)

r.Undo_EndBlock('Open media in Media Explorer', 2)
