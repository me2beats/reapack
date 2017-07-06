-- @description Move selected envelope up
-- @version 1.0
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

function replace_str_parts(str,sub1,sub2)
  return str:gsub(esc(sub2),sub1,1):gsub(esc(sub1),sub2,1)
end

local env = r.GetSelectedEnvelope()
if not env then bla() return end

local tr, tr_fxnum, tr_paramnum = r.Envelope_GetParentTrack(env)
if not tr then bla() return end

local envs = r.CountTrackEnvelopes(tr)

for i = 0,envs-1 do
  local tr_env  = r.GetTrackEnvelope(tr, i)
  if tr_env == env then num = i break end
end

if not num then bla() return end

local chunk = GetTrackChunk(track)

t = {}

local env_str = ''
local i = 0

for env_chunk in chunk:gmatch('<PARMENV.->') do
  i = i+1
  t[i]=env_chunk
  env_str = env_str..'\n'..env_chunk
end

local cur = t[num+1]

for i = num, 1,-1 do
  local env_chunk = t[i]
  if env_chunk:match'\nVIS 1' then
    upper = env_chunk; upper_i = i
  break end
end

if not upper then bla() return end

local chunk_new = replace_str_parts(chunk,upper,cur)

local chunk_empty = chunk:gsub(esc(env_str),'')

r.Undo_BeginBlock()
r.PreventUIRefresh(1)

SetTrackChunk(tr, chunk_empty)
SetTrackChunk(tr, chunk_new)

local upper_env = r.GetTrackEnvelope(tr, upper_i-1)
r.SetCursorContext(2, upper_env)

r.PreventUIRefresh(-1)
r.Undo_EndBlock('Move selected envelope up', -1)
