-- @description Move envelope points X sec right or left
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function closest_l_r_point(env,time,right)

  if time == 0 then return end
  local closest
  local d = math.huge
  local points = r.CountEnvelopePoints(env)

  if not right or right == false or right == 0 then

    for k = 0,points-1 do
      local _, p_x = r.GetEnvelopePoint(env, k)
      if time-p_x >0 and time-p_x < d then d = time-p_x closest = k end
    end

  else
  
    for k = 0,points-1 do
      local _, p_x = r.GetEnvelopePoint(env, k)
      if p_x-time >0 and p_x-time < d then d = p_x-time closest = k end
    end

  end
    
  return closest
end

local tracks = r.CountTracks()
if tracks == 0 then return end

retval, move = r.GetUserInputs("Move", 1, "Move envelope points, sec:", "")
if not retval then bla() return end

move = tonumber(move)
if not move or move == 0 then bla() return end


r.Undo_BeginBlock() r.PreventUIRefresh(1)


for i = 0, tracks-1 do
  local tr = r.GetTrack(0,i)

  local envs = r.CountTrackEnvelopes(tr)
  if envs > 0 then
    for j = 0,envs-1 do
      local env = r.GetTrackEnvelope(tr, j)
      local _, env_chunk = r.GetEnvelopeStateChunk(env, '', 0)
      local vis = env_chunk:match'\nVIS (.).-\n' == '1'
      if vis then
        local points = r.CountEnvelopePoints(env)

        local            a,b,c
        if move > 0 then a,b,c = points-1, 0, -1
        else             a,b,c = 0, points-1, 1 end

        for k =          a,b,c do
          local _, time, _, _, _, sel = r.GetEnvelopePoint(env, k)
          if sel then
            if move > 0 then
              local closest = closest_l_r_point(env,time,1)
              if closest then
                _, closest_time = r.GetEnvelopePoint(env, closest)
                if closest_time < move+time then goto cnt end
              end
            else
              local closest = closest_l_r_point(env,time)
              if closest then
                _, closest_time = r.GetEnvelopePoint(env, closest)
                if closest_time > move+time then goto cnt end
              end
              if move+time <0 then goto cnt end
            end

            r.SetEnvelopePoint(env, k, time+move, nil, nil, nil, nil, 1)
            ::cnt::
          end
        end
      end
    end
  end
end

r.UpdateArrange()

r.PreventUIRefresh(-1) r.Undo_EndBlock('Move envelope points X sec right or left', -1)
