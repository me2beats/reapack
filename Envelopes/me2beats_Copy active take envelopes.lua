-- @description Copy active take envelopes
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

local r = reaper
local item = r.GetSelectedMediaItem(0,0)
if not item then return end
local _, chunk = r.GetItemStateChunk(item, '', 0)

local take = r.GetActiveTake(item)
if not take then return end

local take_guid = r.BR_GetMediaItemTakeGUID(take)

local part = chunk:match(esc(take_guid)..'\n<SOURCE.->\n(.->)\nTAKE') or
chunk:match(esc(take_guid)..'\n<SOURCE.->\n(.->)\n>')

if not part then return end
if not part:match('^<.-ENV\n') then return end

r.DeleteExtState("me2beats_copy-paste", "take_envelopes",0)
r.SetExtState("me2beats_copy-paste", "take_envelopes", part, 0)

