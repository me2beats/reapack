-- @description Toggle mute for muted tracks
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

function toggle_x_for_xed_object(objects, obj_, x_, ext_sec, ext_key, unx_all, do_x, undo_str, get_obj_guid, get_obj_by_guid, add)

  function AnyObjectXed()
    for i = 0, objects-1 do
      local obj = obj_(i)
      local x = x_(obj)
      if x then xed = 1 break end
    end
    if xed then return true end
  end

  local xed_str = r.GetExtState(ext_sec, ext_key)

  r.Undo_BeginBlock(); r.PreventUIRefresh(1)


  if AnyObjectXed() then

    local cur_xed_str = ''
    for i = 0, objects-1 do
      local obj = obj_(i)
      local x = x_(obj)
      if x then cur_xed_str = cur_xed_str..get_obj_guid(obj) end
    end

    if cur_xed_str~=xed_str then
      r.DeleteExtState(ext_sec, ext_key, 0)
      r.SetExtState(ext_sec, ext_key, cur_xed_str, 0)
    end


    unx_all() -- unx all objects    

  else
    if xed_str and xed_str ~= '' then
      for guid in xed_str:gmatch'{.-}' do
        obj = get_obj_by_guid(guid)
        if obj then do_x(obj) end
      end
    end
  end

  if add then add() end

  r.PreventUIRefresh(-1); r.Undo_EndBlock(undo_str, -1)

end

toggle_x_for_xed_object(

r.CountTracks(),

function(i) return
r.GetTrack(0,i)
end,

function(obj) return
r.GetMediaTrackInfo_Value(obj, 'B_MUTE')==1
end,

'me2beats_str','tr_mute',

function() return
r.MuteAllTracks(0) -- unmute all
end,

function(obj) return
r.SetMediaTrackInfo_Value(obj, 'B_MUTE',1)
end,

'Toggle mute for muted tracks',

function(obj) return
r.GetTrackGUID(obj)
end,

function(guid) return
r.BR_GetMediaTrackByGUID(0, guid)
end
)

