-- @description Wait for MIDI note - play-stop
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local rec = r.GetPlayState()==4 or r.GetPlayState()==5
if rec or r.GetPlayState()==1 then r.OnStopButton() else r.OnPlayButton() end

local ext_sec, ext_key = 'me2beats_record_wait', 'stop'

local str = r.GetExtState(ext_sec, ext_key)
if str ~= '1' then r.SetExtState(ext_sec, ext_key, '1', 0) end

bla()
