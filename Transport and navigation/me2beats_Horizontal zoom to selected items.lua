-- @description Horizontal zoom to selected items
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end; reaper.defer(nothing)

function leftmost_sel_item_start_and_rightmost_sel_item_end ()
  local items = reaper.CountSelectedMediaItems(0)
  if items > 0 then
    local tb_left = {}; local tb_right = {}
    for i = 0, items-1 do
      local item = reaper.GetSelectedMediaItem(0,i)
      local start_time = reaper.GetMediaItemInfo_Value(item, 'D_POSITION')
      local end_time = start_time + reaper.GetMediaItemInfo_Value(item, 'D_LENGTH')
      tb_left[#tb_left+1] = start_time; tb_right[#tb_right+1] = end_time
    end
    return math.min(table.unpack(tb_left)), math.max(table.unpack(tb_right))
  end
end

x, y = leftmost_sel_item_start_and_rightmost_sel_item_end ()
if x and y then
  reaper.BR_SetArrangeView(0, x-(y-x)/50, y+(y-x)/50)
end
