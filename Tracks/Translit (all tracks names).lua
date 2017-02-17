local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local tracks = r.CountTracks()

if tracks == 0 then bla() return end

local v = {}

v['А']='A'
v['Б']='B'
v['В']='V'
v['Г']='G'
v['Д']='D'
v['Е']='E'
v['Ё']='Yo'
v['Ж']='Zh'
v['З']='Z'
v['И']='I'
v['Й']='J'
v['К']='K'
v['Л']='L'
v['М']='M'
v['Н']='N'
v['О']='O'
v['П']='P'
v['Р']='R'
v['С']='S'
v['Т']='T'
v['У']='U'
v['Ф']='F'
v['Х']='H'
v['Ц']='Ts'
v['Ч']='Ch'
v['Ш']='Sh'
v['Щ']='Sch'
v['Ы']='Y'
v['Ь']="'"
v['Э']='E'
v['Ю']='Ju'
v['Я']='Ja'
v['а']='a'
v['б']='b'
v['в']='v'
v['г']='g'
v['д']='d'
v['е']='e'
v['ё']='yo'
v['ж']='zh'
v['з']='z'
v['и']='i'
v['й']='j'
v['к']='k'
v['л']='l'
v['м']='m'
v['н']='n'
v['о']='o'
v['п']='p'
v['р']='r'
v['с']='s'
v['т']='t'
v['у']='u'
v['ф']='f'
v['х']='h'
v['ц']='ts'
v['ч']='ch'
v['ш']='sh'
v['щ']='sch'
v['ы']='y'
v['ь']="'"
v['э']='e'
v['ю']='ju'

r.Undo_BeginBlock()

for i = 0, tracks-1 do

  local track = r.GetTrack(0,i)
  _, tr_name = r.GetSetMediaTrackInfo_String(track, 'P_NAME', '', 0)

  for key,val in pairs(v) do
    tr_name = tr_name:gsub(key,val)
  end

  r.GetSetMediaTrackInfo_String(track, 'P_NAME', tr_name, 1)

end

r.Undo_EndBlock('Translit (all tracks names)', -1)
