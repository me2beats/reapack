-- @description Duplicate tracks
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local tracks = r.CountSelectedTracks()
if tracks == 0 then bla() return end

if tracks == 1 then 

  r.Undo_BeginBlock() r.PreventUIRefresh(1)
  r.Main_OnCommand(40062,0) -- Track: Duplicate tracks
  r.PreventUIRefresh(-1) r.Undo_EndBlock('Duplicate tracks', -1)

return end

function SetLastTouchedTrack(tr)

  local function SaveSelTracks()
    sel_tracks = {}
    for i = 0, r.CountSelectedTracks()-1 do
      sel_tracks[i+1] = r.GetSelectedTrack(0, i)
    end
  end

  local function RestoreSelTracks()
    r.Main_OnCommand(40297,0) -- unselect all tracks
    for _, track in ipairs(sel_tracks) do
      r.SetTrackSelected(track, 1)
    end
  end

  SaveSelTracks()
  r.SetOnlyTrackSelected(tr)
  r.Main_OnCommand(40914,0) -- Track: Set first selected track as last touched track
  RestoreSelTracks()

end

last_touched_tr = r.GetLastTouchedTrack()

local last_sel = r.GetSelectedTrack(0, tracks-1)

r.Undo_BeginBlock() r.PreventUIRefresh(1)

SetLastTouchedTrack(last_sel)

r.Main_OnCommand(r.NamedCommandLookup('_S&M_COPYSNDRCV1'),0) -- SWS/S&M: Copy selected tracks (with routing)
r.Main_OnCommand(r.NamedCommandLookup('_BR_FOCUS_TRACKS'),0) -- SWS/BR: Focus tracks
r.Main_OnCommand(r.NamedCommandLookup('_S&M_PASTSNDRCV1'),0) -- SWS/S&M: Paste tracks (with routing) or items

r.PreventUIRefresh(-1) r.Undo_EndBlock('Duplicate tracks', -1)
