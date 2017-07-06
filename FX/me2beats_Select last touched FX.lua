-- @description Select last touched FX
-- @version 0.95
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

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

local retval, trnum, fxnum, paramnum = r.GetLastTouchedFX()

if not retval then bla() return end

local tr
if trnum == 0 then tr = r.GetMasterTrack() else tr = r.GetTrack(0,trnum-1) end

local chunk = GetTrackChunk(tr)

chunk = chunk:gsub('\nLASTSEL .','\nLASTSEL '..fxnum, 1)
-- 1 == don't change input/monitoring/take fx chain (if any)

r.Undo_BeginBlock()
SetTrackChunk(tr, chunk)
r.Undo_EndBlock('Select last touched FX', -1)

