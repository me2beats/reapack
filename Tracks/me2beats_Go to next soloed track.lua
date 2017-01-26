-- @description Go to next soloed track
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

sel_tr = reaper.GetSelectedTrack(0, 0)
if sel_tr ~= nil then
  if reaper.AnyTrackSolo(0) == true then
    num_of_tracks = reaper.CountTracks(0)
    sel_tr_num = reaper.GetMediaTrackInfo_Value(sel_tr, "IP_TRACKNUMBER")
    status = 0 
    t = sel_tr_num
    while (status == 0 and t ~= num_of_tracks) do 
      got_tr = reaper.GetTrack(0, t)
      if (reaper.GetMediaTrackInfo_Value(got_tr, "I_SOLO") == 2 or reaper.GetMediaTrackInfo_Value(got_tr, "I_SOLO") == 1) then
        status = 1
      end
      if (t == num_of_tracks and status ~= 1) then 
        status = 2
      end
      if (t < num_of_tracks and status ~= 1) then
        t = t+1
      end
    end
  end
  if status == 1 then
    tr = reaper.GetTrack(0, t)
    reaper.SetOnlyTrackSelected(tr)
    reaper.Main_OnCommand(40913, 0) -- scroll sel track into view
  end
end
