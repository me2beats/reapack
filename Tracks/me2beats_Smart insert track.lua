-- @description Smart insert track
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

if r.CountSelectedTracks() > 0 then
  local last_sel = r.GetSelectedTrack(0,r.CountSelectedTracks()-1)
  r.SetOnlyTrackSelected(last_sel)
  r.Main_OnCommand(40914,0) -- Track: Set first selected track as last touched track
  local dep = r.GetMediaTrackInfo_Value(last_sel, "I_FOLDERDEPTH")
  if dep < 0 then
    r.Main_OnCommand(40001, 0)
    local new = r.GetSelectedTrack(0, 0)
    r.SetMediaTrackInfo_Value(last_sel, "I_FOLDERDEPTH", 0)
    r.SetMediaTrackInfo_Value(new, "I_FOLDERDEPTH", dep)
  else
    r.Main_OnCommand(40001, 0)
  end
else 
  local n = r.CountTracks(0)
  if n > 0 then
    local was_last_tr = r.GetTrack(0, n-1)
    local dep = r.GetMediaTrackInfo_Value(was_last_tr, "I_FOLDERDEPTH")
    r.SetOnlyTrackSelected(was_last_tr)
    r.Main_OnCommand(40702, 0)
    local new = r.GetSelectedTrack(0, 0)
    r.SetMediaTrackInfo_Value(was_last_tr, "I_FOLDERDEPTH", 0)
    r.SetMediaTrackInfo_Value(new, "I_FOLDERDEPTH", dep)
  end
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Smart insert track', -1)

