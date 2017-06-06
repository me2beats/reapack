-- @description Select all tracks in selected track groups
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local function Elem_in_tb(elem,tb)
  local found
  for eit = 1, #tb do if tb[eit] == elem then found = 1 break end end
  if found then return 1 end
end

local tracks = r.CountSelectedTracks()
if tracks == 0 then bla() return end

local t = {}
local t_tracks = {}

for i = 0, tracks-1 do
  local tr = r.GetSelectedTrack(0,i)
  t_tracks[#t_tracks+1] = tr
  local _, chunk = r.GetTrackStateChunk(tr, '', 0)
  local group_flags = chunk:match'\nGROUP_FLAGS (.-)\n'
  if group_flags then
    for flag in group_flags:gmatch'%d+' do
      flag = tonumber(flag)
      if not (flag == 0 or Elem_in_tb(flag,t)) then t[#t+1] = flag end
    end
  end
end

if #t ==0 then bla() return end

local all_tracks = r.CountTracks()

local t_to_sel = {}

for i = 0, all_tracks-1 do
  local tr = r.GetTrack(0,i)
  if not Elem_in_tb(tr,t_tracks) then
    local _, chunk = r.GetTrackStateChunk(tr, '', 0)
    local group_flags = chunk:match'\nGROUP_FLAGS (.-)\n'
    if group_flags then
      for flag in group_flags:gmatch'%d+' do
        flag = tonumber(flag)
        if not flag ~= 0 and Elem_in_tb(flag,t) then
          if not r.IsTrackSelected(tr) then
            t_to_sel[#t_to_sel+1] = tr break
          end
        end
      end
    end
  end
end

if #t_to_sel==0 then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 1, #t_to_sel do r.SetTrackSelected(t_to_sel[i],1) end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Select all tracks in selected track groups', -1)
