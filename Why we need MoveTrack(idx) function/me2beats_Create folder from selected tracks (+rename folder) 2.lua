-- @description Create folder from selected tracks (+rename folder) 2
-- @version 0.7
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function last_tr_in_folder(folder_tr)
  if r.GetMediaTrackInfo_Value(folder_tr, 'I_FOLDERDEPTH')~=1 then
    return folder_tr, r.GetMediaTrackInfo_Value(folder_tr, 'IP_TRACKNUMBER')-1
  end
  local last_i,last
  local dep = r.GetTrackDepth(folder_tr)
  local num = r.GetMediaTrackInfo_Value(folder_tr, 'IP_TRACKNUMBER')
  local tracks = r.CountTracks()
  for i = num+1, tracks do
    if r.GetTrackDepth(r.GetTrack(0,i-1)) <= dep then last_i = i-2 last = r.GetTrack(0,i-2) break end
  end
  if last_i then return last, last_i else return r.GetTrack(0, tracks-1),tracks-1 end
end

-----------------------------save restore env chunks

local t_env = {}
function sel_tracks_save_env_chunks(stop_track_i,tr_num,last_tr_num)

  local tracks = r.CountSelectedTracks()

  local start_i = stop_track_i or tr_num
  for i = start_i, last_tr_num do
    local tr = r.GetTrack(0,i-1)

    for category = -1, 1 do
      local sends_count = r.GetTrackNumSends(tr, category)
      for sendidx = 0, sends_count -1 do
        for envelopeType = 0, 2 do
          local env = r.BR_GetMediaTrackSendInfo_Envelope(tr, category, sendidx, envelopeType )
          local retval, xml = r.GetEnvelopeStateChunk( env, "", 0)
          local env_copy = r.BR_GetMediaTrackSendInfo_Envelope(tr, category, sendidx, envelopeType )
          t_env[env_copy]=xml
        end
      end
    end
  end
end

function sel_tracks_restore_env_chunks()
  for k,v in pairs(t_env) do
    r.SetEnvelopeStateChunk(k, v, 0)
  end
end
---------------------------------------------------------------------

local stop_track_i

function get_first_stop_track(tracks,tr,i)
  local i = i or r.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER')-1
  local _
  local tr = r.GetTrack(0,i)
  if not tr then return end
  if not r.IsTrackSelected(tr) then stop_track_i = i+1 return end
  _,i = last_tr_in_folder(tr)
  i = i+1
  get_first_stop_track(tracks,tr,i)
end

function sel_tracks_after_exist(num, sel_tracks)
  local f
  for i = sel_tracks-1,0,-1 do
    local tr = r.GetSelectedTrack(0,i)
    local tr_num = r.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER')
    if tr_num >= num then f = 1 break end
  end
  return f
end

function unsel_tracks_before(num, sel_tracks)

  local t = {}
  for i = 0, sel_tracks-1 do
    local tr = r.GetSelectedTrack(0,i)
    local tr_num = r.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER')
    if tr_num >= num then break end

    t[#t+1]=tr
  end
  for i = 1, #t do r.SetTrackSelected(t[i],0) end

end

function create_fol(first_tr,last_tr)

  local tr_num = r.GetMediaTrackInfo_Value(first_tr, 'IP_TRACKNUMBER')
  local last_sel_dep = r.GetMediaTrackInfo_Value(last_tr, 'I_FOLDERDEPTH')

  r.PreventUIRefresh(15)

  r.InsertTrackAtIndex(tr_num-1, 1)
  r.TrackList_AdjustWindows(0)
  local tr = r.GetTrack(0, tr_num-1)

  r.SetMediaTrackInfo_Value(tr, 'I_FOLDERDEPTH', 1)
  r.SetMediaTrackInfo_Value(last_tr, 'I_FOLDERDEPTH', last_sel_dep-1)
  r.SetOnlyTrackSelected(tr)
  r.Main_OnCommand(40914,0) -- Track: Set first selected track as last touched track
  
  r.PreventUIRefresh(-15)
  
  r.Main_OnCommand(40913,0) -- Track: Vertical scroll selected tracks into view
  r.Main_OnCommand(40696,0) -- Track: Rename last touched track
end

local tracks = r.CountTracks()
local sel_tracks = r.CountSelectedTracks()
if sel_tracks == 0 then bla() return end

local first_sel = r.GetSelectedTrack(0,0)
local first_sel_dep1 = r.GetTrackDepth(first_sel)

get_first_stop_track(tracks,first_sel)


r.Undo_BeginBlock()

local last_tr, tr_num

if not stop_track_i or not sel_tracks_after_exist(stop_track_i, sel_tracks) then

  tr_num = r.GetMediaTrackInfo_Value(first_sel, 'IP_TRACKNUMBER')

  local last_sel = r.GetSelectedTrack(0,sel_tracks-1)
  local last_sel_dep = r.GetMediaTrackInfo_Value(last_sel, 'I_FOLDERDEPTH')
  if last_sel_dep == 1 then last_tr = last_tr_in_folder(last_sel) else last_tr = last_sel end

else
  
  r.PreventUIRefresh(11)
  
  unsel_tracks_before(stop_track_i, sel_tracks)



  last_tr = r.GetSelectedTrack(0,r.CountSelectedTracks()-1)
  local last_tr_num = r.GetMediaTrackInfo_Value(last_tr, 'IP_TRACKNUMBER')
  
  sel_tracks_save_env_chunks(stop_track_i,tr_num,last_tr_num)

  r.Main_OnCommand(r.NamedCommandLookup('_S&M_CUTSNDRCV1'),0) -- SWS/S&M: Cut selected tracks (with routing)
  local last_before_stop = r.GetTrack(0,stop_track_i-2)
  local last_before_stop_dep1 = r.GetTrackDepth(last_before_stop)
  local last_before_stop_dep = r.GetMediaTrackInfo_Value(last_before_stop, 'I_FOLDERDEPTH')

  r.SetTrackSelected(last_before_stop,1)
  r.Main_OnCommand(40914,0) -- Track: Set first selected track as last touched track


  r.Main_OnCommand(r.NamedCommandLookup('_S&M_PASTSNDRCV1'),0) -- SWS/S&M: Paste tracks (with routing) or items

  sel_tracks_restore_env_chunks()

  if last_before_stop_dep~= 0 then
    local pasted_first_sel = r.GetSelectedTrack(0,0)
    r.SetMediaTrackInfo_Value(pasted_first_sel, 'I_FOLDERDEPTH', -first_sel_dep1)
    r.SetMediaTrackInfo_Value(last_before_stop, 'I_FOLDERDEPTH', first_sel_dep1-last_before_stop_dep1)
  end
  
  r.PreventUIRefresh(-11)
  
  last_tr = r.GetSelectedTrack(0,r.CountSelectedTracks()-1)
end

local first_num = r.GetMediaTrackInfo_Value(first_sel, 'IP_TRACKNUMBER')
local last_num = r.GetMediaTrackInfo_Value(last_tr, 'IP_TRACKNUMBER')

for i = first_num,last_num-1 do
  local tr = r.GetTrack(0,i)
  local dep1 = r.GetTrackDepth(tr)
  if dep1 < first_sel_dep1 then
    local prev_tr = r.GetTrack(0,i-1)
    if prev_tr then
      local dep = r.GetMediaTrackInfo_Value(prev_tr, 'I_FOLDERDEPTH')
      r.SetMediaTrackInfo_Value(prev_tr, 'I_FOLDERDEPTH', dep+r.GetTrackDepth(prev_tr)-dep1)
    end
  end
end

create_fol(first_sel,last_tr)


r.Undo_EndBlock('Create folder from selected tracks', -1)
