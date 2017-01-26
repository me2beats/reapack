-- @description Set selected items length to length of item under mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end;

it_m = reaper.BR_ItemAtMouseCursor()
if it_m then
  items = r.CountSelectedMediaItems(0)
  if items > 0 then
    r.Undo_BeginBlock()
    r.PreventUIRefresh(111)

    it_m_len = r.GetMediaItemInfo_Value(it_m, 'D_LENGTH')
    for i = 0, items-1 do
      it = r.GetSelectedMediaItem(0,i)
      r.SetMediaItemInfo_Value(it, 'D_LENGTH', it_m_len)
    end
    
    r.PreventUIRefresh(-111)
    r.Undo_EndBlock('Set sel items len to len of item under mouse', -1)
  else bla() end
else bla() end
