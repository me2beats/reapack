-- @description Stutter items (mousewheel)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

undo = -1
min_len = 0.001

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function sel_tr_items_in_area (tr,x,y)
  items = r.CountTrackMediaItems(tr)
  for i = 0, items-1 do
    item = r.GetTrackMediaItem(tr, i)
    item_start = r.GetMediaItemInfo_Value(item, 'D_POSITION')
    if item_start >= x and item_start < y then
      r.SetMediaItemSelected(item, 1)
      r.UpdateItemInProject(item)
    end
  end
end

function sel_items_area()

  min_pos = math.huge
  max_pos = 0
  for i = 1, items do
    item = r.GetSelectedMediaItem(0, i-1)

    item_pos = r.GetMediaItemInfo_Value(item, "D_POSITION")
    item_len = r.GetMediaItemInfo_Value(item, "D_LENGTH")
    min_pos = math.min(min_pos,item_pos)
    max_pos = math.max(max_pos,item_pos+item_len)
  end
  return min_pos,max_pos
end


items = r.CountSelectedMediaItems()



_,_,_,_,_,_,val = r.get_action_context()
if val < 0 then

  
  if items == 0 then bla() return end
  
  it = r.GetSelectedMediaItem(0,0)
  tr = r.GetMediaItem_Track(it)
  
  it_len = r.GetMediaItemInfo_Value(it, "D_LENGTH")
  if it_len < min_len then bla() return end
  
  
  if items == 1 then
    it_pos = r.GetMediaItemInfo_Value(it, "D_POSITION")
    it_end = it_pos+it_len
  
    grid = r.BR_GetNextGridDivision(0)
  
    r.Undo_BeginBlock()
    r.PreventUIRefresh(1)
    
    prev_gr = r.BR_GetPrevGridDivision(it_end)
    next_gr = r.BR_GetNextGridDivision(it_end)
    
    snaped = math.abs(next_gr-prev_gr-2*grid)<0.000001

    x = math.floor((it_len/grid)+0.0000001)%4
    y = math.floor((it_len/grid)+0.0000001)/4
    
    next_near = next_gr-it_end < it_end-prev_gr
    
    function nxt() r.ApplyNudge(0, 1, 3, 1, next_gr, 0, 0) end
    function prv() r.ApplyNudge(0, 1, 3, 1, prev_gr, 0, 0) end
    function nnext() r.ApplyNudge(0, 1, 3, 1, next_gr+grid, 0, 0) end
    
    if y < 1 then
      if x == 0 then
        r.ApplyNudge(0, 1, 3, 1, next_gr, 0, 0)
      elseif x == 1 then
        if not snaped then if next_near then nxt() else prv() end end
      elseif x == 2 then if not snaped then prv() end
      elseif x == 3 then nxt() end
    else
      if x == 0 then if not snaped then prv() end
      elseif x == 1 or x == 3 then nxt()
      elseif x == 2 then nnxt() end
    end
    
    min,max = sel_items_area()
  
    r.ApplyNudge(0, 0, 3, 20, -0.5, 0, 0)
    r.ApplyNudge(0, 0, 5, 20, 1, 0, 0)
    
    sel_tr_items_in_area (tr,min,max)

    r.PreventUIRefresh(-1)
    r.Undo_EndBlock('Stutter', -1)
    return
  
  end
  
  
  min,max = sel_items_area()
  
  r.Undo_BeginBlock()
  r.PreventUIRefresh(1)
  r.ApplyNudge(0, 0, 3, 20, -0.5, 0, 0)
  r.ApplyNudge(0, 0, 5, 20, 1, 0, 0)
  
  sel_tr_items_in_area (tr,min,max)
  r.PreventUIRefresh(-1)
  r.Undo_EndBlock('Stutter', undo)
  
else

  if items <= 1 then bla() return end
  
  it = r.GetSelectedMediaItem(0,0)
  tr = r.GetMediaItem_Track(it)
  
  r.Undo_BeginBlock()
  r.PreventUIRefresh(111)
  tb = {}
  for i = 0, items-1 do
    if math.fmod (i, 2) ~= 0 then tb[#tb+1] = r.GetSelectedMediaItem(0,i) end
  end
  if #tb > 0 then
    for i = 1, #tb do r.DeleteTrackMediaItem(tr,tb[i]) end
    r.UpdateArrange()
  end
  
  r.ApplyNudge(0, 0, 3, 20, 1, 0, 0)
  
  r.PreventUIRefresh(-111)
  r.Undo_EndBlock('Destutter', undo)

end
