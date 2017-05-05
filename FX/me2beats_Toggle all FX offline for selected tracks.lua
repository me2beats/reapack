-- @description Toggle all FX offline for selected tracks
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local tracks = r.CountSelectedTracks()
if tracks == 0 then return end


for i = 0, tracks-1 do
  local tr = r.GetSelectedTrack(0, i)
  local _, tr_chunk = r.GetTrackStateChunk(tr, '', 0)
  local fx_chain = tr_chunk:match'<.-<(.*)>\n<ITEM.->' or tr_chunk:match'<.-<(.*)>.->'
  if fx_chain:match'\nBYPASS . 1 ' then offline = 1 break end
end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

if not offline then
  r.Main_OnCommand(40535,0)--Track: Set all FX offline for selected tracks
else
  r.Main_OnCommand(40536,0)--Track: Set all FX online for selected tracks
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Toggle all FX offline for selected tracks', -1)

