-- @description Auto solo for selected tracks (defer, obey track grouping)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

function sel_tracks_in_sel_tr_groups()

  local function Elem_in_tb(elem,tb)
    local found
    for eit = 1, #tb do if tb[eit] == elem then found = 1 break end end
    if found then return 1 end
  end

  local tracks = r.CountSelectedTracks()
  if tracks == 0 then return end

  local t = {}
  local t_tracks = {}

  for i = 0, tracks-1 do
    local tr = r.GetSelectedTrack(0,i)
    t_tracks[#t_tracks+1] = tr
    local _, chunk = r.GetTrackStateChunk(tr, '', 0)
    local group_flags = chunk:match'\nGROUP_FLAGS (.-)\n'
    if group_flags then
      for flag in group_flags:gmatch'%d+' do
        flag = tonumber(flag)
        if not (flag == 0 or Elem_in_tb(flag,t)) then t[#t+1] = flag end
      end
    end
  end

  if #t ==0 then return end

  local all_tracks = r.CountTracks()

  local t_to_sel = {}

  for i = 0, all_tracks-1 do
    local tr = r.GetTrack(0,i)
    if not Elem_in_tb(tr,t_tracks) then
      local _, chunk = r.GetTrackStateChunk(tr, '', 0)
      local group_flags = chunk:match'\nGROUP_FLAGS (.-)\n'
      if group_flags then
        for flag in group_flags:gmatch'%d+' do
          flag = tonumber(flag)
          if not flag ~= 0 and Elem_in_tb(flag,t) then
            if not r.IsTrackSelected(tr) then
              t_to_sel[#t_to_sel+1] = tr break
            end
          end
        end
      end
    end
  end

  if #t_to_sel==0 then return end
  
--  r.PreventUIRefresh(11)
  for i = 1, #t_to_sel do r.SetTrackSelected(t_to_sel[i],1) end
--  r.PreventUIRefresh(-11)

end

function solo_sel_tracks_unsolo_others()
  
  sel_tracks_in_sel_tr_groups()
  
  for i = 0, r.CountTracks()-1 do
    local tr = r.GetTrack(0,i)
    local sel = r.IsTrackSelected(tr)
    local soloed = r.GetMediaTrackInfo_Value(tr, 'I_SOLO')
    if sel == true then if soloed == 0 then r.SetMediaTrackInfo_Value(tr, 'I_SOLO', 2) end
    elseif soloed ~= 0 then r.SetMediaTrackInfo_Value(tr, 'I_SOLO', 0) end
  end
end


function main()
  local ch_count = r.GetProjectStateChangeCount()

  if not last_ch_count or last_ch_count ~= ch_count then
    r.Undo_BeginBlock()
    r.PreventUIRefresh(1)
    solo_sel_tracks_unsolo_others()
    r.PreventUIRefresh(-1)
    r.Undo_EndBlock('Auto solo for selected tracks (defer)', 2)

  end

  last_ch_count = ch_count
  r.defer(main)
end

----------------------------------------------------------------------------------------------------
function SetButtonON()
  r.SetToggleCommandState( sec, cmd, 1 ) -- Set ON
  r.RefreshToolbar2( sec, cmd )
  main()
end

----------------------------------------------------------------------------------------------------
function SetButtonOFF()
  r.SetToggleCommandState( sec, cmd, 0 ) -- Set OFF
  r.RefreshToolbar2( sec, cmd ) 
end
----------------------------------------------------------------------------------------------------

_, _, sec, cmd = r.get_action_context()
SetButtonON()
r.atexit(
function()
r.SoloAllTracks(0) -- unsolo all
SetButtonOFF()
end
)
