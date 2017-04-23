-- @description Select only first track with name X (without input box)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local name = 'Buss'

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local tracks = r.CountTracks()

if not tracks == 0 then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

r.Main_OnCommand(40297,0) -- unselect all tracks


for i = 0, tracks-1 do
  local tr = r.GetTrack(0, i)
  local _, tr_name = r.GetSetMediaTrackInfo_String(tr, 'P_NAME', '', 0)
  if tr_name  == name then r.SetTrackSelected(tr, 1) break end
end
r.PreventUIRefresh(-1) r.Undo_EndBlock('Select track', -1)
