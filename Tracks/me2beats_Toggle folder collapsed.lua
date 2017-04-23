-- @description Toggle folder collapsed
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local tracks = r.CountSelectedTracks()
if tracks == 0 then bla() return end

local collapsed

for i = 0,tracks-1 do
  local tr = r.GetSelectedTrack(0,i)
  if r.GetMediaTrackInfo_Value(tr, 'I_FOLDERDEPTH') == 1 then
    collapsed = r.GetMediaTrackInfo_Value(tr, 'I_FOLDERCOMPACT')
    if collapsed == 0 then collapsed = 2 else collapsed = 0 end
  break end
end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 0,tracks-1 do
  local tr = r.GetSelectedTrack(0,i)
  if r.GetMediaTrackInfo_Value(tr, 'I_FOLDERDEPTH') == 1 then
    r.SetMediaTrackInfo_Value(tr, 'I_FOLDERCOMPACT',collapsed)
  end
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Toggle folder collapsed', -1)
