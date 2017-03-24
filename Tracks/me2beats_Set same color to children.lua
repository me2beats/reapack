-- @description Set same color to children
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function last_tr_in_folder (folder_tr)
  last = nil
  local dep = r.GetTrackDepth(folder_tr)
  local num = r.GetMediaTrackInfo_Value(folder_tr, 'IP_TRACKNUMBER')
  local tracks = r.CountTracks()
  for i = num+1, tracks do
    if r.GetTrackDepth(r.GetTrack(0,i-1)) <= dep then last = r.GetTrack(0,i-2) last_num = i-2 break end
  end
  if last == nil then last = r.GetTrack(0, tracks-1) last_num = tracks-1 end
  return last, num, last_num
end

tr = r.GetSelectedTrack(0,0)

last_tr,tr_num,last_num = last_tr_in_folder(tr)

if tr == last_tr then bla() return end


tr_col = r.GetMediaTrackInfo_Value(tr, 'I_CUSTOMCOLOR')

r.Undo_BeginBlock(); r.PreventUIRefresh(1)

for i = tr_num,last_num do
  local tr = r.GetTrack(0,i)
  r.SetMediaTrackInfo_Value(tr, 'I_CUSTOMCOLOR',tr_col)
end

r.PreventUIRefresh(-1); r.Undo_EndBlock('Set same color to children', -1)
