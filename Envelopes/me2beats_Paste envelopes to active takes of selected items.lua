-- @description Paste envelopes to active takes of selected items
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

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

part = r.GetExtState("me2beats_copy-paste", "take_envelopes")
if not (part and part ~= '') then bla() return end

r.Undo_BeginBlock(); r.PreventUIRefresh(111)
items = r.CountSelectedMediaItems(0)
for i = 0, items-1 do
item = r.GetSelectedMediaItem(0,i)
_, chunk = r.GetItemStateChunk(item, '', 0)
take = r.GetActiveTake(item)
take_guid = r.BR_GetMediaItemTakeGUID(take)
if chunk:match(esc(take_guid)..'\n<SOURCE.->\n<TAKEFX\n') then
  before, after = chunk:match('(.*'..esc(take_guid)..'\n<SOURCE.->\n<TAKEFX.-\nWAK %d\n>)(.*)')
else before, after = chunk:match('(.*'..esc(take_guid)..'\n<SOURCE.->\n)(.*)') end
tb = {}
for env_part in after:gmatch('<.-ENV\n.->') do
  if not env_part:match('<(.-)ENV\n.->'):match('\n') then tb[#tb+1] = env_part end
end
after_new = after
for k = 1, #tb do after_new = after_new:gsub(esc(tb[k]), '', 1) end
after_new = after_new:gsub('\n+', '\n')

new_chunk = before..'\n'..part..after_new
r.SetItemStateChunk(item, new_chunk, 1)
end
r.PreventUIRefresh(-111); r.UpdateArrange()
r.Undo_EndBlock("Paste copied envelopes to active takes of sel items", -1)
