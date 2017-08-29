-- @description Copy selected track volume envelope points
-- @version 1.1
-- @author me2beats
-- @changelog
--  + init

local r = reaper

function bool_to_num(bool) if bool then return 1 else return 0 end end

local tr = r.GetSelectedTrack(0,0)


local envs = r.CountTrackEnvelopes(tr)

local found,env
for i = 0, envs-1 do
  env = r.GetTrackEnvelope(tr, i)
  local _, env_name = r.GetEnvelopeName(env, '')
  if env_name == 'Volume' then found = 1 break end
end

if not found then return end


local points = r.CountEnvelopePoints(env)
local str = ''
for i = 0, points-1 do
  local ret, time, val, shape, tens, sel = r.GetEnvelopePoint(env, i)
  str = str..time..','..val..','..shape..','..tens..','..bool_to_num(sel)..' '
end

local ext_sec, ext_key = 'me2beats_copy-paste', 'env_points'

r.DeleteExtState(ext_sec, ext_key, 0)
r.SetExtState(ext_sec, ext_key, str, 0)

r.Undo_BeginBlock() r.PreventUIRefresh(1)
r.PreventUIRefresh(-1) r.Undo_EndBlock('Copy volume envelope points', -1)
