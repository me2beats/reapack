-- @description Save MIDI editor view, slot 2
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

function esc(str) str = str:gsub('%-', '%%-') return str end

local take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then bla() return end

local guid = r.BR_GetMediaItemTakeGUID(take)

local item = r.GetMediaItemTake_Item(take)

local tr = r.GetMediaItem_Track(item)

local chunk = r.GetTrackChunk(tr)

local view = chunk:match(esc(guid)..'.-CFGEDITVIEW(.-)\n')

if not view then bla() return end

local ext_sec, ext_key = 'me2beats_save-restore', 'MIDI view2'

r.DeleteExtState(ext_sec, ext_key, 0)
r.SetExtState(ext_sec, ext_key, view, 0)

r.Undo_BeginBlock() r.PreventUIRefresh(1)

r.PreventUIRefresh(-1) r.Undo_EndBlock('Save MIDI editor view', 2)

