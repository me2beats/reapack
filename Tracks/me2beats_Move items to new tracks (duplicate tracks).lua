-- @description Move items to new tracks (duplicate tracks)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function Elem_in_tb(elem,tb)
  _found = nil
  for eit = 1, #tb do if tb[eit] == elem then _found = 1 break end end
  if _found then return 1 end
end

sel_tracks1 = {}
sel_tracks2 = {}

function SaveSelTracks(table)
  for i = 0, r.CountSelectedTracks(0)-1 do
    table[i+1] = r.GetSelectedTrack(0, i)
  end
end

function RestoreSelTracks(table)
  r.Main_OnCommand(40297,0) -- unselect all tracks
  for _, track in ipairs(table) do
    r.SetTrackSelected(track, true)
  end
end


function SetLastTouchedTrack(tr)

  SaveSelTracks(sel_tracks2)
  r.SetOnlyTrackSelected(tr)
  r.Main_OnCommand(40914,0) -- Track: Set first selected track as last touched track
  RestoreSelTracks(sel_tracks2)

end


function SaveView() start_time_view, end_time_view = r.BR_GetArrangeView(0) end

function RestoreView() r.BR_SetArrangeView(0, start_time_view, end_time_view) end


local tracks = r.CountSelectedTracks()


local items = r.CountSelectedMediaItems()
if items == 0 then bla() return end

tracks_tb = {}
items_tb = {}

for i = 1, items do
  local item = r.GetSelectedMediaItem(0,i-1)
  local tr = r.GetMediaItem_Track(item)
  if not Elem_in_tb(tr,tracks_tb) then tracks_tb[#tracks_tb+1] = tr end
  items_tb[i] = {item,tr}
end

if #tracks_tb == 1 then 

  r.Undo_BeginBlock() r.PreventUIRefresh(1)

  SaveSelTracks(sel_tracks1)
  local tr = tracks_tb[1]
  r.SetOnlyTrackSelected(tr)

  r.Main_OnCommand(40062,0) -- Track: Duplicate tracks

  for i = #items_tb,1,-1 do
    local it = items_tb[i][1]
    r.DeleteTrackMediaItem(tr, it)
  end

  local new_tr = r.GetSelectedTrack(0,0)
  local items = r.CountTrackMediaItems(new_tr)
  for i = items-1,0,-1 do
    local item = r.GetTrackMediaItem(new_tr, i)
    if not r.IsMediaItemSelected(item) then r.DeleteTrackMediaItem(new_tr, item) end
  end

  RestoreSelTracks(sel_tracks1)

  r.PreventUIRefresh(-1) r.Undo_EndBlock('Move items to new tracks (duplicate tracks)', -1)

return end



SaveSelTracks(sel_tracks1)
SaveView()

r.Undo_BeginBlock()
r.PreventUIRefresh(1)

r.Main_OnCommand(40297,0) -- unselect all tracks
for i = 1, #tracks_tb do r.SetTrackSelected(tracks_tb[i],1) end

local tracks = #tracks_tb

local last_sel = r.GetSelectedTrack(0, tracks-1)

SetLastTouchedTrack(last_sel)

r.Main_OnCommand(r.NamedCommandLookup('_S&M_COPYSNDRCV1'),0) -- SWS/S&M: Copy selected tracks (with routing)
r.Main_OnCommand(r.NamedCommandLookup('_BR_FOCUS_TRACKS'),0) -- SWS/BR: Focus tracks
r.Main_OnCommand(r.NamedCommandLookup('_S&M_PASTSNDRCV1'),0) -- SWS/S&M: Paste tracks (with routing) or items

for i = #items_tb,1,-1 do
  local it,tr = items_tb[i][1],items_tb[i][2]
  r.DeleteTrackMediaItem(tr, it)
end

for j = 0, r.CountSelectedTracks()-1 do
  local new_tr = r.GetSelectedTrack(0,j)
  local items = r.CountTrackMediaItems(new_tr)
  for i = items-1,0,-1 do
    local item = r.GetTrackMediaItem(new_tr, i)
    if not r.IsMediaItemSelected(item) then r.DeleteTrackMediaItem(new_tr, item) end
  end
end

RestoreSelTracks(sel_tracks1)
RestoreView()

r.PreventUIRefresh(-1)
r.Undo_EndBlock('Move items to new tracks (duplicate tracks)', -1)
