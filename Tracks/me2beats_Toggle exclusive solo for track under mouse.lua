-- @description Toggle exclusive solo for track under mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local undo = 2

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

tracks = r.CountTracks()
mouse_tr = r.BR_TrackAtMouseCursor()

if not mouse_tr or tracks == 0 then bla() return end 

r.Undo_BeginBlock()
r.PreventUIRefresh(1)
sel = r.GetMediaTrackInfo_Value(mouse_tr, 'I_SOLO')
if sel == 0 then
  r.Main_OnCommand(40340,0) -- unsolo all tracks
  r.SetMediaTrackInfo_Value(mouse_tr, 'I_SOLO', 2)
else
  r.Main_OnCommand(40340,0) -- unsolo all tracks
end
r.PreventUIRefresh(-1)
r.Undo_EndBlock('Toggle exclusive solo for track under mouse', undo)
