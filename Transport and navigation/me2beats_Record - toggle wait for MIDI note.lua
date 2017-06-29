-- @description Record - toggle wait for MIDI note
-- @version 1.1
-- @author me2beats
-- @changelog
--  + init
--  + an issue with deleting a track with midi examiner fixed 

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local function find_track_by_name(name)
  local found
  local tracks = r.CountTracks()
  for i = 0, tracks-1 do
    local tr = r.GetTrack(0,i)
    local _, tr_name = r.GetSetMediaTrackInfo_String(tr, 'P_NAME', '', 0)
    if tr_name == name then found = tr end
  end
  return found
end

function track_exists(tr)
  local f
  local tracks = r.CountTracks()
  for i = 0, tracks-1 do
    if track == r.GetTrack(0,i) then f = 1 break end
  end
  return f
end

local track,last_pitch

local function rec_wait()

  local ext_sec, ext_key = 'me2beats_record_wait', 'stop'
  local str = r.GetExtState(ext_sec, ext_key)
  if str == '1' then
    r.DeleteExtState(ext_sec, ext_key, 0) return
  end


  if not track_exists(track) then track = find_track_by_name('MIDI Examiner')
  else
    local _, tr_name = r.GetSetMediaTrackInfo_String(track, 'P_NAME', '', 0)
    if tr_name ~= 'MIDI Examiner' then track = find_track_by_name('MIDI Examiner') end
  end

  r.Undo_BeginBlock() r.PreventUIRefresh(1)
  local fx
  if track then
    fx = r.TrackFX_AddByName(track, 'midi_examine', 0, 0)
    if fx == -1 then r.TrackFX_AddByName(track, 'midi_examine', 0, -1) end
  else
    r.InsertTrackAtIndex(0,0)
    track = r.GetTrack(0,0)
    r.TrackList_AdjustWindows(0)
    fx = r.TrackFX_AddByName(track, 'midi_examine', 0, -1)
    r.GetSetMediaTrackInfo_String(track, 'P_NAME', 'MIDI Examiner', 1)

    r.SetMediaTrackInfo_Value(track, 'B_SHOWINMIXER',0)
    r.SetMediaTrackInfo_Value(track, 'B_SHOWINTCP',0)

    r.SetMediaTrackInfo_Value(track, 'I_RECARM',1)
    r.SetMediaTrackInfo_Value(track, 'I_RECMON',1)
  end


  local val

  val = r.TrackFX_GetParam(track, fx, 3)


  last_pitch = last_pitch or val

  if val~= last_pitch and val ~= 0 then
    last_pitch = val

    local rec = r.GetPlayState()==4 or r.GetPlayState()==5

    if not rec then r.CSurf_OnRecord() end

  end

  r.PreventUIRefresh(-1) r.Undo_EndBlock('Wait for MIDI note', 2)

end




local function main()
  rec_wait()
  r.defer(main)
end

-----------------------------------------------

function SetButtonON(sec, cmd)
  r.SetToggleCommandState( sec, cmd, 1 ) -- Set ON
  r.RefreshToolbar2( sec, cmd )
  main()
end

-----------------------------------------------

function SetButtonOFF(sec, cmd)
  r.SetToggleCommandState( sec, cmd, 0 ) -- Set OFF
  r.RefreshToolbar2( sec, cmd ) 
end

-----------------------------------------------

local _, _, sec, cmd = r.get_action_context()

SetButtonON(sec, cmd)
r.atexit(
function ()
  SetButtonOFF(sec, cmd)
  local rec = r.GetPlayState()==4 or r.GetPlayState()==5
  if rec then r.OnStopButton() end
end)

