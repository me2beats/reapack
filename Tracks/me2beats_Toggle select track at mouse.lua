-- @description Toggle select track at mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local mouse_tr = r.BR_TrackAtMouseCursor()
if not mouse_tr then bla() return end

local sel = r.IsTrackSelected(mouse_tr)

r.Undo_BeginBlock() r.PreventUIRefresh(1)

r.SetTrackSelected(mouse_tr,not sel)

r.PreventUIRefresh(-1) r.Undo_EndBlock('Toggle select track at mouse', 2)
