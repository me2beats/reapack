-- @description Nudge tracks volume down 0.5 db
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

-----------------you always can change this--
local nudge = -0.5
-- in db
---------------------------------------------

local r = reaper

function VOL(db) return 10^(0.05*db) end
function DB(vol) return 20*math.log(vol, 10) end

local tracks = r.CountSelectedTracks()
if tracks == 0 then return end

r.Undo_BeginBlock(); r.PreventUIRefresh(1)

for i = 0, tracks-1 do
  local tr = r.GetSelectedTrack(0,i)
  local vol = r.GetMediaTrackInfo_Value(tr, 'D_VOL')
  r.SetMediaTrackInfo_Value(tr, 'D_VOL',VOL(DB(vol)+nudge))
end

r.PreventUIRefresh(-1); r.Undo_EndBlock('Nudge tracks volume down 0.5 db', -1)
