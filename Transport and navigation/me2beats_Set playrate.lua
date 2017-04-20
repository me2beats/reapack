-- @description Set playrate
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local retval, rate = r.GetUserInputs("Set project playrate", 1, "Set project playrate:", "")
if not retval then bla() return end

rate = tonumber(rate)

if not rate or rate <0 then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)
r.CSurf_OnPlayRateChange(rate)
r.PreventUIRefresh(-1) r.Undo_EndBlock('Set rate', -1)
