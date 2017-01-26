-- @description Nudge selected track volume
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local function nothing() end
local r = reaper

local tracks = r.CountSelectedTracks(0)
if tracks > 0 then
  local retval, delta_db = r.GetUserInputs("Nudge volume", 1, "Nudge volume, dB:", "")
  if retval == true then 
    r.Undo_BeginBlock(); r.PreventUIRefresh(111)
    for i = 0, tracks-1 do
      local tr = r.GetSelectedTrack(0, i)
      local vol = r.GetMediaTrackInfo_Value(tr, 'D_VOL')
      local norm = 10^(0.05*delta_db)
      r.SetMediaTrackInfo_Value(tr, 'D_VOL', vol*norm)
    end
    r.PreventUIRefresh(-111); r.Undo_EndBlock('Nudge sel track volume', -1)
  else r.defer(nothing) end
else r.defer(nothing) end
