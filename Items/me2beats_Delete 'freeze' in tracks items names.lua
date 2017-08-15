-- @description Delete 'freeze' in tracks items names
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

local tracks = r.CountSelectedTracks()
if tracks == 0 then return end

r.Undo_BeginBlock(); r.PreventUIRefresh(1)


for i = 0, tracks-1 do
  local tr = r.GetSelectedTrack(0,i)

  local tr_items = r.CountTrackMediaItems(tr)
  for i = 0, tr_items-1 do
    local tr_item = r.GetTrackMediaItem(tr, i)
    local take = r.GetActiveTake(tr_item)
    local _, name = r.GetSetMediaItemTakeInfo_String(take, 'P_NAME', '', 0)
    if name:match' %- freeze' then name = name:match'(.*) %- freeze' end
    r.GetSetMediaItemTakeInfo_String(take, 'P_NAME', name, 1)
  end
end

r.PreventUIRefresh(-1); r.Undo_EndBlock("Delete 'freeze' in items names", -1)
