-- @description Pool active takes of selected items
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function esc (str)
str = str:gsub('%(', '%%(')
str = str:gsub('%)', '%%)')
str = str:gsub('%.', '%%.')
str = str:gsub('%+', '%%+')
str = str:gsub('%-', '%%-')
str = str:gsub('%$', '%%$')
str = str:gsub('%[', '%%[')
str = str:gsub('%]', '%%]')
str = str:gsub('%*', '%%*')
str = str:gsub('%?', '%%?')
str = str:gsub('%^', '%%^')
str = str:gsub('/', '%%/')
return str end


reaper.Undo_BeginBlock(); reaper.PreventUIRefresh(111)

item_p = reaper.GetSelectedMediaItem(0,0)
_, chunk_p = reaper.GetItemStateChunk(item_p, '', 0)
takes_p = reaper.GetMediaItemNumTakes(item_p)
take_p = reaper.GetActiveTake(item_p)
for i = 0, takes_p do
  if reaper.GetMediaItemTake(item_p, i) == take_p then
    take_id_p = i+1
  break end
end
k = 0
for part_p in chunk_p:gmatch('(<SOURCE.->)\n') do
  k=k+1
  if k == take_id_p then x_p = part_p break end
end

if x_p then
  pooled_guid_p = x_p:match('POOLEDEVTS {(.-)}')
  
  for j = 0, reaper.CountSelectedMediaItems(0)-1 do
  
    item = reaper.GetSelectedMediaItem(0,j)
    _, chunk = reaper.GetItemStateChunk(item, '', 0)
    takes = reaper.GetMediaItemNumTakes(item)
    take = reaper.GetActiveTake(item)
    for i = 0, takes do
      if reaper.GetMediaItemTake(item, i) == take then
        take_id = i+1
      break end
    end
    k = 0
    for part in chunk:gmatch('(<SOURCE.->)\n') do
      k=k+1
      if k == take_id then x = part break end
    end
    if x then
      x = esc(x)
      pooled_guid = x:match('POOLEDEVTS {(.-)}')
      before, pooled_guid, after = chunk:match('(.*{)('..pooled_guid..')(}.*)')
      if before and after then
        new_chunk = before..pooled_guid_p..after
        reaper.SetItemStateChunk(item, new_chunk, 0)
      end
    end
  end
end

reaper.PreventUIRefresh(-111); reaper.Undo_EndBlock('Pool active takes of selected items', -1)
