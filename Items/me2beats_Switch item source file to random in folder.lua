-- @description Switch item source file to random in folder
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function shuffle(array)

  function swap(array, index1, index2)
    array[index1], array[index2] = array[index2], array[index1]
  end

  local counter = #array
  while counter > 1 do
    local index = math.random(counter)
    swap(array, index, counter)
    counter = counter - 1
  end
end

local items = r.CountSelectedMediaItems()
if items == 0 then bla() return end


r.Undo_BeginBlock()
r.PreventUIRefresh(1)

r.Main_OnCommand(40440,0)

for j = 0, r.CountSelectedMediaItems()-1 do
  local it = r.GetSelectedMediaItem(0,j)
  
  
  local tk = r.GetActiveTake(it)
  if not tk then goto cnt end
  if r.TakeIsMIDI(tk) then goto cnt end
  local src = r.GetMediaItemTake_Source(tk)
  if not src then goto cnt end
  local src_fn = r.GetMediaSourceFileName(src, '')
  local folder = src_fn:match[[(.*)\]]

  local clonedsource

  local pos, new_fn, files
  pos = r.GetExtState(folder, 'pos')
  if not (pos and pos ~= '') then
  
    local t = {}
    for i = 0, 10000 do
      local fn = r.EnumerateFiles(folder, i)
      if not fn or fn == '' then break end
      if fn:match'%.wav$' or fn:match'%.mp3$' or fn:match'%.aiff$' then
        t[#t+1] = folder..[[\]]..fn
      end
    end

    files = #t
    shuffle(t)
    
  
    for i = 1, files do
      local ext_key = tostring(i)
      r.SetExtState(folder, ext_key, t[i], 0)
    end

    r.SetExtState(folder, 'pos', 1, 0)
    r.SetExtState(folder, 'files', files, 0)
    pos = 1
    new_fn = t[1]
  else
    files = tonumber(r.GetExtState(folder, 'files'))
    pos = tonumber(r.GetExtState(folder, 'pos'))
    local f
    for i = 1, files do
      if pos <= files-1 then pos = pos+1 else pos = 1 end
      new_fn = r.GetExtState(folder, tostring(pos))
      if r.file_exists(new_fn) then f = pos break end
    end
    if not f then new_fn = nil
    else
      r.SetExtState(folder, 'pos', pos, 0)
    end

  end
  
  if new_fn then
    clonedsource = r.PCM_Source_CreateFromFile(new_fn)
    r.SetMediaItemTake_Source(tk, clonedsource)
    r.GetSetMediaItemTakeInfo_String(tk, 'P_NAME', new_fn:match[[.*\(.*)]], 1)
    r.UpdateItemInProject(it)
  end
  
  ::cnt::
  
end

r.Main_OnCommand(40439,0)
r.Main_OnCommand(40047,0)
r.PreventUIRefresh(-1)

r.Undo_EndBlock('Switch item source', -1)


