-- @description Toggle exclusive solo for selected tracks
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

tracks = r.CountTracks()
sel_tracks = r.CountSelectedTracks()

if tracks == 0 or sel_tracks == 0 then bla() return end 

r.Undo_BeginBlock()
r.PreventUIRefresh(1)
sel = r.GetMediaTrackInfo_Value(r.GetSelectedTrack(0,0), 'I_SOLO')
if sel == 0 then
  r.Main_OnCommand(40340,0) -- unsolo all tracks
  for i = 0, sel_tracks-1 do
    tr = r.GetSelectedTrack(0,i)
    r.SetMediaTrackInfo_Value(tr, 'I_SOLO', 2)
  end
else
  r.Main_OnCommand(40340,0) -- unsolo all tracks
end
r.PreventUIRefresh(-1)
r.Undo_EndBlock('Toggle exclusive solo for selected tracks', -1)
