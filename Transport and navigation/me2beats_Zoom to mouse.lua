-- @description Zoom to mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper


h = 8
w = 20


------------------------------------save-restore sel tracks
local sel_tracks = {}

local function SaveSelTracks()
  for i = 0, r.CountSelectedTracks(0)-1 do
    sel_tracks[i+1] = r.GetSelectedTrack(0, i)
  end
end

local function UnselectAllTracks()
  local first_track = reaper.GetTrack(0, 0)
  r.SetOnlyTrackSelected(first_track)
  r.SetTrackSelected(first_track, false)
end

local function RestoreSelTracks()

  UnselectAllTracks()

  for _, track in ipairs(sel_tracks) do
    r.SetTrackSelected(track, 1)
  end
end
-------------------------------------------------------------


local mouse_tr = r.BR_TrackAtMouseCursor()
if not mouse_tr then return end

SaveSelTracks()

r.Undo_BeginBlock()
r.PreventUIRefresh(1)

r.SetOnlyTrackSelected(mouse_tr)
r.Main_OnCommand(40914,0) --Track: Set first selected track as last touched track

r.CSurf_OnZoom(0, -10000)
r.CSurf_OnZoom(0, h)

local window, segment, details = r.BR_GetMouseCursorContext()
local mouse = r.BR_GetMouseCursorContext_Position()

r.BR_SetArrangeView(0, mouse-w, mouse+w)

r.PreventUIRefresh(-1)

r.Main_OnCommand(40913,0) -- Track: Vertical scroll selected tracks into view

RestoreSelTracks()

r.Undo_EndBlock('Zoom', 2)
