-- @description Paste saved points to selected track volume envelope
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local tr = r.GetSelectedTrack(0,0)
if not tr then bla() return end

local ext_sec, ext_key = 'me2beats_copy-paste', 'env_points'

local str = r.GetExtState(ext_sec, ext_key)
if not str or str == '' then bla() return end

local envs = r.CountTrackEnvelopes(tr)

local found,env
for i = 0, envs-1 do
  env = r.GetTrackEnvelope(tr, i)
  local _, env_name = r.GetEnvelopeName(env, '')
  if env_name == 'Volume' then found = 1 break end
end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

if not found then
  r.Main_OnCommand(40406,0) -- Track: Toggle track volume envelope visible
end

local envs = r.CountTrackEnvelopes(tr)

local found,env
for i = 0, envs-1 do
  env = r.GetTrackEnvelope(tr, i)
  local _, env_name = r.GetEnvelopeName(env, '')
  if env_name == 'Volume' then break end
end

r.DeleteEnvelopePointRange(env, 0, 100000)

for point in str:gmatch'(.-) ' do
  local time, val, shape, tens, sel = point:match'(.-),(.-),(.-),(.-),(.*)'
  sel = tonumber(sel)
  r.InsertEnvelopePoint(env, time, val, shape, tens, sel, 0)
end

r.UpdateArrange()

r.PreventUIRefresh(-1) r.Undo_EndBlock('Paste volume envelope points', -1)
