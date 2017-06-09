-- @description Toggle show-hide saved tracks, slot 1 (persist)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local slot = 1

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local notes = r.GetSetProjectNotes(0, 0, 0)
local data = notes:match'||me2beats_save_restore_tracks\r\n(.-\r\n)end||'
if not data then bla() return end
local sel_tracks_str = data:match('slot'..slot..' (.-)\r\n')
if not sel_tracks_str then bla() return end

local t = {}

for guid in sel_tracks_str:gmatch'{.-}' do
  local tr = r.BR_GetMediaTrackByGUID(0, guid)
  if tr then t[#t+1] = tr end
end

if #t == 0 then bla() return end

local ok

for i = 1, #t do
  local tr = t[i]
  if r.GetMediaTrackInfo_Value(tr, 'B_SHOWINMIXER')==1 and r.GetMediaTrackInfo_Value(tr, 'B_SHOWINTCP')==1 then ok = 0 break end
end

if not ok then ok = 1 end


r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 1, #t do
  local tr = t[i]
  r.SetMediaTrackInfo_Value(tr, 'B_SHOWINMIXER',ok)
  r.SetMediaTrackInfo_Value(tr, 'B_SHOWINTCP',ok)
end
r.TrackList_AdjustWindows(0)

r.PreventUIRefresh(-1) r.Undo_EndBlock('Toggle show saved tracks', -1)
