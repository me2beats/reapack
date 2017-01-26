-- @description Move selected items to previous item
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end;

items = r.CountSelectedMediaItems()
if items == 0 then bla() return end

first_sel_it = r.GetSelectedMediaItem(0,0)
first_sel_it_pos = r.GetMediaItemInfo_Value(first_sel_it, 'D_POSITION') -- get first sel item start
tr = r.GetMediaItemTrack(first_sel_it)
tr_items = r.CountTrackMediaItems(tr)

if tr_items == 0 then bla() return end

prev_it_end = 0
for i = 0, tr_items-1 do
  tr_it =  r.GetTrackMediaItem(tr, i)
  if r.IsMediaItemSelected(tr_it) == false then
    tr_it_end = r.GetMediaItemInfo_Value(tr_it, 'D_LENGTH') + r.GetMediaItemInfo_Value(tr_it, 'D_POSITION')
    if tr_it_end > prev_it_end and tr_it_end <= first_sel_it_pos+0.000001 then
      prev_it_end = tr_it_end
    end
  end
end
if prev_it_end > 0 then
  r.Undo_BeginBlock()
  r.ApplyNudge(0, 0, 0, 1, first_sel_it_pos - prev_it_end, 1, 0)
  r.Undo_EndBlock('move selected items to prev one', -1)
end
