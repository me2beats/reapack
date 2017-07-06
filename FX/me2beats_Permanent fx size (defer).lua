-- @description Permanent fx size (defer)
-- @version 0.6
-- @author me2beats
-- @changelog
--  + init

local r = reaper

function GetTrackChunk(track)
  if not track then return end
  local fast_str, track_chunk
  fast_str = r.SNM_CreateFastString("")
  if r.SNM_GetSetObjectState(track, fast_str, false, false) then
    track_chunk = r.SNM_GetFastString(fast_str)
  end
  r.SNM_DeleteFastString(fast_str)  
  return track_chunk
end

function SetTrackChunk(track, track_chunk)
  if not (track and track_chunk) then return end
  local fast_str, ret 
  fast_str = r.SNM_CreateFastString("")
  if r.SNM_SetFastString(fast_str, track_chunk) then
    ret = r.SNM_GetSetObjectState(track, fast_str, true, false)
  end
  r.SNM_DeleteFastString(fast_str)
  return ret
end

tr = r.GetSelectedTrack(0,0)
if not tr then return end

opened_tb = {}
closed_tb = {}

function perm_fx_size()

  local tracks = r.CountTracks()

  for i = 0, tracks-1 do

    tr = r.GetTrack(0,i)
    if not tr then return end

    local chunk = GetTrackChunk(tr)

    for opened,guid in chunk:gmatch'\nFLOAT (%d+ %d+ %d+ %d+)\nFXID {(.-)}\n' do
      opened_tb[guid] = opened
    end

    for closed,guid in chunk:gmatch'\nFLOATPOS (%d+ %d+ %d+ %d+)\nFXID {(.-)}\n' do
      closed_tb[guid] = closed
    end
   
    for guid,opened in pairs(opened_tb) do
      if closed_tb[guid] and closed_tb[guid] ~= opened_tb[guid] then
 
        local tr_chunk = chunk:gsub('\nFLOAT '..opened..'\n','\nFLOAT '..closed_tb[guid]..'\n',1)

        SetTrackChunk(tr, tr_chunk)

        closed_tb[guid] = nil
        break
      end
    end
  end
end



function main()
  r.PreventUIRefresh(1)
  perm_fx_size()  
  r.PreventUIRefresh(-1)
  r.defer(main)
end

-----------------------------------------------

function SetButtonON()
  r.SetToggleCommandState( sec, cmd, 1 ) -- Set ON
  r.RefreshToolbar2( sec, cmd )
  main()
end

-----------------------------------------------

function SetButtonOFF()
  r.SetToggleCommandState( sec, cmd, 0 ) -- Set OFF
  r.RefreshToolbar2( sec, cmd ) 
end

-----------------------------------------------
_, _, sec, cmd = r.get_action_context()
SetButtonON()
r.atexit(SetButtonOFF)
