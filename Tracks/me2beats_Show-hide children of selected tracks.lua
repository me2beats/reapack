-- @description Show-hide children of selected tracks
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

local function show_tcp_mcp(tracks_tb)
  local t = {}
  for i = 1, #tracks_tb do
    local tr = tracks_tb[i]

    local showintcp = r.GetMediaTrackInfo_Value(tr, 'B_SHOWINTCP')
    local showinmcp = r.GetMediaTrackInfo_Value(tr, 'B_SHOWINMIXER')

    t[#t+1] = {tr,showintcp,showinmcp}
  end
  return t
end


local function folders_and_childrens_from_sel_tracks(sel_tracks,all_tracks)

  local function first_tr_not_in_fol(folder_tr,all_tracks)
    local i_out,tr_out
    local t = {}
    local dep = r.GetTrackDepth(folder_tr)
    local tr_num = r.GetMediaTrackInfo_Value(folder_tr, 'IP_TRACKNUMBER')
    local tracks = r.CountTracks()
    for i = tr_num,tracks-1 do
      local tr = r.GetTrack(0,i)
      local tr_dep = r.GetTrackDepth(tr)
      if tr_dep <= dep then i_out,tr_out = i,tr break end

      if i == all_tracks-1 then i_out,tr_out,t[#t+1] = i,tr,tr break end

      t[#t+1] = tr
    end
    return i_out,tr_out,t
  end

  local t = {}

  local function main(iter)
    for i = iter, sel_tracks-1 do
      local tr = r.GetSelectedTrack(0,i)
      local tr_is_folder = r.GetMediaTrackInfo_Value(tr, 'I_FOLDERDEPTH')==1
      if tr_is_folder then
        local next_i, next_tr, t1 = first_tr_not_in_fol(tr,all_tracks)
        if not next_i then break end
        t[#t+1] = {tr,t1}
        main(next_i)
      end
    end
    return t
  end

  local t_res = main(0)

  return t_res
end




local function folders_and_childrens_from_sel_tracks(sel_tracks,all_tracks)

  local function first_tr_not_in_fol(folder_tr,all_tracks)
    local i_out,tr_out
    local t = {}
    local dep = r.GetTrackDepth(folder_tr)
    local tr_num = r.GetMediaTrackInfo_Value(folder_tr, 'IP_TRACKNUMBER')
    local tracks = r.CountTracks()
    for i = tr_num,tracks-1 do
      local tr = r.GetTrack(0,i)
      local tr_dep = r.GetTrackDepth(tr)
      if tr_dep <= dep then i_out,tr_out = i,tr break end

      if i == all_tracks-1 then i_out,tr_out,t[#t+1] = i,tr,tr break end

      t[#t+1] = tr
    end
    return i_out,tr_out,t
  end

  local t = {}

  local function main(iter)
    for i = iter, sel_tracks-1 do
      local tr = r.GetSelectedTrack(0,i)
      local tr_is_folder = r.GetMediaTrackInfo_Value(tr, 'I_FOLDERDEPTH')==1
      if tr_is_folder then
        local next_i, next_tr, t1 = first_tr_not_in_fol(tr,all_tracks)
        if not next_i then break end
        t[#t+1] = {tr,t1}
        main(next_i)
      end
    end
    return t
  end

  local t_res = main(0)

  return t_res
end


local tracks = r.CountSelectedTracks()
if tracks == 0 then return end

local all_tracks = r.CountTracks()


local f = folders_and_childrens_from_sel_tracks(tracks,all_tracks)

if #f == 0 then return end


local t_res = {}

for i = 1, #f do
  for j = 1, #f[i][2] do t_res[#t_res+1] = f[i][2][j] end
end

t_res = show_tcp_mcp(t_res)

local state

for i = 1, #t_res do
  local tr,showintcp,showinmcp = table.unpack(t_res[i])
  if showintcp == 1 or showinmcp == 1 then state = 1 break end
end

state = state or 0

local state_invert = math.abs(state-1)

r.Undo_BeginBlock()
r.PreventUIRefresh(1)

for i = 1, #t_res do

  local tr,showintcp,showinmcp = table.unpack(t_res[i])

  if showintcp == state then
    r.SetMediaTrackInfo_Value(tr, 'B_SHOWINTCP',state_invert)
  end
  if showinmcp == state then
    r.SetMediaTrackInfo_Value(tr, 'B_SHOWINMIXER',state_invert)
  end

end


r.TrackList_AdjustWindows(0)
--r.UpdateArrange()

r.PreventUIRefresh(-1)
r.Undo_EndBlock('Show/hide children', -1)

