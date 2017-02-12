-- @description Select next hidden track
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

sel_tr = r.GetSelectedTrack(0,0)

if not sel_tr then bla() return end

sel_tr_num = r.GetMediaTrackInfo_Value(sel_tr, 'IP_TRACKNUMBER')

local tracks = r.CountTracks()

for i = sel_tr_num, tracks-1 do

  tr = r.GetTrack(0,i)
  if r.GetMediaTrackInfo_Value(tr, 'B_SHOWINTCP') == 0 or r.GetMediaTrackInfo_Value(tr, 'B_SHOWINMIXER') == 0 then

    r.Undo_BeginBlock()

    r.SetOnlyTrackSelected(tr,1)

    r.Undo_EndBlock('Select next hidden track', -1)

    break
  end


end

bla()
