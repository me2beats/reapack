-- @description Select tracks - Shift+Up 2
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

function set_last_touched(tr)

  local function UnselectAllTracks()
    local first_track = r.GetTrack(0, 0)
    r.SetOnlyTrackSelected(first_track)
    r.SetTrackSelected(first_track, 0)
  end

  local function SaveSelTracks()
    sel_tracks = {}
    for i = 0, r.CountSelectedTracks()-1 do
      sel_tracks[i+1] = r.GetSelectedTrack(0, i)
    end
  end

  local function RestoreSelTracks()
    UnselectAllTracks()
    for _, track in ipairs(sel_tracks) do
      r.SetTrackSelected(track, 1)
    end
  end


  SaveSelTracks()
  r.SetOnlyTrackSelected(tr,1)
  r.Main_OnCommand(40914,0) -- Track: Set first selected track as last touched track
  RestoreSelTracks()
end


local last_touched = r.GetLastTouchedTrack()
local last_touched_num = r.GetMediaTrackInfo_Value(last_touched, 'IP_TRACKNUMBER') 

local first_sel = r.GetSelectedTrack(0,0)
local last_sel = r.GetSelectedTrack(0,r.CountSelectedTracks()-1)

r.Undo_BeginBlock(); r.PreventUIRefresh(1)

if first_sel == last_sel then
  r.Main_OnCommand(40288,0) -- Track: Go to previous track (leaving other tracks selected)
else
  if last_sel == last_touched then
    r.SetTrackSelected(last_sel,0)
    local last_sel_num = r.GetMediaTrackInfo_Value(last_sel, 'IP_TRACKNUMBER')
    set_last_touched(r.GetTrack(0,last_sel_num-2))
  elseif first_sel == last_touched then
    r.Main_OnCommand(40288,0) -- Track: Go to previous track (leaving other tracks selected)
  end
end

r.PreventUIRefresh(-1); r.Undo_EndBlock('Select tracks', -1)
