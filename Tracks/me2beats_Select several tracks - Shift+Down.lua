-- @description Select several tracks - Shift+Down
-- @version 0.9
-- @author me2beats
-- @changelog
--  + init

local r = reaper
--[[
function get_next_or_prev(num,go_next)
  if go_next then ii = num+i else ii = num-i end
  for i = 0, 1000 do
    local tr = r.GetTrack(0,ii)
    if tr and r.GetMediaTrackInfo_Value(tr, 'B_SHOWINMIXER')==1 and r.GetMediaTrackInfo_Value(tr, 'B_SHOWINTCP')==1 then
      tr_ = tr break
    end
    if not tr then break end
  end
  return tr_
end
--]]

function get_next(num)
  for i = 0, 1000 do
    local tr = r.GetTrack(0,num+i)
    if tr and r.GetMediaTrackInfo_Value(tr, 'B_SHOWINMIXER')==1 and r.GetMediaTrackInfo_Value(tr, 'B_SHOWINTCP')==1 then
      tr_ = tr break
    end
    if not tr then break end
  end
  return tr_
end

function main ()
  last_touched_tr = r.GetLastTouchedTrack()
  last_touched_tr_num = r.GetMediaTrackInfo_Value(last_touched_tr, 'IP_TRACKNUMBER')
  
  tracks = r.CountSelectedTracks()
  if tracks > 0 then
    r.PreventUIRefresh(1)
    lower = r.GetSelectedTrack(0,tracks-1)
    lower_num = r.GetMediaTrackInfo_Value(lower, 'IP_TRACKNUMBER')
  
    if lower_num <= last_touched_tr_num then
      lower_2 = get_next(lower_num)
      if lower_2 then
        tb = {}
        all_tracks = r.CountTracks(0)
        for i = 0, all_tracks-1 do
          tr = r.GetTrack(0,i)
          if r.IsTrackSelected(tr) == true then tb[#tb+1] = tr; r.SetTrackSelected(tr,0) end
        end
        r.SetTrackSelected(lower_2,1)
        r.Main_OnCommand(40914,0) --set first sel track as last touched
        for i = 1, #tb do r.SetTrackSelected(tb[i],1) end
      end
    else
      upper = r.GetSelectedTrack(0,0)
      if upper then
        r.SetTrackSelected(upper,0)
        r.Main_OnCommand(40914,0) --set first sel track as last touched
      end
    end
    r.PreventUIRefresh(-1)
  end
end

r.Undo_BeginBlock()
main()
r.Undo_EndBlock('Sel tracks', -1)

