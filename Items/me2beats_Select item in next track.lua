-- @description Select item in next track
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

r.Undo_BeginBlock() r.PreventUIRefresh(1)

local cur = r.GetCursorPosition()
r.Main_OnCommand(40419,0) -- Item navigation: Select and move to item in next track
r.SetEditCurPos2(0, cur, 0, 0)

r.PreventUIRefresh(-1) r.Undo_EndBlock('Select item in next track', -1)
