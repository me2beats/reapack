-- @description Duplicate tracks without items
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper
function a(id) return r.Main_OnCommand(id,0) end
r.Undo_BeginBlock() r.PreventUIRefresh(1)
t = {} for i = 0, r.CountSelectedMediaItems(0)-1 do t[i+1] = r.GetSelectedMediaItem(0, i) end
a(40062) a(40289) a(40421) a(40006) a(40289)
for _, item in ipairs(t) do r.SetMediaItemSelected(item, 1) end
r.PreventUIRefresh(-1) r.Undo_EndBlock('duplicate tracks without items', -1)
