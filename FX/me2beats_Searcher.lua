-- @description Searcher
-- @version 0.96
-- @author me2beats
-- @changelog
--  + init

local r = reaper


space = 26
show_main = true
stop_drag = true


local OS = r.GetOS()
if OS ~= 'Win32' and OS ~= 'Win64' then r.MB('This version requires Windows',0 ,0) bla() return end


locale = os.setlocale(nil)

local t_chars = {}
local lower_t = {}


if locale:match'Russian_Russia' then

  t_chars = {
  [184]='ё',
  [233]='й',
  [246]='ц',
  [243]='у',
  [234]='к',
  [229]='е',
  [237]='н',
  [227]='г',
  [248]='ш',
  [249]='щ',
  [231]='з',
  [245]='х',
  [250]='ъ',
  [244]='ф',
  [251]='ы',
  [226]='в',
  [224]='а',
  [239]='п',
  [240]='р',
  [238]='о',
  [235]='л',
  [228]='д',
  [230]='ж',
  [253]='э',
  [255]='я',
  [247]='ч',
  [241]='с',
  [236]='м',
  [232]='и',
  [242]='т',
  [252]='ь',
  [225]='б',
  [254]='ю',
  [168]='Ё',
  [201]='Й',
  [214]='Ц',
  [211]='У',
  [202]='К',
  [197]='Е',
  [205]='Н',
  [195]='Г',
  [216]='Ш',
  [217]='Щ',
  [199]='З',
  [213]='Х',
  [218]='Ъ',
  [212]='Ф',
  [219]='Ы',
  [194]='В',
  [192]='А',
  [207]='П',
  [208]='Р',
  [206]='О',
  [203]='Л',
  [196]='Д',
  [198]='Ж',
  [221]='Э',
  [223]='Я',
  [215]='Ч',
  [209]='С',
  [204]='М',
  [200]='И',
  [210]='Т',
  [220]='Ь',
  [193]='Б',
  [222]='Ю'}
  
  lower_t={
  ['А']='а',
  ['Б']='б',
  ['В']='в',
  ['Г']='г',
  ['Д']='д',
  ['Е']='е',
  ['Ё']='ё',
  ['Ж']='ж',
  ['З']='з',
  ['И']='и',
  ['Й']='й',
  ['К']='к',
  ['Л']='л',
  ['М']='м',
  ['Н']='н',
  ['О']='о',
  ['П']='п',
  ['Р']='р',
  ['С']='с',
  ['Т']='т',
  ['У']='у',
  ['Ф']='ф',
  ['Х']='х',
  ['Ц']='ц',
  ['Ч']='ч',
  ['Ш']='ш',
  ['Щ']='щ',
  ['Ъ']='ъ',
  ['Ы']='ы',
  ['Ь']='ь',
  ['Э']='э',
  ['Ю']='ю',
  ['Я']='я'}

else
  -- for turkish
  t_chars[252] = 'ü'
  t_chars[220] = 'Ü'
  t_chars[240] = 'ğ'
  t_chars[208] = 'Ğ'
  t_chars[231] = 'ç'
  t_chars[199] = 'Ç'
  t_chars[254] = 'ş'
  t_chars[222] = 'Ş'
  t_chars[246] = 'ö'
  t_chars[214] = 'Ö'
  t_chars[253] = 'ı'
  
  lower_t = {['Ü']='ü',['Ğ']='ğ',['Ş']='ş',['Ç']='ç',['Ö']='ö'}
end

----------------- fixed get/set track chunk
function GetTrackChunk(track)
  if not track then return end
  local fast_str, track_chunk
  fast_str = r.SNM_CreateFastString("")
  if r.SNM_GetSetObjectState(track, fast_str, false, false) then
    track_chunk = r.SNM_GetFastString(fast_str)
  end
  r.SNM_DeleteFastString(fast_str)  
  return track_chunk
end

function SetTrackChunk(track, track_chunk)
  if not (track and track_chunk) then return end
  local fast_str, ret 
  fast_str = r.SNM_CreateFastString("")
  if r.SNM_SetFastString(fast_str, track_chunk) then
    ret = r.SNM_GetSetObjectState(track, fast_str, true, false)
  end
  r.SNM_DeleteFastString(fast_str)
  return ret
end

function esc(str)
str = str:gsub('%(', '%%(')
str = str:gsub('%)', '%%)')
str = str:gsub('%.', '%%.')
str = str:gsub('%+', '%%+')
str = str:gsub('%-', '%%-')
str = str:gsub('%$', '%%$')
str = str:gsub('%[', '%%[')
str = str:gsub('%]', '%%]')
str = str:gsub('%*', '%%*')
str = str:gsub('%?', '%%?')
str = str:gsub('%^', '%%^')
str = str:gsub('/', '%%/')
return str end


function esc_lite(str) str = str:gsub('%-', '%%-') return str end

local function read_only(file)
  local file_open = io.open(file, 'r')
  local data = file_open:read'*a'
  file_open:close(); return data
end


function ExtractBrackets(str)
  local s, other, f = '',''
  local count = 1
  for line in str:gmatch('[^\n]+') do
    if not f then
      s = s..'\n'..line
      if line:sub(1,1) == '<' then count = count +1 end
      if line:sub(1,1) == '>' then count = count -1 end
      if count == 0 then f = 1 end
    else other = other..'\n'..line end
  end
  if s:sub(-1) == '>' then s = s:sub(1,-2) other = '>'..other end
  return s, other
end

function get_tr_fx_chain(tr,chunk)
  if chunk:match'\n<FXCHAIN\n' then
    local a,b,c
    a,b = chunk:match'(.-\n<FXCHAIN\n)(.*)'
    b,c = ExtractBrackets(b)

    return a,b,c
  end
end


str_tb = {}
local c_pos = 0

function minmax(x, minv, maxv) return math.min(math.max(x, minv),maxv) end

----------------------------------------

function DrawLoadStatus(what)
  gfx.set(0.9, 0.87, 0.82, 1)--set label color
  
  gfx.setfont(1, 'Verdana',22)
  ------------------
  gfx.x, gfx.y = 10, 0
  ------------------
  local s_x, s_y = 10, 17
  gfx.x, gfx.y = s_x, s_y
  ------------------
  gfx.drawstr(what)

--  if i == c_pos then gfx.line(gfx.x, gfx.y, gfx.x, gfx.y + gfx.texth) end -- cursor
  gfx.update();
end

function DrawInfoFrame()
--  gfx.set(1)
  gfx.set(0.9, 0.87, 0.82, 1)--set label color
  

  local s_x, s_y = 13, 17
  gfx.x, gfx.y = s_x, s_y

  local r_,g_,b_,a_  = 0.43,0.4,0.4,0.2
  gfx.set(r_,g_,b_,a_)--set btn color
  local x,y,w,h = 6, gfx.h-info_box_hei, gfx.w-10, info_box_hei-10

  local r_,g_,b_,a_ = 0.53,0.5,0.5,1
  gfx.set(r_,g_,b_,a_)--set btn color

  gfx.rect(x+1, y+1, w-2, h-2, false)--frame

end

function DrawText(str_tb)
--  gfx.set(1)
  gfx.set(0.9, 0.87, 0.82, 1)--set label color
  
  gfx.setfont(1, 'Verdana',18)
  ------------------
--  gfx.x, gfx.y = 11, 0
  ------------------
  local s_x, s_y = 13, 17
  gfx.x, gfx.y = s_x, s_y
  if c_pos == 0 then gfx.line(gfx.x, gfx.y, gfx.x, gfx.y + gfx.texth) end
  ------------------
  for i = 1, #str_tb do
    local c = str_tb[i]
    if c ~= 13 then if type(c) == 'string' then gfx.drawstr(c) else gfx.drawchar(c) end end
    if i == c_pos then gfx.line(gfx.x, gfx.y, gfx.x, gfx.y + gfx.texth) end -- cursor
  end

  local r_,g_,b_,a_  = 0.43,0.4,0.4,0.2
  gfx.set(r_,g_,b_,a_)--set btn color
  local x,y,w,h = 7, 10, gfx.w-11, 35
--  gfx.rect(x,y,w,h,true)--body
  
--  local r_,g_,b_,a_  = 0.43,0.4,0.4,1
  local r_,g_,b_,a_  = 0.63,0.6,0.6,1
  gfx.set(r_,g_,b_,a_)--set btn color
  
  gfx.rect(x+1, y+1, w-2, h-2, false)--frame
      
end


function lower1(s,lower_t)
  
  for k,v in pairs(lower_t) do
    if s:match(k) then s = s:gsub(k,v) end
  end
  s = s:lower()

  return s
end



function new_tb(t)
  local t_new = {}
  for i = 1, #t do
    t_new[i] = t[i]
  end
  return t_new
end


function Elem_in_tb(elem,tb)
  local found
  for eit = 1, #tb do if tb[eit] == elem then found = 1 break end end
  return found
end

function Elem_in_tb_kv(elem,tb)
  local found
  for eit = 1, #tb do if tb[eit] == elem then found = 1 break end end
  return found
end

function Elem_in_tb_match(elem,tb)
  local found
  for eit = 1, #tb do if tb[eit]:match('^'..elem) then found = 1 break end end
  return found
end

function new_guids(str)
  t_guids = {}
  for guid in str:gmatch'{........%-....%-....%-....%-............}' do
    if not Elem_in_tb_kv(guid,t_guids) then t_guids[#t_guids+1] = guid end
  end
  for i = 1, #t_guids do str = str:gsub(esc_lite(t_guids[i]),r.genGuid()) end
  return str
end

function add_tr_fx_chain(tr, chunk, new_chain, replace7)
  if not tr then return end

  local fx = r.TrackFX_GetCount(tr)
  local fx_chain

  local a,b,c = get_tr_fx_chain(tr,chunk)

  if b then
    if replace7 and replace7~=0 then
      chunk = a..new_chain..'\n'..c
    else
      chunk = a..b..new_chain..'\n'..c
    end
  else
    local a,b,c
    a, c = chunk:match'(.-\nMAINSEND.-\n)(.*)'
    b = '<FXCHAIN\n'..new_chain..'\n>\n'
    chunk = a..b..c
  end

  SetTrackChunk(tr, chunk)

end

function insert_track(num)
  r.InsertTrackAtIndex(num,1)
  local new_tr = r.GetTrack(0, num)
  r.TrackList_AdjustWindows(0)
  r.UpdateArrange()
  return new_tr
end

----------------------------------- parse fx ------------------------------

js_tb = {}
vst_tb = {}
vst_bridge_tb = {}

function parse_js_ini()
  local fn = res_path..[[\]]..'reaper-jsfx.ini'
  if not r.file_exists(fn) then return end
  local str = read_only(fn)

  if not str then return end
  str = str:match'(.-)\nREV '

  for line in str:gmatch("[^\n]+") do
    if line ~= '' then
      line = line:match'NAME (.*)'
      if line then
        local a,b
        if line:match'".-".-".-"' then
          a,b = line:match'"(.*)" "(.*)"'
        elseif line:sub(1,1) == '"' then
          a,b = line:match'"(.*)" (.*)'
        elseif line:sub(-1) == '"' then
          a,b = line:match'(.*) "(.*)"'
        else
          a,b = line:match'(.*) (.*)'
        end

        if a then js_tb[underscore(a)] = {a,b} end
      end
    end
  end
end



function parse_vst_ini()

  function parse_vst(fn)
    if not r.file_exists(fn) then return end
    local str = read_only(fn)
    if not str then return end

    for line in str:gmatch("[^\n]+") do
      if line ~= '' then
        local module,info = line:match'(.-)=(.*)'
        if module then
          local id1,id2,name
          if info then id1,id2,name = info:match'(.-),(.-),(.*)' end
  
          if id1 then
            local mutant_module = module
            mutant_module = mutant_module:gsub('<','_')
            mutant_module = mutant_module:gsub('.dll','')
            if module:match'%.vst3' then mutant_module = 'vst3_'..module:gsub('%.vst3','') end            
            
            vst_tb[mutant_module] = {module,id1,id2,name}
          end
        end
      end
    end
  end

  parse_vst(res_path..[[\]]..'reaper-vstplugins64.ini')
  parse_vst(res_path..[[\]]..'reaper-vstplugins.ini')

end



function underscore(str)
  str = str:gsub('/', '_')
  str = str:gsub('%.', '_')
  str = str:gsub('%+', '_')
  return str
end

function underscore2(str)
  str = str:gsub(' ', '_')
  str = str:gsub('/', '_')
  str = str:gsub('%.', '_')
  str = str:gsub('%-', '_')
  str = str:gsub('%(', '_')
  str = str:gsub('%)', '_')
  str = str:gsub('%+', '_')
  return str
end

-----------------------------------------------------------------

function plugin_exist(fx_type, module_name)
  local sub_tb
  if fx_type == 'js' then
    sub_tb = js_tb[module_name]
  elseif fx_type == 'vst' or fx_type == 'vst3' then

    if fx_type == 'vst3' then
         sub_tb = vst_tb[underscore2(fx_type..'-'..module_name)]
    else sub_tb = vst_tb[underscore2(module_name)] end
  end
  return sub_tb
end




function create_fx_chain(sub_tb,fx_type,module_name)
  local fx_chain, name

  if fx_type == 'js' then
    local module_name = sub_tb[1]
    if module_name:match' ' then module_name='"'..module_name..'"' end
    fx_chain = '<'..'JS'..' '..module_name..'\n>'
  
  elseif fx_type == 'vst' or fx_type == 'vst3' then
    name = sub_tb[4]
  
    if fx_type == 'vst3' then module_name = module_name..'.vst3'
    elseif fx_type == 'vst' then module_name = module_name..'.dll' end
  
    if module_name:match' ' then module_name='"'..module_name..'"' end
  
    fx_type=fx_type:upper()
  
    if name:sub(-7) == '!!!VSTi' then name=name:sub(1,-8) fx_type = 'VSTi' end
  
    if fx_type == 'vst' then
      fx_chain = '<VST '..'"'..fx_type..': '..name..'" '..module_name..'\nPRESETNAME\n>'
    else
      fx_chain = '<VST '..'"'..fx_type..': '..name..'" '..module_name..' 0 "" '..sub_tb[3]..'{'..sub_tb[2]..'}'..'\nPRESETNAME\n>'
    end
  end
  
  return fx_chain, name

end

function add_fx(preset_file_name,tr,chunk,fx_chain)

  local fx_type, module_name = preset_file_name:match'(.-)%-(.*)%.ini'  

  local sub_tb = plugin_exist(fx_type, module_name)
  if not sub_tb then return end

  local fx_chain = create_fx_chain(sub_tb,fx_type,module_name)

  add_tr_fx_chain(tr, chunk, fx_chain, 0)

end


function split(str,sub_str)
  local t = {}
  str = str:gsub(sub_str,sub_str..sub_str)
  str = str:gsub(sub_str,'',1)
  str = str..sub_str
  for cap in str:gmatch('('..sub_str..'.-)'..sub_str..'') do
    t[#t+1] = cap
  end
  return t
end

function UnselectAllTracks()
  local first_track = r.GetTrack(0, 0)
  r.SetOnlyTrackSelected(first_track)
  r.SetTrackSelected(first_track, 0)
end

function add_tr_template(tr_idx, template_str, select7, mixer_scroll7, tcp_scroll7)
  tr_idx = tr_idx or r.CountTracks()
  idx_0 = tr_idx

  UnselectAllTracks()
  template_str = new_guids(template_str)
  
  local t_chunks = split(template_str,'<TRACK\n')
  
  local i1 = 1
  for i = 1, #t_chunks do
    local new_chunk = t_chunks[i]
    
    local t = {}
    
    i1 = i1+1
    
    for send_line in new_chunk:gmatch'(AUXRECV %d+ %d+ .-\n)' do
      local a, send_num, b = send_line:match'(AUXRECV )(%d+)(.*)'
      
      local new_send_line = a..math.floor(tonumber(send_num)+idx_0 + 0.5)..b
      t[#t+1] = {send_line,new_send_line}
    end
    
    for i = 1, #t do new_chunk = new_chunk:gsub(esc(t[i][1]),t[i][2],1) end
    
    local tr = insert_track(tr_idx)
    SetTrackChunk(tr, new_chunk)


    if select7 and select7~=0 then
      r.SetTrackSelected(tr,1)
    end

    tr_idx=tr_idx+1

  --[[  
    if mixer_scroll7 and select7~=0 then r.SetMixerScroll(tr) end
    
  --]]
  end
  r.Main_OnCommand(40914,0)-- Track: Set first selected track as last touched track
  if tcp_scroll7 then
    r.Main_OnCommand(40913,0) --Track: Vertical scroll selected tracks into view
  end
end


local t_env={}
function save_and_delete_env_chunk(tr_chunk)
  for env_chunks in chunk:gmatch 'FXID {.-\n(.-)WAK %d\n' do
    for env_chunk in env_chunks:gmatch'' do
    end
  end
end

t_info = {}

function get_fx_names(data, fn_type)
  local fx_names = {}
  local x

  for fx_first_line in data:gmatch'<VST (.-)\n' do
    local name = fx_first_line:match'".-: (.-)"'
    
--    if not Elem_in_tb_kv(name,fx_names) then fx_names[#fx_names+1] = name end
    if not Elem_in_tb_kv(name,fx_names) then fx_names[#fx_names+1] = name:gsub('%(.-%)','') end
  end

  for fx_first_line in data:gmatch'<JS (.-)\n' do
    local name
    if fx_first_line:sub(1,1) == '"' then name = fx_first_line:match'"(.-)" '
    else name = fx_first_line:match'(.-) ' end
    
    name = underscore(name)
    local name_fix = js_tb[name]
    if name_fix then name_fix = name_fix[2] else name_fix = name end
    
    if not Elem_in_tb_kv(name_fix,fx_names) then fx_names[#fx_names+1] = name_fix:gsub('%(.-%)','') end
  end

  return fx_names
end

function count_tracks_in_tr_template(data)
  local i = 0
  for track in data:gmatch'<TRACK\n' do
    i = i+1
  end
  return i
end

function get_info(fn,file_type)
-- file_type: 0 == fx_chain, 1 == tr_template, 2 = fx_preset
  local data = read_only(fn)

  if file_type == 0 then

    t_info[fn] = {file_type,get_fx_names(data)}

  elseif file_type == 1 then

    local tracks = count_tracks_in_tr_template(data)
    t_info[fn] = {file_type,get_fx_names(data),tracks}
  elseif file_type == 2 then
    fx = 0
    t_info[fn] = {file_type,fx}
  end
end

function get_file_type(exp)
  local t
  if exp == '.RfxChain' then t = 0
  elseif exp == '.RTrackTemplate' then t = 1
  else t = 2 end
  return t
end


t_preset_names = {}

function enum_fx_presets(fx_ini_fn)
  local t = {}

  local fx_type, module_name = fx_ini_fn:match('.*'..[[\]]..'(.-)%-(.*)%.ini')

  local sub_tb = plugin_exist(fx_type, module_name)
  
  if not sub_tb then return t,-1 end

  local fx_data = read_only(fx_ini_fn)
  if fx_data:match'^%[General%]\nNbPresets=0' then return -1,-1 end -- file exists but 0 presets


  local fx_chain, name = create_fx_chain(sub_tb,fx_type,module_name)
  if not name and fx_type == 'js' then
    name = sub_tb[2]
  end
  
  if not fx_chain then return -1,-1 end
  
  t_preset_names[fx_ini_fn] = name

  for preset_name in fx_data:gmatch'\nName=(.-)\n' do
--    t[#t+1] = {name = preset_name, fx_name = module_name, m_type = 2, chain = fx_chain, fn = fx_ini_fn}
    t[#t+1] = {name = preset_name, fx_name = module_name:gsub('%(.-%)',''), m_type = 2, chain = fx_chain, fn = fx_ini_fn}
  end
  
  return t
end

function get_size(fn)
  local file_open = io.open(fn, 'r')
  local size = file_open:seek("end")
  file_open:close(); return size
end

sizes_tb = {}

only_files_tb = {}

found_tb = {}


t = {}

Colors_tb = {['0']= {0.99, 0.88, 0.26},['1']={0.26, 0.73, 0.99},['2']={0.1, 0.9, 0.1}}

B_lbl_tb = {'Ch','T','P'}



Actions_TB = {}

action_name = ''

sel_tb = {}

hei = 40
--info_box_hei = 130

rgba_0 = {0.3,0.3,0.3,1}

local Button_TB,Color_TB,Filter_TB,Info_TB,FX_TB

gfx.clear = r.ColorToNative(54, 51, 51)

local info_x = 12


local function only_get_all_files(in_dir,type_out,exp)

  t_all = t_all or {}

  local function get_all_files_main(in_dir,type_out,exp)
    for i = 0, 10000 do
      local fn = r.EnumerateFiles(in_dir, i)
      DrawLoadStatus('Count files ...')
      if not fn or fn == '' then break end
      local full = in_dir..[[\]]..fn
      if fn:match(exp..'$') then t_all[#t_all+1] = {full,fn,type_out,exp} end
    end
    for i = 0, 10000 do
      local dir = r.EnumerateSubdirectories(in_dir,i)
      if not dir or dir == '' then break end
      get_all_files_main(in_dir..[[\]]..dir,type_out,exp)
    end
--    return t
  end


  return get_all_files_main(in_dir,type_out,exp)
end





--------------- get_all_files

local function get_all_files(t_all)

  local files_tb = {}

  for i = 1, #t_all do
    percent = i
    DrawLoadStatus(math.ceil(percent*100/#t_all)..' %')
    local full,fn,type_out,exp = table.unpack(t_all[i])
    local size = get_size(full)
    sizes_tb[full] = size
  
    if exp == '.ini' then
      local t = {}
      if not cash_tb[full] or tonumber(cash_tb[full][1].file_size) ~= size then
        t,ret = enum_fx_presets(full,fn:match'(.*)%.ini')
        if ret ~= -1 then

          cash_tb[full] = cash_tb[full] or {}
          for i = 1, #t do
            table.insert(cash_tb[full],{file_size = size, name = t[i].name, fx_name = t[i].fx_name, m_type = 2, chain = t[i].chain, fn = full})
            
          end
        else
        end
        
      else
        t = cash_tb[full]
      end
      if ret ~= -1 then
        for i = 1, #t do table.insert(files_tb,t[i]) end
      end
    else
      files_tb[#files_tb+1] = full
      if not cash_tb[full] or tonumber(cash_tb[full][3]) ~= size then

        local file_type = type_out
        get_info(full, file_type)
        
        cash_tb[full] = {file_type, {file_type, t_info[full][2]}, size}
      else
        t_info[full]=cash_tb[full][2]
      end
    end
          
  end
  return files_tb

end



-----------------------------------------


function dockButton()

  local dockState = gfx.dock(-1)
  if dockState == 0 then
    local lastDock = tonumber(r.GetExtState(EXT_SECTION, EXT_LAST_DOCK))
    if not lastDock or lastDock < 1 then lastDock = 1 end

    gfx.dock(lastDock)
  else
    r.SetExtState(EXT_SECTION, EXT_LAST_DOCK, tostring(dockState), 1)
    gfx.dock(0)
  end
end


function previousWindowState()
  local state = tostring(r.GetExtState(EXT_SECTION, EXT_WINDOW_STATE))
  return state:match("^(%d+) (%d+) (%d+) (-?%d+) (-?%d+)$")
end

function saveWindowState()
  local dockState, xpos, ypos = gfx.dock(-1, 0, 0, 0, 0)
  local w, h = gfx.w, gfx.h
  if dockState > 0 then
    w, h = previousWindowState()
  end

  r.SetExtState(EXT_SECTION, EXT_WINDOW_STATE,
    string.format("%d %d %d %d %d", w, h, dockState, xpos, ypos), 1)
end

function get_phrase(str_tb)

  local s = ''
  for i = 1, #str_tb do
    if type(str_tb[i]) == 'string' then s = s..str_tb[i] else s = s..string.char(str_tb[i]) end
  end
  return s
  
end

function words_tb_l(phrase)
  local tb = {}
  for word in phrase:gmatch'%S+' do tb[#tb+1] = lower1(word,lower_t) end
  return tb
end

local function create_dir (path, dir)
  if OS == 'Win32' or OS == 'Win64' then path = path:gsub([==[\]==], [==[\]==])..[[\\]]..dir
  else path = path..[[/]]..dir end
  r.RecursiveCreateDirectory(path, 0)
end

local function write (file, str)
  local file_open = io.open(file, 'w'); file_open:write(str); file_open:close()
end


local function write_to_end (file, str)
  local file_open = io.open(file, 'a'); file_open:write(str); file_open:close()
end


function os_path (path, addstr)
--needs OS == r.GetOS()
  if OS == 'Win32' or OS == 'Win64' then path = path..[[\]]..addstr
  else path = path..[[/]]..addstr end
  
  if path:match('|') then 
    if OS == 'Win32' or OS == 'Win64' then path = path:gsub('|', [==[\]==])
    else path = path:gsub('|', [[/]]) end
  end
  return path
end



function sort_on_values(t,...)
  local a = {...}
  table.sort(t,
  function (u,v)
    for i = 1, #a do
      if not u[a[i]] then return false
      else
        if type(u[a[i]]) == 'string' then
          if u[a[i]]:lower() > v[a[i]]:lower() then return false end
          if u[a[i]]:lower() < v[a[i]]:lower() then return true end
        else
          if not u[a[i]] then return false elseif not v[a[i]] then return true end
          if u[a[i]] > v[a[i]] then return false end
          if u[a[i]] < v[a[i]] then return true end
        end
      end
    end
  end)
end

function show()
  for i = #t_sorted, 1,-1 do
    if not show_ch and t_sorted[i].m_type == 0 or
       not show_t  and t_sorted[i].m_type == 1 or
       not show_p  and t_sorted[i].m_type == 2 then
      table.remove(t_sorted,i)
    end
  end
end



function get_cash()

  cash_tb = {}
  
  if data ~= '' then
    for obj_type,fullname,size,other in data:gmatch'||preset (.-)\n(.-)\n(.-)\n(.-\n)preset end||' do
      DrawLoadStatus('Read cache ...')
      if other ~= '' or '\n' then
        size, obj_type = tonumber(size), tonumber(obj_type)
        sizes_tb[fullname] = sizes_tb[fullname] or size
        if obj_type == 2 then
          cash_tb[fullname] = cash_tb[fullname] or {}
          for preset_name,module_name,fx_chain in other:gmatch'(.-.)\n(.-.)\n(<.->)\n' do
            
  
            table.insert(cash_tb[fullname],{file_size = size, name = preset_name, fx_name = module_name, m_type = 2, chain = fx_chain, fn = fullname})
          end
        elseif obj_type == 0 or obj_type == 1 then
          local fx_names = {}
          for fx_name in other:gmatch'(.-)|=|' do
            if fx_name ~= '' then
              fx_names[#fx_names+1] = fx_name
            end
          end
          cash_tb[fullname] = {obj_type,{obj_type,fx_names},size}
        end
      end
    end
  end
end


function cash_tb_to_str()

  str = ''
  for fullname, t in pairs(cash_tb) do
    local str1, size, obj_type = ''
    size = sizes_tb[fullname]
    if t[1] == 0 or t[1] == 1 then obj_type = t[1] else obj_type = 2 end
    str = str..'||preset '..obj_type..'\n'..fullname..'\n'..size..'\n'
    if t[1] == 0 or t[1] == 1 then
      if obj_type == 0 or obj_type == 1 then
        for i = 1, #t[2][2] do
          fx_name = t[2][2][i]
          str1 = str1..fx_name..'|=|'
        end
      end
    elseif obj_type == 2 then
      for i = 1, #t do
        preset_name,module_name,fx_chain = t[i].name, t[i].fx_name, t[i].chain
        str1 = str1..preset_name..'\n'..module_name..'\n'..fx_chain..'\n'
      end
      str1 = str1:sub(1,-2)
    end
    str = str..str1..'\npreset end||\n'
  end
  
  write(cash_file,str)

end



function alphanumsort(o)
   local function conv(s)
      local res, dot = "", ""
      for n, m, c in tostring(s):gmatch"(0*(%d*))(.?)" do
         if n == "" then
            dot, c = "", dot..c
         else
            res = res..(dot == "" and ("%03d%s"):format(#m, m)
                                  or "."..n)
            dot, c = c:match"(%.?)(.*)"
         end
         res = res..c:gsub(".", "\0%0")
      end
      return res
   end
   table.sort(o,
      function (a, b)
         local ca, cb = conv(a), conv(b)
         return ca < cb or ca == cb and a < b
      end)
   return o
end




function update_tracks_tb()
  Button_TB ={}
  Color_TB ={}
  Filter_TB ={}
  Info_TB ={}
  FX_TB ={}
  B_TB ={}

  local btn={xywh={15,0,150,hei}, rgba=rgba_0, fnt={"Verdana",15}}
  table.insert(Filter_TB,btn)



  local file_type
  if action_name_full and cash_tb[action_name_full] then
    if type(cash_tb[action_name_full][1])=='number' then
      file_type = cash_tb[action_name_full][1]
    else
      if type(cash_tb[action_name_full][1])=='table' then file_type = 2 end -- !! we have only 3 types for this moment
    end

    if file_type == 2 then

      y = gfx.h-info_box_hei+25

      local btn={xywh={info_x,y,150,hei}, rgba=rgba_0, fnt={"Verdana",14},fx=cash_tb[action_name_full][1].fx_name}
      table.insert(FX_TB,btn)
      y = y + 15

    elseif file_type == 0 or file_type == 1 then

--      y = 40
      y = gfx.h-info_box_hei+25

      for i = 1, #cash_tb[action_name_full][2][2] do
        local btn={xywh={info_x,y,150,hei}, rgba=rgba_0, fnt={"Verdana",14}, fx = cash_tb[action_name_full][2][2][i]}
        table.insert(FX_TB,btn)
        y = y + 15
      end
  
    end
  end  
  

  y = hei

  y_max = y
  for k, v in pairs(Button_TB) do
    _,y_cand  = table.unpack(v.xywh)
    if y_cand > y_max then y_max = y_cand end
  end
  
  do
    local info_x = info_x
    for i = 1, 3 do
      table.insert(B_TB,{xywh={info_x,gfx.h-info_box_hei,15,hei}, lbl = B_lbl_tb[i], rgba=rgba_0, fnt={"Verdana",15}})
      info_x = info_x+20
    end
  end

  table.insert(Info_TB,{xywh={info_x,gfx.h-info_box_hei,info_box_hei+20,hei}, rgba=rgba_0, fnt={"Verdana",15}})

  sel_tb = {}

  y = hei


  for j = 1, #t_sorted do
    local full_nm,short_nm = t_sorted[j].fullname, t_sorted[j].name

    if phrase and phrase ~= '' then
    
      local t_words = {}
      
      for pre_word in short_nm:gmatch'%P+' do
        for word in pre_word:gmatch'%S+' do
          word = lower1(word,lower_t)
          if not Elem_in_tb(word,t_words) then t_words[#t_words+1]=word end
        end
      end

      for i = 1,#words_l do
        local word = words_l[i]
        if not Elem_in_tb_match(word,t_words) then goto continue2 end
      end
    end

    
--    local btn={xywh={15,y,150,hei}, rgba=rgba_0, fnt={"Verdana",15},fullname = full_nm, m_type = t_sorted[j].m_type}
    local btn={xywh={15,y,gfx.w-15-4,hei}, rgba=rgba_0, fnt={"Verdana",15},fullname = full_nm or t_sorted[j].fn, m_type = t_sorted[j].m_type}
    
    if t_sorted[j].m_type == 2 then
      btn.fx=t_sorted[j].fx_name
      btn.chain=t_sorted[j].chain
      btn.lbl=t_sorted[j].name
      
      btn.fx_fn = t_sorted[j].fn
      
    else
      btn.lbl=short_nm
    end

    table.insert(Button_TB,btn)

    local btn={xywh={3,y,10,hei-6}, rgba=Colors_tb[tostring(t_sorted[j].m_type)] or {0,0,0},col= color}
    
    
    table.insert(Color_TB,btn)
    y = y + hei
    ::continue2::
  end
  
  y_max = y
  for k, v in pairs(Button_TB) do 
    _,y_cand  = table.unpack(v.xywh)
    if y_cand > y_max then y_max = y_cand end
  end
  
  y_offs_min = -y_max

end





--------------------------------------- init


EXT_SECTION = 'me2beats_searcher'
EXT_WINDOW_STATE = 'window_state'
EXT_LAST_DOCK = 'last_dock'



r.PreventUIRefresh(11)


dockButton()

local w_, h_, dockState, x_, y_ = previousWindowState()

if w_ then
     gfx.init("Searcher", w_ ,h_, dockState, x_, y_)
else gfx.init("Searcher", 300,600 ) end


r.PreventUIRefresh(-11)

------------------------------------------------------------------

res_path = r.GetResourcePath()
if not res_path then return end

parse_js_ini()

parse_vst_ini()

me2beats_path = os_path(res_path, 'me2beats')
cash_file = os_path(me2beats_path, 'cash_file.txt')

settings_file = os_path(me2beats_path, 'settings_file.txt')

for i = 0, 1000 do
  dir = r.EnumerateSubdirectories(res_path, i)
  if dir == 'me2beats' then found = 1 break
  elseif dir == '' or not dir then break end
end

if not found then
  r.RecursiveCreateDirectory(me2beats_path, 0)
  write(cash_file, '')
  data = ''
  write(settings_file, '')
  settings_data = ''
end

if r.file_exists(cash_file) then data = read_only(cash_file) end
if not data then write(cash_file, '') data = '' end

if r.file_exists(settings_file) then settings_data = read_only(settings_file) end
if not settings_data then write(settings_file, '') settings_data = '' end

show_menu = settings_data:match"(!Show FX chains|.-)\n" or
                  settings_data:match"(Show FX chains|.-)\n"


if not show_menu then
  show_menu = "!Show FX chains|!Show track templates|!Show presets|"
  settings_data = show_menu..'\n'..settings_data
  write(settings_file, settings_data)
end

info_box_hei = settings_data:match'info_box_hei=(.-)\n'
if not info_box_hei then
  info_box_hei = 130
  settings_data = settings_data..'info_box_hei='..info_box_hei..'\n'
  write(settings_file, settings_data)
end

show_ch = show_menu:match'!Show FX chains|'
show_t = show_menu:match'!Show track templates|'
show_p = show_menu:match'!Show presets|'


old_show_menu = show_menu


get_cash()


only_get_all_files(res_path..[[\]]..'FXChains',0,'.RfxChain')
only_get_all_files(res_path..[[\]]..'TrackTemplates',1,'.RTrackTemplate')
only_get_all_files(res_path..[[\]]..'presets',2,'.ini')

get_all_files(t_all)


cash_tb_to_str()


t_sorted = {}
t_sorted_all = {}



for k, v in pairs(cash_tb) do

  local file_type
  if v[1]==1 or v[1]==0 then
    file_type = v[1]

  elseif type(v[1])=='table' then file_type = 2 -- !! we have only 3 types for this moment
  end
  if file_type == 2 then
    for i = 1, #v do
      t_sorted[#t_sorted+1] = v[i]
      t_sorted[#t_sorted].fullname = k
      t_sorted[#t_sorted].lbl = k:match[[.*\(.*)]]
      t_sorted[#t_sorted].lbl = k
    end
  elseif file_type == 0 or file_type == 1 then
    t_sorted[#t_sorted+1] = {m_type = file_type, fullname = k, name = k:match[[.*\(.*)]], fx_chain = v[2][2], lbl = k:match[[.*\(.*)]]}
  end
  
end


sort_on_values(t_sorted,'m_type','name','fullname')

t_sorted_all = new_tb(t_sorted)


show_ch = show_menu:match'!Show FX chains|'
show_t = show_menu:match'!Show track templates|'
show_p = show_menu:match'!Show presets|'


show()





update_tracks_tb()





--Button-----------------------------------------------------------------------------------
function pointIN(p_x, p_y,  x,y,w,h)
  return p_x > x and p_x < x + w and p_y > y and p_y < y + h
--  return p_x >= x and p_x <= x + w and p_y >= y and p_y <= y + h
end




function draw_btn(btn,i)
  local x,y,w,h  = table.unpack(btn.xywh)
  tb_y = y
  y = y + y_offs 
  if y<40 or y>gfx.h-info_box_hei-40 then return end
  local r_,g_,b_,a_  = table.unpack(btn.rgba)
  local fnt,fnt_sz = table.unpack(btn.fnt)--fnt,fnt_sz


  --Draw btn lbl(text)--
  
  local label = btn.lbl
  
  gfx.set(0.9, 0.87, 0.82, 1)--set label color
  gfx.setfont(1,fnt,fnt_sz);--set label fnt
--  local lbl_w, lbl_h = gfx.measurestr(label:sub(1,space))
  local lbl_w, lbl_h = gfx.measurestr(label)
  gfx.x = x+8
  gfx.y = y+(h-lbl_h)/2
--  gfx.drawstr(label:sub(1,space))
  gfx.drawstr(label)


  l_up = gfx.mouse_cap&1==0
  l_down = gfx.mouse_cap&1==1
  r_down = gfx.mouse_cap&2 == 0
--  r_up = gfx.mouse_cap&2 == 1
  right = gfx.mouse_cap&2 == 2
  
  what = pointIN(gfx.mouse_x,gfx.mouse_y, x,y,w,h)
  

  if l_up and pointIN(gfx.mouse_x,gfx.mouse_y, x,y,w,h) then
    action_name = btn.lbl
    action_name_full = btn.fullname
    
    if btn.m_type == 2 then
      fx_name = btn.fx_name
      fx_fn = btn.fx_fn
--      action_name_full = btn.fx_fn
    end
    
    a_=a_+ 1.7
    
  end

  --in elm L_down--
  if l_down and pointIN(mouse_ox,mouse_oy, x,y,w,h) then
    last_touched = action_name
    a_=a_+0.5
  end


  if l_down and not what and last_mouse_cap&1==1 and pointIN(mouse_ox,mouse_oy, x,y,w,h) and
  not pointIN(gfx.mouse_x, gfx.mouse_y,  0,gfx.h-info_box_hei-5,gfx.w,15) then -- this line is to avoid tooltip showing
    local x,y = r.GetMousePosition()
    r.TrackCtl_SetToolTip(last_touched, x+15, y+15, 1)
    if not drag_elem then drag_elem = true end
  end

  if l_up and last_mouse_cap&1==1 and pointIN(mouse_ox,mouse_oy, x,y,w,h) then r.TrackCtl_SetToolTip('', x+15, y+15, 0) end
  
  if l_up and not what and last_mouse_cap&1==1 and pointIN(mouse_ox,mouse_oy, x,y,w,h) then
    if drag_elem then drag_elem = false end
    
--    r.TrackCtl_SetToolTip('Added!', x+10, y+10, 0)

    local window, segment, details = r.BR_GetMouseCursorContext()
    if segment == 'empty' then
      if btn.m_type ~= 1 then
        local tracks = r.CountTracks()
        r.InsertTrackAtIndex(tracks,1)
        local new_tr = r.GetTrack(0, tracks)
        r.SetOnlyTrackSelected(new_tr)
        r.TrackList_AdjustWindows(0)
        r.UpdateArrange()

        
        if btn.m_type == 2 then
          local tr = r.GetSelectedTrack(0,0)
          if not tr then return end
        
          local tracks = r.CountSelectedTracks()
          for i = 0, tracks-1 do
            local tr = r.GetSelectedTrack(0,i)
            local fx = r.TrackFX_GetCount(tr)
            local chunk = GetTrackChunk(tr)
            add_tr_fx_chain(tr, chunk, btn.chain, 0)
            r.TrackFX_SetPreset(tr, fx, btn.lbl)
          end
        
        else
          str_scr = btn.fullname
          local tr = r.GetSelectedTrack(0,0)
          if not tr then return end
        
          if btn.m_type == 1 then
            local tr_num = r.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER')
            add_tr_template(tr_num, read_only(str_scr),1,1,1)

          elseif btn.m_type == 0 then
            local tracks = r.CountSelectedTracks()
            for i = 0, tracks-1 do
              local tr = r.GetSelectedTrack(0,i)
              local chunk = GetTrackChunk(tr)
              add_tr_fx_chain(tr, chunk, read_only(str_scr), 0)
            end
          end
        end
        
        
      else
        str_scr = btn.fullname
        local tracks = r.CountTracks()
        add_tr_template(tracks, read_only(str_scr),1,1,1)
        
      end
    elseif (window == 'arrange' or window == 'tcp' or window == 'mcp') then

      local tr = r.BR_TrackAtMouseCursor()
      if tr then
        sel_tb = {math.ceil((y-y_offs)/hei)}


        if btn.m_type == 2 then
        
          local fx = r.TrackFX_GetCount(tr)
          local chunk = GetTrackChunk(tr)
          add_tr_fx_chain(tr, chunk, btn.chain, 0)
          r.TrackFX_SetPreset(tr, fx, btn.lbl)
        
        else
          str_scr = btn.fullname
        
          if btn.m_type == 1 then
            local tr_num = r.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER')
            add_tr_template(tr_num, read_only(str_scr),1,1,1)
        
          elseif btn.m_type == 0 then
            local tracks = r.CountSelectedTracks()
            local chunk = GetTrackChunk(tr)
            add_tr_fx_chain(tr, chunk, read_only(str_scr), 0)
          end
        end
        
        
--[[
        last_sel_tb[cur_folder] = sel_tb[1]
        last_scroll_tb[cur_folder] = y_offs
        
  --      insert(t_recent[sel_tb[1]-1],3,mouse_tr)
        insert(t_recent[sel_tb[1]-1],5)
--]]
      end
    end
  end
  
  
  
  
  --in elm L_up(released and was previously pressed)--
  if l_up and last_mouse_cap&1==1 and pointIN(gfx.mouse_x,gfx.mouse_y, x,y,w,h) and pointIN(mouse_ox,mouse_oy, x,y,w,h) then 
    
    last_x_0 = last_x_0 or last_x
    last_y_0 = last_y_0 or last_y
    
    last_l_down = last_l_down or os.clock()    
    if os.clock() - last_l_down > 0 and os.clock() - last_l_down < 0.4 then -- Doubleclicked
      if last_x_0 ~= last_x or last_y_0 ~= last_y then return end

      last_l_down = nil
      last_x_0 = nil
      last_y_0 = nil

      if btn.m_type == 2 then
        local tr = r.GetSelectedTrack(0,0)
        if not tr then return end

        local tracks = r.CountSelectedTracks()
        for i = 0, tracks-1 do
          local tr = r.GetSelectedTrack(0,i)
          local fx = r.TrackFX_GetCount(tr)
          local chunk = GetTrackChunk(tr)
          add_tr_fx_chain(tr, chunk, btn.chain, 0)
          r.TrackFX_SetPreset(tr, fx, btn.lbl)
        end

      else
        str_scr = btn.fullname
        local tr = r.GetSelectedTrack(0,0)
        if not tr then return end

        if btn.m_type == 1 then
          local tr_num = r.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER')
          add_tr_template(tr_num, read_only(str_scr),1,1,1)

        elseif btn.m_type == 0 then
          local tracks = r.CountSelectedTracks()
          for i = 0, tracks-1 do
            local tr = r.GetSelectedTrack(0,i)
            local chunk = GetTrackChunk(tr)
            add_tr_fx_chain(tr, chunk, read_only(str_scr), 0)
          end
        end
      end
    end

    sel_tb = {math.ceil((y-y_offs)/hei)-1}
  end
  

  if right and last_mouse_cap&2==2 and mouse_ox and pointIN(gfx.mouse_x,gfx.mouse_y, x,y,w,h) then 

    nnn = gfx.showmenu(show_menu)
    if nnn >=1 and nnn <= 3 then
      old_show_menu = show_menu
      if nnn == 1 and (not show_ch or show_ch and (show_t or show_p)) then
        if show_menu:match'!Show FX chains|' then
          show_menu = show_menu:gsub('!Show FX chains|','Show FX chains|')
        else
          show_menu = show_menu:gsub('Show FX chains|','!Show FX chains|')
        end
        show_ch = not show_ch
      elseif nnn == 2 and (not show_t or show_t and (show_ch or show_p)) then
        if show_menu:match'!Show track templates|' then
          show_menu = show_menu:gsub('!Show track templates|','Show track templates|')
        else
          show_menu = show_menu:gsub('Show track templates|','!Show track templates|')
        end
        show_t = not show_t
      elseif nnn == 3 and (not show_p or show_p and (show_ch or show_t)) then
        if show_menu:match'!Show presets|' then
          show_menu = show_menu:gsub('!Show presets|','Show presets|')
        else
          show_menu = show_menu:gsub('Show presets|','!Show presets|')
        end
        show_p = not show_p
      elseif nnn == 5 then
        retval, new_name = r.GetUserInputs('New', 1, 'New name:', '')
        if retval == true then
          DRAW()
        end
      end
      
      
      
      settings_data = settings_data:gsub(old_show_menu,show_menu)
      write(settings_file,settings_data)      
      
--      y_max = 50
      y_offs = 0
      y_offs_min = -y_max
      y_offs_max = 0
      x_offs_max = 0
      y = 50

      t_sorted = new_tb(t_sorted_all)

      show()

--      DRAW()
      update_tracks_tb()

    end

  end
  
    
  if Elem_in_tb_kv(math.ceil((y-y_offs)/hei),sel_tb) then
  
    local r_,g_,b_,a_  = 0.43,0.4,0.4,0.8
    gfx.set(r_,g_,b_,a_)--set btn color
    gfx.rect(x,y,w,h,true)--body
    gfx.rect(x+1, y+1, w-2, h-2, false)--frame
    
  else

    gfx.set(r_,g_,b_,a_)--set btn color
    gfx.rect(x+1, y+1, w-2, h-2, false)--frame
  end
end




function draw_B(btn,i)
  local x,y,w,h  = table.unpack(btn.xywh)

  local r_,g_,b_,a_  = table.unpack(btn.rgba)
  local fnt,fnt_sz = table.unpack(btn.fnt)--fnt,fnt_sz
  
  local label = btn.lbl
  
  gfx.set(0.9, 0.87, 0.82, 1)--set label color
  gfx.setfont(1,fnt,fnt_sz);--set label fnt
  local lbl_w, lbl_h = gfx.measurestr(label)
  gfx.x = x+8
  gfx.y = y+(h-lbl_h)/2
  gfx.drawstr(label)

  l_down = gfx.mouse_cap&1==0
  l_up = gfx.mouse_cap&1==1
  r_down = gfx.mouse_cap&2 == 0
  

  if l_down and pointIN(gfx.mouse_x,gfx.mouse_y, x,y,w,h) then
    
    a_=a_+ 1.7
  end
  --in elm L_down--
  if l_up and pointIN(mouse_ox,mouse_oy, x,y,w,h) then a_=a_+0.5 end
  --in elm L_up(released and was previously pressed)--
  if l_down and last_mouse_cap&1==1 and pointIN(gfx.mouse_x,gfx.mouse_y, x,y,w,h) and pointIN(mouse_ox,mouse_oy, x,y,w,h) then 
    
  end
  
  
    
--  if Elem_in_tb_kv(math.ceil((y-y_offs)/hei),sel_tb) then
  
    local r_,g_,b_,a_  = 0.43,0.4,0.4,0.8
    gfx.set(r_,g_,b_,a_)--set btn color
    gfx.rect(x,y,w,h,true)--body
    gfx.rect(x+1, y+1, w-2, h-2, false)--frame
    
--  else
--[[
    gfx.set(r_,g_,b_,a_)--set btn color
    gfx.rect(x+1, y+1, w-2, h-2, false)--frame
--]]
--  end
end


-------------------------------------------------------------------------------------------


function draw_clr(btn)
  local x,y,w,h = table.unpack(btn.xywh)
  tb_y = y
  y = y + y_offs
--  if y < 40 then return end
--  if y<40 or y>gfx.h-150 then return end
  if y<40 or y>gfx.h-info_box_hei-40 then return end

--  local r_,g_,b_,a_ = table.unpack(btn.rgba)
  local rd,gr,bl = table.unpack(btn.rgba)
--  rd,gr,bl = r.ColorFromNative(btn.col)
--  rd,gr,bl = rd/256,gr/256,bl/256

--  gfx.set(rd,gr,bl,a_)--set btn color
  gfx.set(rd,gr,bl,0.8)--set btn color
  gfx.rect(x+5,y+4,w-6,h-4,0.8)--body
--  gfx.rect(x+1, y+1, w-2, h-2, 0)--frame
    
end


function draw_info(btn)
  local lbl = action_name:match'(.*)%.' or action_name
  if not action_name or action_name == '' then return end
  local x,y = table.unpack(btn.xywh)
  
  if y >gfx.h-40 then return end
  
--  local r_,g_,b_,a_ = table.unpack(btn.rgba)

  gfx.set(0.9, 0.87, 0.82, 1)--set label color
  local fnt,fnt_sz = btn.fnt[1], 20--fnt,fnt_sz
  gfx.setfont(1,fnt,fnt_sz);--set label fnt
--  local lbl_w, lbl_h = gfx.measurestr(phrase)
  gfx.x = x
  gfx.y = y

  gfx.drawstr(lbl)
end


function draw_FX(btn)


  local x,y,w,h = table.unpack(btn.xywh)

  local r_,g_,b_,a_ = table.unpack(btn.rgba)
  
  if y > gfx.h-35 then
    gfx.triangle(50,gfx.h-18,60,gfx.h-18,55,gfx.h-15)
  return end
  

  gfx.set(0.9, 0.87, 0.82, 1)--set label color
  local fnt,fnt_sz = table.unpack(btn.fnt)--fnt,fnt_sz
  gfx.setfont(1,fnt,fnt_sz);--set label fnt
  local lbl_w, lbl_h = gfx.measurestr(phrase)
  gfx.x = x
  gfx.y = y
--  gfx.y = y+30
--  gfx.drawstr(btn.num..'.  '..btn.lbl:sub(1,18))

  local font_sz = 15

  gfx.drawstr(btn.fx)
end


function draw_settings()
  
end

function DRAW()

  if show_main then
    
    DrawText(str_tb)
    DrawInfoFrame()
    for i,v in pairs(Button_TB) do draw_btn(v,i) end
    draw_info(Info_TB[1])
    for i,v in pairs(FX_TB) do draw_FX(v,i) end
    -- for i,v in pairs(B_TB) do draw_B(v,i) end
    for i,v in pairs(Color_TB) do draw_clr(v,i) end

  elseif show_settings then
    draw_settings()
  end
end
---------------------------------------
---------------------------------------

last_mouse_cap=0
mouse_dx, mouse_dy =0,0
y_offs = 0
y_offs_min = -y_max
y_offs_max = 0
x_offs_max = 0
phrase = ''


t_utf = {}

sn_arrow = false
function foo(x,y) return x-x%y end

---------------------------------------
function mainloop()

  if last_l_down and os.clock()-last_l_down >= 0.4 then
    last_l_down = nil
    
    last_x_0 = nil
    last_y_0 = nil
  end
    

  update_tracks_tb()
  local ch_count = r.GetProjectStateChangeCount()
  if not last_ch_count or last_ch_count ~= ch_count then
--    update_tracks_tb()
    y_offs_min = -y
  end
  last_ch_count = ch_count

  if gfx.mouse_cap&1==1 and last_mouse_cap&1==0 then 
    mouse_ox, mouse_oy = gfx.mouse_x, gfx.mouse_y 
  end
  Ctrl  = gfx.mouse_cap&4==4
  Shift = gfx.mouse_cap&8==8
---Scroll(vrt)---
--[[
    if not Shift and not Ctrl then M_Wheel = gfx.mouse_wheel;gfx.mouse_wheel = 0
      if M_Wheel>0 then y_offs = math.min(y_offs + hei , y_offs_max )
      elseif M_Wheel<0 and y_offs - y_offs_min > gfx.h then y_offs = math.max(y_offs - hei, y_offs_min) end
    end
--]]
    
    if not Shift and not Ctrl then
      M_Wheel = gfx.mouse_wheel;gfx.mouse_wheel = 0
      if not drag_elem then
        if M_Wheel>0 then y_offs = math.min(y_offs + foo(gfx.h-hei-info_box_hei,hei), y_offs_max )
        elseif M_Wheel<0 and y_offs - y_offs_min > gfx.h then y_offs = math.max(y_offs - foo(gfx.h-hei-info_box_hei,hei), y_offs_min) end
      elseif M_Wheel<0 then r.CSurf_OnArrow(1, 0) elseif M_Wheel>0 then r.CSurf_OnArrow(0, 0) end
    end
    
---Scroll(fast vrt)---
    if Shift and not Ctrl then
      M_Wheel = gfx.mouse_wheel;gfx.mouse_wheel = 0
      if not drag_elem then
        if M_Wheel>0 then y_offs = math.min(y_offs + 4*hei , y_offs_max )
        elseif M_Wheel<0 and y_offs - y_offs_min > gfx.h then y_offs = math.max(y_offs - 4*hei, y_offs_min) end
      elseif M_Wheel<0 then r.CSurf_OnScroll(50, 0) elseif M_Wheel>0 then r.CSurf_OnScroll(-50, 0) end
    end
  

    
  char = gfx.getchar()

  if gfx.mouse_cap&1==1 and last_mouse_cap&1==0 and pointIN(gfx.mouse_x, gfx.mouse_y,  0,gfx.h-info_box_hei-5,gfx.w,15) then stop_drag = false info_box_drag = true end

  if gfx.mouse_cap&1==1 and last_mouse_cap&1==1 then
    if not stop_drag and gfx.mouse_y > 40 and gfx.mouse_y < gfx.h-20 then
      info_box_hei = gfx.h-gfx.mouse_y
    end
  end


  if gfx.mouse_cap&1==0 and last_mouse_cap&1==1 then
    if info_box_drag then
      if not stop_drag then stop_drag = true end
      settings_data = settings_data:gsub('info_box_hei=.-\n','info_box_hei='..info_box_hei..'\n')
      write(settings_file, settings_data)

      info_box_drag = false
    end
  end
  
  
  if pointIN(gfx.mouse_x, gfx.mouse_y,  0,gfx.h-info_box_hei-5,gfx.w,15) then
    if not sn_arrow then gfx.setcursor(32645) sn_arrow = true end
  else
    if sn_arrow then gfx.setcursor(32512) sn_arrow = false end
  end

  mouse_down = gfx.mouse_cap&1 == 1 and mouse_last_cap&1 == 0
  mouse_last_cap = gfx.mouse_cap
  
  
  
  if char > 31 and char < 127 then
    table.insert(str_tb, c_pos+1, char); c_pos = c_pos+1; y_offs = 0
  end
  if char > 127 and char < 256 then
    if t_chars[char] then
      table.insert(str_tb, c_pos+1, t_chars[char])
    else
      table.insert(str_tb, c_pos+1, char)
    end
    c_pos = c_pos+1
    
    y_offs = 0
  end
  ---------------
  if char == 8 and c_pos > 0 then table.remove(str_tb, c_pos); c_pos = c_pos-1 y_offs = 0 end
  if char == 1818584692 then c_pos = minmax(c_pos-1, 0, #str_tb) end 
  if char == 1919379572 then c_pos = minmax(c_pos+1, 0, #str_tb) end
  
  if char == 6579564 then --del
    if #str_tb >= c_pos+1 then
      table.remove(str_tb, c_pos+1)
      y_offs = 0
    end
  end

  if char == 1752132965 then --home
    c_pos = 0
  end

  if char == 6647396 then --end
    c_pos = #str_tb
  end

  if char == 127 then -- ctrl + backspace
    str_tb = {}
    c_pos = 0
    y_offs = 0
  end
  

  if char == 9 then -- tab    
  end
  
  if char == 27 then -- esc
    return
  end
  
  
  if char == 26161 then -- F1

  end
  
  
  phrase = get_phrase(str_tb)
  words_l = words_tb_l(phrase)
  
------
  DRAW()


  last_mouse_cap = gfx.mouse_cap
  last_x,last_y = gfx.mouse_x,gfx.mouse_y  
  
  
  if char~=-1 then r.defer(mainloop) end --defer
  gfx.update();
end
---------------------------------------
-------------
mainloop()


r.atexit(function()
  saveWindowState()
end)


