-- @description Set project bpm according to selected take name bpm
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end;

local it = r.GetSelectedMediaItem(0,0)
if not it then bla() return end
local tk = r.GetActiveTake(it)
if not tk then bla() return end
local _, tk_name =  r.GetSetMediaItemTakeInfo_String(tk, 'P_NAME', 0, 0)
for bpm in tk_name:gmatch'%d+' do
  bpm = tonumber(bpm)
  if bpm <= 200 and bpm >= 50 then found = bpm break end
end
if not found then bla() return end

r.Undo_BeginBlock()
r.SetCurrentBPM(0, found, 1)
r.Undo_EndBlock('Set bpm', -1)
