-- @description Close all fx windows
-- @version 1.1
-- @author me2beats
-- @changelog
--  + init

local r = reaper

function close_tr_fx(tr)
  local fx = r.TrackFX_GetCount(tr)
  for i = 0,fx-1 do
    if r.TrackFX_GetOpen(tr, i) then
      r.TrackFX_SetOpen(tr, i, 0)
    end
    if r.TrackFX_GetChainVisible(tr)~=-1 then
      r.TrackFX_Show(tr, 0, 0)
    end
  end

  local rec_fx = r.TrackFX_GetRecCount(tr)
  for i = 0,rec_fx-1 do
    i_rec = i+16777216
    if r.TrackFX_GetOpen(tr, i_rec) then
      r.TrackFX_SetOpen(tr, i_rec, 0)
    end
    if r.TrackFX_GetRecChainVisible(tr)~=-1 then
      r.TrackFX_Show(tr, i_rec, 0)
    end
  end

end

function close_tk_fx(tk)
  if not tk then return end
  local fx = r.TakeFX_GetCount(tk)
  for i = 0,fx-1 do
    if r.TakeFX_GetOpen(tk, i) then
      r.TakeFX_SetOpen(tk, i, 0)
    end
    if r.TakeFX_GetChainVisible(tk)~=-1 then
      r.TakeFX_Show(tk, 0, 0)
    end
  end
end

local tracks = r.CountTracks()

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 0, tracks-1 do
  local tr = r.GetTrack(0,i)
  close_tr_fx(tr)

  local tr_items = r.CountTrackMediaItems(tr)
  for j = 0, tr_items-1 do
    local tr_item = r.GetTrackMediaItem(tr, j)

    local takes = r.GetMediaItemNumTakes(tr_item)
    for k = 0, takes-1 do
      close_tk_fx(r.GetTake(tr_item,k))
    end
  end
end

close_tr_fx(r.GetMasterTrack())

r.PreventUIRefresh(-1)
r.Undo_EndBlock('Close all fx', 2)
