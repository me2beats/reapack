-- @description Save project grid
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

local _, division, swingmode, swingamt = r.GetSetProjectGrid(0, 0)

local ext_sec, ext_key = 'me2beats_save-restore', 'grid'
r.SetExtState(ext_sec, ext_key, division..','..swingmode..','..swingamt, 0)

