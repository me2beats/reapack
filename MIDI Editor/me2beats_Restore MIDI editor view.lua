-- @description Restore MIDI editor view
-- @version 1.1
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function GetTrackChunk(track)
  if not track then return end
  local fast_str, track_chunk
  fast_str = r.SNM_CreateFastString("")
  if r.SNM_GetSetObjectState(track, fast_str, false, false) then
    track_chunk = r.SNM_GetFastString(fast_str)
  end
  r.SNM_DeleteFastString(fast_str)  
  return track_chunk
end

function SetTrackChunk(track, track_chunk)
  if not (track and track_chunk) then return end
  local fast_str, ret 
  fast_str = r.SNM_CreateFastString("")
  if r.SNM_SetFastString(fast_str, track_chunk) then
    ret = r.SNM_GetSetObjectState(track, fast_str, true, false)
  end
  r.SNM_DeleteFastString(fast_str)
  return ret
end

function esc(str) str = str:gsub('%-', '%%-') return str end

local take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then bla() return end

local ext_sec, ext_key = 'me2beats_save-restore', 'MIDI view'
local view = r.GetExtState(ext_sec, ext_key)
if not view or view == '' then bla() return end

local guid = r.BR_GetMediaItemTakeGUID(take)
local item = r.GetMediaItemTake_Item(take)

local tr = r.GetMediaItem_Track(item)

r.Undo_BeginBlock() r.PreventUIRefresh(1)

local sync
if r.GetToggleCommandStateEx(32060, 40640) == 1 then
  r.MIDIEditor_LastFocused_OnCommand(40640,0)--Timebase: Toggle sync to arrange view
  sync = 1
end

r.SelectAllMediaItems(0, 0); r.SetMediaItemSelected(item, 1)

local chunk = r.GetTrackChunk(tr)
local a, old_view, b = chunk:match('(.*'..esc(guid)..'.-CFGEDITVIEW)(.-)(\n.*)')
local new_chunk = a..view..b

r.MIDIEditor_LastFocused_OnCommand(2, 0) -- close editor

local tr_items = r.CountTrackMediaItems(tr)
for i = tr_items-1,0,-1 do
  local tr_item = r.GetTrackMediaItem(tr, i)
  r.DeleteTrackMediaItem(tr, tr_item)
  if item == tr_item then break end
end

SetTrackChunk(tr, new_chunk)

r.Main_OnCommand(40109,0)--Item: Open items in primary external editor

if sync then r.MIDIEditor_LastFocused_OnCommand(40640,0) end --Timebase: Toggle sync to arrange view

r.PreventUIRefresh(-1) r.Undo_EndBlock('Restore MIDI editor view', 2)