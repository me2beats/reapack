-- @description Wait for MIDI note - stop recording
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local rec = r.GetPlayState()==4 or r.GetPlayState()==5

if rec then r.OnStopButton() end

local ext_sec, ext_key = 'me2beats_record_wait', 'stop'
r.SetExtState(ext_sec, ext_key, '1', 0)

bla()
