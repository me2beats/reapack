-- @description View - scroll to end of tracklist
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper
r.Undo_BeginBlock()
r.CSurf_OnScroll(0,1000000)
r.Undo_EndBlock('Scroll to end of tracklist', 2)
