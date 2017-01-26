-- @description Vertical zoom to project
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

r = reaper

local tracks_tb = {}

local function SaveSelTracks ()
-- N: tracks_tb
  for i = 0, r.CountSelectedTracks(0)-1 do tracks_tb[i+1] = r.GetSelectedTrack(0, i) end
end

local function RestoreSelTracks ()
  r.Main_OnCommand(40297, 0) -- unselect all tracks
  for _, track in ipairs(tracks_tb) do r.SetTrackSelected(track, 1) end
end


r.Undo_BeginBlock()
r.PreventUIRefresh(1)
SaveSelTracks ()
r.Main_OnCommand(40296,0) -- select all tracks
r.Main_OnCommand(r.NamedCommandLookup('_SWS_VZOOMFIT'),0)
RestoreSelTracks ()
r.PreventUIRefresh(-1)
r.Undo_EndBlock('Vertical zoom to project', 2)
