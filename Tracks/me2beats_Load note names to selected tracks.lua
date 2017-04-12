-- @description Load note names to selected tracks
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local function read_only(file)
  local file_open = io.open(file, 'r'); local data = file_open:read('*a'); file_open:close(); return data
end

local OS = r.GetOS()
local slash
if OS == 'Win32' or OS == 'Win64' then slash = [[\\]] else slash = '/' end

local path = r.GetResourcePath()..slash.."MIDINoteNames"..slash.."*.*"

local _, file = r.GetUserFileNameForRead(path, "Track note names path:", "")

if not file or not r.file_exists(file) then bla() return end

local tracks = r.CountSelectedTracks()
if tracks == 0 then return end

t = {}

for i = 0, tracks-1 do
  local tr = r.GetSelectedTrack(0,i)
  t[#t+1] = r.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER')-1
end

notes_names_tb = {}

local data = read_only(file)
if not data then bla() return end

for line in data:gmatch("[^\n]+") do
  local pitch, name = line:match'^(%d+) (.*)$'
  if pitch then notes_names_tb[tonumber(pitch)] = name end
end

if not notes_names_tb then bla() return end



r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i =  1, #t do
  local tr = t[i]
  for p = 0, 126 do
    n = notes_names_tb[p]
    if n then
      r.SetTrackMIDINoteName(tr, p, -1, n)
    else
      r.SetTrackMIDINoteName(tr, p, -1, '')
    end
  end
end



r.PreventUIRefresh(-1) r.Undo_EndBlock('Load note names to selected tracks', -1)
