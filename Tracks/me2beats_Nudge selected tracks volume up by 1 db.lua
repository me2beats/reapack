-- @description Nudge selected tracks volume up by 1 db
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local db = 1

local r = reaper; function nothing() end; function bla() r.defer(nothing) end

local tracks = r.CountSelectedTracks(0)
if tracks > 0 then
  db = tonumber(db)
  if db then
    r.Undo_BeginBlock(); r.PreventUIRefresh(111)
    for i = 0, tracks-1 do
      local tr = r.GetSelectedTrack(0, i)
      local vol = r.GetMediaTrackInfo_Value(tr, 'D_VOL')
      r.SetMediaTrackInfo_Value(tr, 'D_VOL', vol*10^(0.05*db))
    end
    r.PreventUIRefresh(-111); r.Undo_EndBlock('Nudge sel track volume', -1)
  else r.defer(nothing) end
else r.defer(nothing) end
