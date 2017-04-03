-- @description Copy FX of item under mouse to selected items (active takes)
-- @version 1.1
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local function esc (str)
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


local function get_active_take_fx_str(item)
  local _, chunk = r.GetItemStateChunk(item, '', 0)
  if not chunk:match'\nTAKE SEL' then
    local take_fx_ = chunk:match'\nNAME .-\n(<TAKEFX.-\nWAK .->.-)\nNAME '
    if not take_fx_ then
    
      local takes = r.GetMediaItemNumTakes(item)
      if takes == 1 then
        take_fx = chunk:match'(<TAKEFX.-\nWAK .->)\n'
        return take_fx
      end
    else  
      take_fx = 0 return take_fx
    end

    if take_fx_:match'\nNAME ' then take_fx = 0 else
      take_fx = chunk:match'(<TAKEFX.-\nWAK .->).-\nNAME '
    end
  else
    take_fx = chunk:match'\nTAKE SEL.-\n(<TAKEFX.-\nWAK .->).-\nNAME ' or
                    chunk:match'\nTAKE SEL.-\n(<TAKEFX.*\nWAK .->)'
  end
  return take_fx or 0
end

local mouse_it = r.BR_ItemAtMouseCursor()
if not mouse_it then bla() return end

local take = r.GetActiveTake(mouse_it)
if not take then return end


local fx = get_active_take_fx_str(mouse_it)

if fx == 0 then bla() return end


fx = take_fx..'\n'

local items = r.CountSelectedMediaItems()
if items == 0 then return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 0, items-1 do

  local item = r.GetSelectedMediaItem(0,i)
  if item == mouse_it then goto continue end
  local take = r.GetActiveTake(item)
  if not take then goto continue end

  guid = r.BR_GetMediaItemTakeGUID(take)

  local _, chunk = r.GetItemStateChunk(item, '', 0)

  chunk_no64 = chunk
  for x in chunk:gmatch('\nBYPASS %d+ %d+ %d+\n<.-\n(.-)>') do
    chunk_no64 = chunk_no64:gsub(esc(x), '')
  end

  chunk = chunk_no64

  if chunk:match'\nTAKE SEL' then a, b = chunk:match'(.*\nTAKE SEL.-\n<SOURCE .->\n)(.*)'
  else a, b = chunk:match'(.-\n<SOURCE .->\n)(.*)' end

  if b:match'\nNAME ' then b, c = chunk:match'(.-)(\nNAME.*)' end

  b = b:match'<TAKEFX.*\nWAK .-\n>(.*)' or b

  if c then chunk = a..fx..b..c else chunk = a..fx..b end

  r.SetItemStateChunk(item, chunk, 0)

  ::continue::

end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Copy FX of item under mouse to selected items', -1)