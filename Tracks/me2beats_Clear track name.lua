-- @description Clear track name
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local tracks = r.CountSelectedTracks()
if tracks == 0 then bla() return end

local t = {}

for i = 0, tracks-1 do
  local tr = r.GetSelectedTrack(0,i)
  local _, tr_name = r.GetSetMediaTrackInfo_String(tr, 'P_NAME', '', 0)
  if tr_name ~= '' then t[#t+1] = tr end
end

if #t==0 then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)
for i = 1, #t do r.GetSetMediaTrackInfo_String(t[i], 'P_NAME', '', 1) end
r.PreventUIRefresh(-1) r.Undo_EndBlock('Clear track name', -1)
