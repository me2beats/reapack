-- @description Delete envelope at mouse
-- @version 1.2
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

function esc (str)
str = str:gsub('%(', '%%(')
str = str:gsub('%)', '%%)')
str = str:gsub('%.', '%%.')
str = str:gsub('%+', '%%+')
str = str:gsub('%-', '%%-')
str = str:gsub('%$', '%%$')
str = str:gsub('%[', '%%[')
str = str:gsub('%]', '%%]')
str = str:gsub('%*', '%%*')
str = str:gsub('%?', '%%?')
str = str:gsub('%^', '%%^')
str = str:gsub('/', '%%/')
return str end

local window, segment, details = r.BR_GetMouseCursorContext()
local env, takeEnv = r.BR_GetMouseCursorContext_Envelope()
if takeEnv then return end

if not env then return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

tr = r.Envelope_GetParentTrack( env )

local envs = r.CountTrackEnvelopes(tr)

for i = 0,envs-1 do
  local tr_env = r.GetTrackEnvelope(tr, i)
  if tr_env == env then num = i break end
end

local chunk = GetTrackChunk(tr)

x = -1
for env_chunk in chunk:gmatch('<PARMENV.->') do
  x = x+1
  if x == num then
    chunk = chunk:gsub(esc(env_chunk)..'\n','',1)
    break
  end
end

SetTrackChunk(tr, chunk)

r.PreventUIRefresh(-1) r.Undo_EndBlock('Delete envelope at mouse', -1)
