-- @description Delete envelope at mouse
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

local window, segment, details = r.BR_GetMouseCursorContext()
local env, takeEnv = r.BR_GetMouseCursorContext_Envelope()
if takeEnv then bla() return end

if not env then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

tr = r.Envelope_GetParentTrack( env )

local envs = r.CountTrackEnvelopes(tr)

for i = 0,envs-1 do
  local tr_env = r.GetTrackEnvelope(tr, i)
  if tr_env == env then num = i break end
end

local _, chunk = r.GetTrackStateChunk(tr, '', 0)

x = -1
for env_chunk in chunk:gmatch('<PARMENV.->') do
  x = x+1
  if x == num then
    chunk = chunk:gsub(esc(env_chunk)..'\n','',1)
    break
  end
end

r.SetTrackStateChunk(tr, chunk, 0)

r.PreventUIRefresh(-1) r.Undo_EndBlock('Delete envelope at mouse', -1)
