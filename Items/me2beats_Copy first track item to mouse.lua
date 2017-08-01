-- @description Copy first track item to mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function SetLastTouchedTrack(tr)

  local function SaveSelTracks()
    sel_tracks = {}
    for i = 0, r.CountSelectedTracks()-1 do
      sel_tracks[i+1] = r.GetSelectedTrack(0, i)
    end
  end

  local function RestoreSelTracks()
    r.Main_OnCommand(40297,0) -- unselect all tracks
    for _, track in ipairs(sel_tracks) do
      r.SetTrackSelected(track, 1)
    end
  end

  SaveSelTracks()
  r.SetOnlyTrackSelected(tr)
  r.Main_OnCommand(40914,0) -- Track: Set first selected track as last touched track
  RestoreSelTracks()

end

function is_tr_item_with_pos(tr,pos,tr_items)
  local found
  local tr_items = tr_items or r.CountTrackMediaItems(tr)
  for i = 0, r.CountTrackMediaItems(tr)-1 do
    local tr_item = r.GetTrackMediaItem(tr, i)
    local it_start = r.GetMediaItemInfo_Value(tr_item, 'D_POSITION')
    if math.abs(it_start-pos) < 0.0000001 then found = 1 break end
  end
  return found
end

local window, segment, details = r.BR_GetMouseCursorContext()

local mouse_tr

if window == 'arrange' and segment == 'empty' then
  r.InsertTrackAtIndex(r.CountTracks(), 1)
  mouse_tr = r.GetTrack(0,r.CountTracks()-1)
  r.TrackList_AdjustWindows(0)
end


local mouse = r.BR_GetMouseCursorContext_Position()
if not mouse then bla() return end

mouse_tr = mouse_tr or r.BR_TrackAtMouseCursor()
if not mouse_tr then bla() return end

local item
--item = r.GetSelectedMediaItem(0,0)
item = r.GetTrackMediaItem(mouse_tr, 0)
if not item then bla() return end


local ext_sec, ext_key = 'me2beats_copy', 'recent'
local guid = r.GetExtState(ext_sec, ext_key)

if not ((guid or guid == '') or item) then bla() return end -- no guid no item

if item and (not guid or guid == '' or item_guid~=guid) then
  r.DeleteExtState(ext_sec, ext_key, 0)
  r.SetExtState(ext_sec, ext_key, r.BR_GetMediaItemGUID(item), 0)
end


local recent_item = r.BR_GetMediaItemByGUID(0, guid)

if not item and not recent_item then bla() return end

if not item and recent_item then item = recent_item r.SetMediaItemSelected(item,1) end

local where
if r.GetToggleCommandState(1157) == 1 then
  where = r.BR_GetPrevGridDivision(mouse)
--  where = r.BR_GetClosestGridDivision(mouse)
else where = mouse end

if is_tr_item_with_pos(mouse_tr,where,r.CountTrackMediaItems(mouse_tr)) then bla() return end


local last_touched_tr = r.GetLastTouchedTrack()
if not last_touched_tr then last_touched_tr = mouse_tr  end

local tr = r.GetMediaItem_Track(item)

r.Undo_BeginBlock() r.PreventUIRefresh(1)

r.SelectAllMediaItems(0, 0) -- unselect all items
r.SetMediaItemSelected(item,1)


SetLastTouchedTrack(mouse_tr)

local cur = r.GetCursorPosition()
r.SetEditCurPos2(0, where, 0, 0)

r.Main_OnCommand(40698,0) -- Edit: Copy items
r.Main_OnCommand(40058,0) -- Item: Paste items/tracks

SetLastTouchedTrack(last_touched_tr)

r.SetEditCurPos2(0, cur, 0, 0)

r.PreventUIRefresh(-1) r.Undo_EndBlock('', -1)
