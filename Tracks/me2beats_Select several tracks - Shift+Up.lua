-- @description Select several tracks - Shift+Up
-- @version 0.9
-- @author me2beats
-- @changelog
--  + init

local r = reaper

function get_prev(num)
  for i = 0, 1000 do
    local tr = r.GetTrack(0,num-i)
    if tr and r.GetMediaTrackInfo_Value(tr, 'B_SHOWINMIXER')==1 and r.GetMediaTrackInfo_Value(tr, 'B_SHOWINTCP')==1 then
      tr_ = tr break
    end
    if not tr then break end
  end
  return tr_
end

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
  
  tracks = r.CountSelectedTracks(0)
  if tracks > 0 then
    r.PreventUIRefresh(1)
    upper = r.GetSelectedTrack(0,0)
    upper_num = r.GetMediaTrackInfo_Value(upper, 'IP_TRACKNUMBER')
  
    if upper_num >= last_touched_tr_num then
      upper_2 = get_prev(upper_num-2)
      if upper_2 then
        r.SetTrackSelected(upper_2,1)
        r.Main_OnCommand(40914,0) --set first sel track as last touched
      end
    else
      lower = r.GetSelectedTrack(0,tracks-1)
      if lower then
        lower_num = r.GetMediaTrackInfo_Value(lower, 'IP_TRACKNUMBER')
        lower_2 = get_prev(lower_num-2)
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
          r.SetTrackSelected(lower,0)
        end

      end
    end
    r.PreventUIRefresh(-1)
  end
end


r.Undo_BeginBlock()
main()
r.Undo_EndBlock('Sel tracks', -1)
