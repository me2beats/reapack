-- @description Toggle mute for muted items
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


function unmute_all_items()
  for i = 0, r.CountMediaItems()-1 do
    local item = r.GetMediaItem(0,i)
    if r.GetMediaItemInfo_Value(item, 'B_MUTE')==1 then
      r.SetMediaItemInfo_Value(item, 'B_MUTE',0)
    end
  end
end


toggle_x_for_xed_object(

r.CountMediaItems(),

function(i) return
r.GetMediaItem(0,i)
end,

function(obj) return
r.GetMediaItemInfo_Value(obj, 'B_MUTE')==1
end,

'me2beats_str','it_mute',

function() return
unmute_all_items()
end,

function(obj) return
r.SetMediaItemInfo_Value(obj, 'B_MUTE',1)
end,

'Toggle mute for muted items',

function(obj) return
r.BR_GetMediaItemGUID(obj)
end,

function(guid) return
r.BR_GetMediaItemByGUID(0, guid)
end,

function() return
r.UpdateArrange()
end

)

