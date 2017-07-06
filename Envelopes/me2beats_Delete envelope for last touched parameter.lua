-- @description Delete envelope for last touched parameter
-- @version 1.1
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

local retval, trnum, fxnum, paramnum = r.GetLastTouchedFX()

local tr = r.GetTrack(0,trnum-1)


r.Undo_BeginBlock() r.PreventUIRefresh(1)


local envs = r.CountTrackEnvelopes(tr)

for i = 0,envs-1 do
  local tr_env  = r.GetTrackEnvelope(tr, i)
  _, tr_fxnum, tr_paramnum = r.Envelope_GetParentTrack(tr_env)
  if tr_fxnum == fxnum and tr_paramnum == paramnum then num = i break end
end

if not num then bla() return end

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


r.PreventUIRefresh(-1) r.Undo_EndBlock('Delete envelope for last touched parameter', -1)
