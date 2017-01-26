-- @description Remove selected items envelopes
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; r.Undo_BeginBlock(); local items = r.CountSelectedMediaItems(0)
for i = 0, items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  local _, chunk = r.GetItemStateChunk(item, '', 0)
  chunk = chunk:gsub('<%a+ENV.->', '')
  chunk = chunk:gsub('\nTAKE_FX_HAVE_NEW_PDC_AUTOMATION_BEHAVIOR 1\n', '')
  reaper.SetItemStateChunk(item, chunk, 1)
end
r.UpdateArrange(); r.Undo_EndBlock("Remove selected items envelopes", -1)
