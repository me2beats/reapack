-- @description Toggle auto solo when tracks selected
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init (use this script with Auto solo selected tracks!)

r = reaper

function esc_lite (str) str = str:gsub('%-', '%%-') return str end


local function SaveTracks ()
  sel_tracks = {}
  for i = 0, r.CountSelectedTracks(0)-1 do sel_tracks[i+1] = r.GetSelectedTrack(0, i) end
end

local function RestoreTracks ()
  r.Main_OnCommand(40297, 0) -- unselect all tracks
  for _, track in ipairs(sel_tracks) do r.SetTrackSelected(track, 1) end
end

local function SaveItems ()
  sel_items = {}
  for i = 0, r.CountSelectedMediaItems(0)-1 do sel_items[i+1] = r.GetSelectedMediaItem(0, i) end
end

local function RestoreItems ()
  r.Main_OnCommand(40289, 0) -- unselect all items
  for _, item in ipairs(sel_items) do r.SetMediaItemSelected(item, 1) end
end

function SaveCur() cur = r.GetCursorPosition() end

function RestoreCur() r.SetEditCurPos(cur, 0, 0) end


if not tr_with_data then

  tracks = r.CountTracks()

  for i = 0, tracks-1 do
    tr = r.GetTrack(0,i)
    _, tr_name = r.GetSetMediaTrackInfo_String(tr, 'P_NAME', '', 0)
    if tr_name == 'me2beats data' then tr_with_data = tr break end
  end

  if not tr_with_data then
    r.InsertTrackAtIndex(0, 0)
    r.TrackList_AdjustWindows(0)
    tr_with_data = r.GetTrack(0,0)
    r.GetSetMediaTrackInfo_String(tr_with_data, 'P_NAME', 'me2beats data', 1)
    tr_with_data = r.GetTrack(0,0)

    SaveTracks (); SaveItems (); SaveCur()

    r.SetOnlyTrackSelected(tr_with_data)

    r.Main_OnCommand(40914, 0) -- set first sel track as last touched track
    r.Main_OnCommand(40142, 0) -- insert empty item

    r.SetMediaTrackInfo_Value(tr_with_data, 'B_SHOWINMIXER', 0)
    r.SetMediaTrackInfo_Value(tr_with_data, 'B_SHOWINTCP', 0)

    RestoreTracks(); RestoreItems(); RestoreCur()

    r.Main_OnCommand(40914, 0) -- set first sel track as last touched track

  end

end

_, chunk = r.GetTrackStateChunk(tr_with_data, '', 0)

notes = chunk:match'\n<NOTES\n|(.-)\n>'

if not notes then

  before, after = chunk:match'(.*\nIID.-\n)(.*)'

  tr_guids_str = ''
  for i = 0, r.CountSelectedTracks()-1 do
    tr = r.GetSelectedTrack(0,i)
    if tr ~= tr_with_data then
      tr_guid = r.BR_GetMediaTrackGUID(tr)
      tr_guids_str = tr_guids_str..tr_guid..'1 '
      
      sol = r.GetMediaTrackInfo_Value(tr, 'I_SOLO')
      if sol == 0 then r.SetMediaTrackInfo_Value(tr, 'I_SOLO', 2) end
      
    end
  end

  add_notes = '<NOTES\n|+ '..tr_guids_str..'\n>\n'

  r.SetTrackStateChunk(tr_with_data, before..add_notes..after, 0)

  return

end


for i = 0, r.CountSelectedTracks()-1 do
  tr = r.GetSelectedTrack(0,i)
  if tr ~= tr_with_data then
    tr_guid = r.BR_GetMediaTrackGUID(tr)
    if notes:match(esc_lite (tr_guid)) then
      notes = notes:gsub(esc_lite (tr_guid)..'1 ','')
      notes = notes:gsub(esc_lite (tr_guid)..'0 ','')
    else
      notes = notes..tr_guid..'1 '
      sol = r.GetMediaTrackInfo_Value(tr, 'I_SOLO')
      if sol == 0 then r.SetMediaTrackInfo_Value(tr, 'I_SOLO', 2) end
    end
  end
end


before, after = chunk:match'(.*\n<NOTES\n).-(\n.*)'

new = before..'|'..notes..after

r.SetTrackStateChunk(tr_with_data, new, 0)

