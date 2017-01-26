-- @description Select tracks from selected track to last one (but hidden tracks)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end

-- SAVE INITIAL TRACKS SELECTION
local function SaveSelectedTracks (table)
  for i = 0, reaper.CountSelectedTracks(0)-1 do table[i+1] = reaper.GetSelectedTrack(0, i) end
end

-- RESTORE INITIAL TRACKS SELECTION
local function RestoreSelectedTracks (table)
  reaper.Main_OnCommand(40297, 0) -- Unselect all tracks
  for _, track in ipairs(table) do reaper.SetTrackSelected(track, true) end
end

tr = reaper.GetSelectedTrack(0,0)
if tr ~= nil then
  reaper.Undo_BeginBlock(); reaper.PreventUIRefresh(111)
  t1 = {}
  sel_tr_num = reaper.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER')
  for t = sel_tr_num, reaper.CountTracks(0)-1 do
    track = reaper.GetTrack(0,t);
    if reaper.GetMediaTrackInfo_Value(track, 'B_SHOWINMIXER') == 1 and reaper.GetMediaTrackInfo_Value(track, 'B_SHOWINTCP') == 1 then
      reaper.SetTrackSelected(track, 1)
    end
  end
  SaveSelectedTracks (t1)
  reaper.SetOnlyTrackSelected(track)
  reaper.Main_OnCommand(40913, 0) -- vertical scroll sel track into view
  RestoreSelectedTracks (t1)
  reaper.PreventUIRefresh(-111)
  reaper.Undo_EndBlock('Select tracks from selected track to last one', -1)  
else reaper.defer(nothing) end
