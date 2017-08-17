-- @description Adjust metronome volume
-- @version 0.5
-- @author me2beats
-- @changelog
--  + init

local r = reaper

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
    if not w then return end
  end

  r.SetExtState(EXT_SECTION, EXT_WINDOW_STATE,
    string.format("%d %d %d %d %d", w, h, dockState, xpos, ypos), 1)
end


--------------------------------------------------------------------------------
---   Simple Element Class   ---------------------------------------------------
--------------------------------------------------------------------------------
local Element = {}
function Element:new(x,y,w,h, r,g,b,a, lbl,fnt,fnt_sz, norm_val,display_val)
    local elm = {}
    elm.def_xywh = {x,y,w,h,fnt_sz} -- its default coord,used for Zoom etc
    elm.x, elm.y, elm.w, elm.h = x, y, w, h
    elm.r, elm.g, elm.b, elm.a = r, g, b, a
    elm.lbl, elm.fnt, elm.fnt_sz  = lbl, fnt, fnt_sz
    elm.norm_val = norm_val
    elm.display_val = display_val
    ------
    setmetatable(elm, self)
    self.__index = self 
    return elm
end
--------------------------------------------------------------
--- Function for Child Classes(args = Child,Parent Class) ----
--------------------------------------------------------------
function extended(Child, Parent)
  setmetatable(Child,{__index = Parent}) 
end
--------------------------------------------------------------
---   Element Class Methods(Main Methods)   ------------------
--------------------------------------------------------------
function Element:update_xywh()
  if not Z_w or not Z_h then return end -- return if zoom not defined
  if Z_w>0.5 and Z_w<3 then  
   self.x, self.w = math.ceil(self.def_xywh[1]* Z_w) , math.ceil(self.def_xywh[3]* Z_w) --upd x,w
  end
  if Z_h>0.5 and Z_h<3 then
   self.y, self.h = math.ceil(self.def_xywh[2]* Z_h) , math.ceil(self.def_xywh[4]* Z_h) --upd y,h
  end
  if Z_w>0.5 or Z_h>0.5  then --fix it!--
     self.fnt_sz = math.max(9,self.def_xywh[5]* (Z_w+Z_h)/2)
     self.fnt_sz = math.min(22,self.fnt_sz)
  end       
end
--------
function Element:pointIN(p_x, p_y)
  return p_x >= self.x and p_x <= self.x + self.w and p_y >= self.y and p_y <= self.y + self.h
end
--------
function Element:mouseIN()
  return gfx.mouse_cap&1==0 and self:pointIN(gfx.mouse_x,gfx.mouse_y)
end
--------
function Element:mouseDown()
  return gfx.mouse_cap&1==1 and self:pointIN(mouse_ox,mouse_oy)
end
--------
function Element:mouseClick()
  return gfx.mouse_cap&1==0 and last_mouse_cap&1==1 and
  self:pointIN(gfx.mouse_x,gfx.mouse_y) and self:pointIN(mouse_ox,mouse_oy)         
end
--------
function Element:draw_frame()
  local x,y,w,h  = self.x,self.y,self.w,self.h
  gfx.rect(x, y, w, h, 0)--frame1
  gfx.roundrect(x, y, w-1, h-1, 3, true)--frame2         
end
--------------------------------------------------------------------------------
---   Create Element Child Classes(Button,Slider,Knob)   -----------------------
--------------------------------------------------------------------------------
local Button ={}; local Knob ={}; local Slider ={}; 
  extended(Button, Element)
  extended(Knob,   Element)
  extended(Slider, Element)
---Create Slider Child Classes(V_Slider,H_Slider)----
local H_Slider ={}; local V_Slider ={};
  extended(H_Slider, Slider)
  extended(V_Slider, Slider)
----------------------------------------------------------
---------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
---   Knob Class Methods   -----------------------------------------------------   
--------------------------------------------------------------------------------
function Knob:update_xywh() --redefine method for Knob
    if not Z_w or not Z_h then return end -- return if zoom not defined
    local w_h = math.ceil( math.min(self.def_xywh[3]*Z_w, self.def_xywh[4]*Z_h) )
    if Z_w>0.5 and Z_w<3 then self.x = math.ceil(self.def_xywh[1]* Z_w) end
    if Z_h>0.5 and Z_h<3 then self.y = math.ceil(self.def_xywh[2]* Z_h) end
    if Z_w>0.5 and Z_h>0.5 and (Z_w<3 or Z_h<3) then self.w, self.h = w_h, w_h end
    if Z_w>0.5 or Z_h>0.5 then --fix it!--
      self.fnt_sz = math.max(7, self.def_xywh[5]* (Z_w+Z_h)/2)--fix it!
      self.fnt_sz = math.min(20,self.fnt_sz) 
    end 
end
--------
function Knob:set_norm_val()
    local x,y,w,h  = self.x,self.y,self.w,self.h
    local VAL,K = 0,5 -- temp value; coefficient(when Ctrl pressed)

    if not Ctrl then VAL = self.norm_val + ((last_y-gfx.mouse_y)/(h*K))
       else VAL = (h-(gfx.mouse_y-y))/h end
       
    if VAL<0 then VAL=0 elseif VAL>1 then VAL=1 end
    self.norm_val=VAL
    
    r.PreventUIRefresh(1)
    
    for i = 1, 285 do
      r.Main_OnCommand(r.NamedCommandLookup('_S&M_METRO_VOL_DOWN'),0) -- lalala
    end
    
    for i = 1, 100+VAL*170 do
      r.Main_OnCommand(r.NamedCommandLookup('_S&M_METRO_VOL_UP'),0) -- lalala
    end
    
    r.PreventUIRefresh(-1)
    
    
end
--------
function Knob:draw_body()
    local x,y,w,h  = self.x,self.y,self.w,self.h
    local k_x, k_y, r = x+w/2, y+h/2, (w+h)/4
    local pi=math.pi
    local offs = pi+pi/4
    local val = 1.5*pi * self.norm_val
    local ang1, ang2 = offs-0.01, offs + val
    gfx.circle(k_x,k_y,r-1, false) --external
       for i=1,10 do
        gfx.arc(k_x, k_y, r-2,  ang1, ang2, true)
        r=r-1; --gfx.a=gfx.a+0.005 --variant
       end
    gfx.circle(k_x, k_y, r-1, true)--internal
end
--------
function Knob:draw_lbl()
    local x,y,w,h  = self.x,self.y,self.w,self.h
    local lbl_w, lbl_h = gfx.measurestr(self.lbl)
    gfx.x = x+(w-lbl_w)/2; gfx.y = (y+h/2)/2 -lbl_h
    gfx.drawstr(self.lbl)--draw knob label
end
--------
function Knob:draw_val()
    local x,y,w,h  = self.x,self.y,self.w,self.h
    
--    local val = string.format("%.1f", 29*self.norm_val^0.4-17)
--    local val = 12
--    local val_w, val_h = gfx.measurestr(val)
--    gfx.x = x+(w-val_w)/2; gfx.y = (y+h/2)-val_h-3
--    gfx.x = x+(w-val_w)/2; gfx.y = (y+h/2)-val_h-3
--    gfx.drawstr('0')--draw knob Value
end

-------------------
function Knob:draw()
    self:update_xywh()--Update xywh(if wind changed)
    local x,y,w,h  = self.x,self.y,self.w,self.h
    local r,g,b,a  = self.r,self.g,self.b,self.a
    local fnt,fnt_sz = self.fnt, self.fnt_sz
    ---Get L_mouse state--
          --in element--
          if self:mouseIN() then a=a+0.1 end
          --in elm L_down--
          if self:mouseDown() then a=a+0.2 
             self:set_norm_val()
          end
          --in elm L_up(released and was previously pressed)--
          --if self:mouseClick() then --[[self.onClick()]] end
    --Draw (body,frame)--
    gfx.set(r,g,b,a)--set color
    self:draw_body()--body
    --self:draw_frame()--frame
    ------------------------
    --Draw label,value--
    gfx.set(0.7, 1, 0, 1)--set labels color
    gfx.setfont(1, fnt, fnt_sz);--set labels fnt
    --self:draw_lbl()
    self:draw_val()
end


----------------------------------------------------------------------------------------------------
---   START   --------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
---   Objects(for Example Only)   ------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
local knb1 = Knob:new(10,10,80,80,   0.3,0.7,0.3,0.4, "K1","Arial",22, 0.5 )
local Knob_TB = {knb1}
----------------------------------------------------------------------------------------------------
---   Main DRAW function   -------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
function DRAW()
    for key,knb  in pairs(Knob_TB)   do knb:draw()  end 
end

--------------------------------------------------------------------------------
--   INIT   --------------------------------------------------------------------
--------------------------------------------------------------------------------
function Init()
    --Some gfx Wnd Default Values--------------
    local R,G,B = 20,20,20        --0..255 form
    Wnd_bgd = R + G*256 + B*65536 --red+green*256+blue*65536  
    Wnd_Title,Wnd_W,Wnd_H,Wnd_Dock,Wnd_X,Wnd_Y = "Metronome primary beat volume", 100,100, 0,100,320
    --Init window------------------------------
    gfx.clear = Wnd_bgd
    
    EXT_SECTION = 'me2beats_metronome'
    EXT_WINDOW_STATE = 'window_state'
    EXT_LAST_DOCK = 'last_dock'
    
    local w_, h_, dockState, x_, y_ = previousWindowState()
    
    if w_ then
         gfx.init("Metronome primary beat volume", w_ ,h_, dockState, x_, y_)
    else gfx.init( Wnd_Title, Wnd_W,Wnd_H, Wnd_Dock, Wnd_X,Wnd_Y ) end
    
    
    
    --Mouse--------------
    last_mouse_cap = 0
    last_x, last_y = 0, 0
end
----------------------------------------
--   Mainloop   ------------------------
----------------------------------------
function mainloop()
    Z_w,Z_h = gfx.w/Wnd_W, gfx.h/Wnd_H
    if gfx.mouse_cap&1==1 and last_mouse_cap&1==0 then 
       mouse_ox, mouse_oy = gfx.mouse_x, gfx.mouse_y 
    end
    Ctrl  = gfx.mouse_cap&4==4
    Shift = gfx.mouse_cap&8==8
    -----------------------
    --DRAW,MAIN functions--
      DRAW()--Main() 
    -----------------------
    -----------------------
    last_mouse_cap = gfx.mouse_cap
    last_x, last_y = gfx.mouse_x, gfx.mouse_y
    char = gfx.getchar() 
    if char~=-1 then reaper.defer(mainloop) end --defer
    -----------  
    gfx.update()
    -----------
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------
Init()
mainloop()

r.atexit(function()
  saveWindowState()
end)
