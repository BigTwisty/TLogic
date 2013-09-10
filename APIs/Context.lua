--[[

  API Name: Context
  Author:   BigTwisty
  
  Notes:
  
    Provides a screen buffer for localization of applications, forms and controls
    
    Compatible with term.redirect()

]]

if not sys then if not os.loadAPI("TLogic/APIs/sys") then error("Could not load primary API (sys)", 0) end end
sys.loadAPI("Class")

local base

local function colorInt(color)
  if type(color)~="number" then return nil end
  c = math.log(color)/math.log(2)
  if math.floor(c) ~= c then return nil end
  return c
end

function getHex(color)
  v = colorInt(color)
  sys.assert(v ~= nil, "btBuffer Internal Error: getHex(color) invalid color", 2)
  return string.format("%X", v)
end

local function getColor(hex)
  return math.pow(2,tonumber(hex,16))
end

local function strReplace(text, rpl, index)
  if index > #text then return text end
  if index + #rpl < 2 then return text end
  if index < 1 then
    rpl = rpl:sub(0 - index + 2)
    index = 1
  end
  local str = text:sub(1, index - 1)..rpl
  endLen = #text - #str
  if endLen >= 1 then
    str = str..text:sub(0 - endLen)
  end
  return str:sub(1, #text)
end

local function newline(b)
  return { text = string.rep(" ", b.width),
           bg = string.rep(getHex(b.bg), b.width),
           fg = string.rep(getHex(b.fg), b.width) }
end

local function renderActive(b)
  b.setChanged()
  if b.isActive then
    base.render(b, b.tx, b.ty, b.terminal)
  end
end

base = {

  activate = function(b, x, y, terminal)
    b.terminal = terminal or term.native
    b.isActive = true
    b.tx, b.ty = x, y
    renderActive(b)
  end,

  deactivate = function(b)
    b.isActive = false
  end,
  
  getSize = function(b) return b.width, b.height end,
  
  getCusorPos = function(b) return b.x, b.y end,

  setCursorPos = function(b, x, y)
    b.x = math.max(math.min(x or b.x, b.width), 1)
    b.y = math.max(math.min(y or b.y, b.height), 1)
    if b.isActive then
      b.terminal.setCursorPos(b.x + b.tx - 1, b.y + b.ty - 1)
    end
    b.setChanged()
  end,
  
  getCursorPos = function(b)
    return b.x, b.y
  end,
  
  translatePos = function(b, x, y)
    if b.terminal == nil then return x, y end
    if b.terminal.translatePos == nil then return x, y end
    return b.terminal.translatePos(x, y)
  end
  
  setCursorBlink = function(b, value)
    value = value or b.cursorBlink or false
    b.cursorBlink = value
    if b.isActive then
      b.terminal.setCursorBlink(value)
      base.setCursorPos(b)
    end
  end,
  
  resize = function (b, width, height)
    if b.width ~= width or b.height ~= height then
      b.width = width
      b.height = height
      base.clear(b)
    end
  end,
  
  clear = function(b)
    b.lines = { }
    dbPrint("---- Clear ----  bg:", b.bg," fg:",b.fg)
    for y=1,b.height do
      b.lines[y] = newline(b)
      dbPrint("Line ",y," text: \"",b.lines[y].text,"\"  bg: \"",b.lines[y].bg,"\"  fg: \"",b.lines[y].fg)
    end
    renderActive(b)
  end,
  
  clearLine = function(b)
    if b.y > 0 and b.y <= b.height then
      b.lines[b.y] = newline(b)
    end
    renderActive(b)
  end,
  
  write = function(b, text)
    if b.x > b.width or 
       b.y > b.height or 
       b.y < 1 or
       b.x + #text < 2 then 
      return
    end
    
    if b.x < 1 then
      text = text:sub(1 - #text - b.x)
      b.x = 1
    end
    
    b.lines[b.y].text = strReplace(b.lines[b.y].text, text, b.x)
    b.lines[b.y].fg = strReplace(b.lines[b.y].fg, string.rep(getHex(b.fg), b.width), b.x)
    b.lines[b.y].bg = strReplace(b.lines[b.y].bg, string.rep(getHex(b.bg), b.width), b.x)
    b.x = b.x + #text
    renderActive(b)
  end,
  
  scroll = function(b, n)
    table.remove(b.text, 1)
    table.remove(b.fg, 1)
    table.remove(b.bg, 1)
    table.insert(b.text, string.rep(" ", b.width))
    table.insert(b.fg, string.rep(getHex(b.textColor), b.width))
    table.insert(b.bg, string.rep(getHex(b.backgroundColor), b.width))
    renderActive(b)
  end,
  
  isColor = function(b) return b.isColor end,
  
  isColour = function(b) return b.isColor end,
  
  getTextColor = function(b) return b.textColor end,
  
  getBackgroundColor = function(b) return b.backgroundColor end,
  
  setTextColor = function(b, v)
    sys.assert(colorInt(v) ~= nil, "Invalid color", 3)
    b.fg = v
  end,
  
  setTextColour = function(b, v)
    sys.assert(colorInt(v) ~= nil, "Invalid color", 3)
    b.fg = v
  end,
  
  setBackgroundColor = function(b, v)
    sys.assert(colorInt(v) ~= nil, "Invalid color", 3)
    b.bg = v
  end,
  
  setBackgroundColour = function(b, v)
    sys.assert(colorInt(v) ~= nil, "Invalid color", 3)
    b.bg = v
  end,
  
  render = function(b, destX, destY, terminal)
    terminal = terminal or term.native
    destX, destY = destX or 1, destY or 1
    destW, destH = terminal.getSize()
    oldX, oldY = terminal.getCursorPos()
    for y=1,b.height do
      dy = destY + y - 1
      if dy > 0 and dy <= destH then
        terminal.setCursorPos(destX, dy)
        text = b.lines[y].text
        fg = b.lines[y].fg
        bg = b.lines[y].bg
        
        while #text > 0 do
          len = #text
          if b.isColor and (terminal or term).isColor() then
            fgc = fg:sub(1,1)
            bgc = bg:sub(1,1)
            _,fgLen = fg:find(fgc.."+")
            _,bgLen = bg:find(bgc.."+")
            len = math.min(fgLen, bgLen)
            dbPrint("fgc:",fgc," bgc:",bgc," len:",len)
            terminal.setTextColor(getColor(fgc))
            terminal.setBackgroundColor(getColor(bgc))
          end
          terminal.write(text:sub(1, len))
          text = text:sub(len + 1)
          fg = fg:sub(len + 1)
          bg = bg:sub(len + 1)
        end
      end
    end
    terminal.setCursorPos(oldX, oldY)
  end
}

local nextId = 0
local function newId()
  nextId = nextId + 1
  return nextId
end

function new(width, height, textColor, backgroundColor, isColor)
  textColor = textColor or colors.white
  backgroundColor = backgroundColor or colors.black
  sys.validate("number", width, height)
  sys.assert(width >= 1, "Expected width > 0")
  sys.assert(height >= 1, "Expected height > 0")
  sys.assert(colorInt(textColor) ~= nil and colorInt(backgroundColor) ~= nil, "Invalid color")
  local _self = Class.new()
  local _buffer = {
    x = 1,
    y = 1,
    isColor = isColor or true,
    width = width,
    height = height,
    fg = textColor,
    bg = backgroundColor,
    setChanged = function()
      if type(_self.onChange) == "function" then
      _self.onChange(_self)
    end
  end
  }
  for k,v in pairs(base) do
    if type(v) == "function" then
      _self._newMethod = { k, v, ref = _buffer }
    end
  end
  _self._newProperty = { "active", get = function() return _buffer.isActive end }
  _self._lock()
  _self.clear()
  return _self
end