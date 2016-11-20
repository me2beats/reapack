-- @description Auto solo selected tracks (defer)
-- @version 1.1
-- @author me2beats
-- @changelog
--  + init
--  + rec arm like behavior (see some bugs when changing project tabs, will fix this soon)

r = reaper

function esc_lite (str) str = str:gsub('%-', '%%-') return str end

function Is_tb1_with_elem_in_tb(elem,tb,idx,ret_idx)
  found = nil; idx = idx or 1; ret_idx = ret_idx or 2
  for gtwe = 1, #tb do if tb[gtwe][idx] == elem then
    found = gtwe ret_val = tb[gtwe][ret_idx] break end
  end
  if found then return ret_val end
end

function Elem_in_tb(elem,tb)
  _found = nil
  for eit = 1, #tb do if tb[eit] == elem then _found = 1 break end end
  if _found then return true end
end


function bool_to_num(bool)
  if bool == true then return 1 elseif bool == false then return 0 end
end

local function SaveTracks ()
  sel_tracks = {}
  for i = 0, r.CountSelectedTracks(0)-1 do sel_tracks[i+1] = r.GetSelectedTrack(0, i) end
end

local function RestoreTracks ()
  r.Main_OnCommand(40297, 0) -- unselect all tracks
  for _, track in ipairs(sel_tracks) do r.SetTrackSelected(track, 1) end
end


local function SaveItems ()
  sel_items = {}
  for i = 0, r.CountSelectedMediaItems(0)-1 do sel_items[i+1] = r.GetSelectedMediaItem(0, i) end
end

local function RestoreItems ()
  r.Main_OnCommand(40289, 0) -- unselect all items
  for _, item in ipairs(sel_items) do r.SetMediaItemSelected(item, 1) end
end

function SaveCur() cur = r.GetCursorPosition() end

function RestoreCur() r.SetEditCurPos(cur, 0, 0) end


t = {}

function autosolo()

  auto_tb = {}

  tracks = r.CountTracks()

  for i = 0, tracks-1 do
    tr = r.GetTrack(0,i)
    _, tr_name = r.GetSetMediaTrackInfo_String(tr, 'P_NAME', '', 0)
    if tr_name == 'me2beats data' then tr_with_data = tr break end
  end

  if not tr_with_data then
    r.InsertTrackAtIndex(0, 0)
    r.TrackList_AdjustWindows(0)
    tr_with_data = r.GetTrack(0,0)
    r.GetSetMediaTrackInfo_String(tr_with_data, 'P_NAME', 'me2beats data', 1)
    tr_with_data = r.GetTrack(0,0)
    
    SaveTracks (); SaveItems (); SaveCur()

    r.SetOnlyTrackSelected(tr_with_data)

    r.Main_OnCommand(40914, 0) -- set first sel track as last touched track
    r.Main_OnCommand(40142, 0) -- insert empty item
    
    r.SetMediaTrackInfo_Value(tr_with_data, 'B_SHOWINMIXER', 0)
    r.SetMediaTrackInfo_Value(tr_with_data, 'B_SHOWINTCP', 0)

    RestoreTracks(); RestoreItems(); RestoreCur()


  end

  _, chunk = r.GetTrackStateChunk(tr_with_data, '', 0)

  notes = chunk:match'\n<NOTES\n|+(.-)\n>'



  if not notes then

    before, after = chunk:match'(.*\nIID.-\n)(.*)'

    notes = ''
    for i = 0, r.CountSelectedTracks()-1 do
      tr = r.GetSelectedTrack(0,i)
      if tr ~= tr_with_data then
        tr_guid = r.BR_GetMediaTrackGUID(tr)
        notes = notes..tr_guid..'1 '

        auto_tb[#auto_tb+1] = {tr_guid,1}

      end
      
    end


    add_notes = '<NOTES\n|+ '..notes..'\n>\n'

    r.SetTrackStateChunk(tr_with_data, before..add_notes..after, 0)

    return

  else

    for tr_guid in notes:gmatch'%S+' do
      if tr_guid ~= '+' then auto_tb[#auto_tb+1] = {tr_guid:sub(1,-2),tonumber(tr_guid:sub(-1))} end
    end
  end



  unauto_tb = {}
  solo_tb = {}

  r.PreventUIRefresh(1)

  for i = 1, #auto_tb do
    tr_guid = auto_tb[i][1]
    tr = r.BR_GetMediaTrackByGUID(0,tr_guid)
    
    last_sel = auto_tb[i][2]
    
    if not tr then unauto_tb[#unauto_tb+1] = {tr_guid,last_sel}
    else

      sel = r.IsTrackSelected(tr)

      if sel == true then
        if last_sel == 1 then
          sol = r.GetMediaTrackInfo_Value(tr, 'I_SOLO')
          if sol == 0 then
            unauto_tb[#unauto_tb+1] = {tr_guid,last_sel}
          end
        else
          sol = r.GetMediaTrackInfo_Value(tr, 'I_SOLO')
          if sol == 0 then r.SetMediaTrackInfo_Value(tr, 'I_SOLO', 2) end
        end
      else
        if last_sel == 1 then
          sol = r.GetMediaTrackInfo_Value(tr, 'I_SOLO')
          if sol ~= 0 then r.SetMediaTrackInfo_Value(tr, 'I_SOLO', 0) end
        else
          sol = r.GetMediaTrackInfo_Value(tr, 'I_SOLO')
          if sol ~= 0 then
            unauto_tb[#unauto_tb+1] = {tr_guid,last_sel}
          end
        end
      end
    end
  end

  r.PreventUIRefresh(-1)
  
  new = chunk

  for i = 1, #unauto_tb do
    table.remove(auto_tb,i)
    new = new:gsub(esc_lite (unauto_tb[i][1])..unauto_tb[i][2]..' ','')
  end
  
  r.SetTrackStateChunk(tr_with_data, new, 0)
  
  for i = 1, #auto_tb do
    tr_guid = auto_tb[i][1]
    tr = r.BR_GetMediaTrackByGUID(0,tr_guid)
    
    sel = r.IsTrackSelected(tr)
    last_sel = auto_tb[i][2]
    
    if sel == false and last_sel == 1 then 
      new = new:gsub(esc_lite (auto_tb[i][1])..'1',auto_tb[i][1]..'0')
    elseif sel == true and last_sel == 0 then 
      new = new:gsub(esc_lite (auto_tb[i][1])..'0',auto_tb[i][1]..'1')
    end
  end
  r.SetTrackStateChunk(tr_with_data, new, 0)
end


function main()
  local ch_count = r.GetProjectStateChangeCount()

  if not last_ch_count or last_ch_count ~= ch_count then

    autosolo()

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
r.atexit(SetButtonOFF)
