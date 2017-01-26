-- @description Move selected items to next item
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end;

items = r.CountSelectedMediaItems()
if items == 0 then bla() return end

last_sel_it = r.GetSelectedMediaItem(0,items-1)
last_sel_it_pos = r.GetMediaItemInfo_Value(last_sel_it, 'D_POSITION')
last_sel_it_len = r.GetMediaItemInfo_Value(last_sel_it, 'D_LENGTH')
last_sel_it_end = last_sel_it_pos + last_sel_it_len

tr = r.GetMediaItemTrack(last_sel_it)
tr_items = r.CountTrackMediaItems(tr)

if tr_items == 0 then bla() return end

next_it_start = 10000
for i = 0, tr_items-1 do
  tr_it =  r.GetTrackMediaItem(tr, i)
  if r.IsMediaItemSelected(tr_it) == false then
    tr_it_start = r.GetMediaItemInfo_Value(tr_it, 'D_POSITION')
    if tr_it_start < next_it_start and tr_it_start >= last_sel_it_end-0.000001 then
      next_it_start = tr_it_start
    end
  end
end
if next_it_start < 10000 then
  r.Undo_BeginBlock()
  r.ApplyNudge(0, 0, 0, 1, next_it_start-last_sel_it_end, 0, 0)
  r.Undo_EndBlock('move selected items to next one', -1)
end
