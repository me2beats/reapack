-- @description Move selected envelope up
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

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

local _, chunk = r.GetTrackStateChunk(tr, '', 0)

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

r.SetTrackStateChunk(tr, chunk_empty, 0)
r.SetTrackStateChunk(tr, chunk_new, 0)


local upper_env = r.GetTrackEnvelope(tr, upper_i-1)
r.SetCursorContext(2, upper_env)

r.PreventUIRefresh(-1)
r.Undo_EndBlock('Move selected envelope up', -1)
