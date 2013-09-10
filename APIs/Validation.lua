-- working link: os.loadAPI("btValidation")--<link>https://www.dropbox.com/s/ib5hiijsq6l1xeb/btValidation.lua</link>
-- appName = "btValidation"
-- appVersion = "1.0a"

local apiName = "Validation"

-- Provides a list of error throwbacks to ignore.
-- Validation does not ignore ALL throwbacks to  provide 
-- information on unintended errors occurring inside the tested code.
local throwbacks = { basic="pcall: " }
do
  local h = fs.open("TLogic/APIs/"..apiName, "r")
  if h == nil then error("Validation API not installed in /TLogic/APIs/", 2) end
  local index = 1
  local s = h.readLine()
  while s do
    index = index + 1
    if s:find("-- read line") then
      throwbacks.read = apiName..":"..tostring( index )..": "
    elseif s:find("-- write line") then
      throwbacks.write = apiName..":"..tostring( index )..": "
    elseif s:find("-- pcall line") then
      throwbacks.pcall = apiName..":"..tostring( index )..": "
    end
    s = h.readLine()
  end
  h.close()
end

function throwbacks(apiName)
  return throwbacks.pcall, throwbacks.read, throwbacks.write
end

local function append( filename, ... )
  args = {...}
  line = ""
  for _, arg in ipairs( args ) do
    line = line..tostring( arg )
  end
  h = fs.open( filename, "a" )
  h.writeLine( line )
  h.close()
  return line
end

local function _write(tbl, key, value)
  -- write line
  tbl[key] = value
end

local function _read(tbl, key)
  -- read line
  return tbl[key]
end

function new( filename, terminal )
  local h = fs.open( filename, "w" )
  local _terminal = terminal or term.native
  if terminal then
    terminal.clear()
    do
      local x,y = terminal.getSize()
      terminal.setCursorPos(1, y)
    end
  end
  if (h == nil) then error( "Invalid output file name", 2 ) end
  h.close()
  local _filename = filename
  local self
  self = {
    testCount = 0,
    failCount = 0,
    try = function( tag, testCall, expected, callback)
      expected = expected or { true }
      if type(tag)     ~="string" then error( "(tag) string expected, got "..type( tag ), 2 ) end
      if type(testCall)~="table"  then error( "(testCall) table expected, got "..type( testCall ), 2 ) end
      if type(expected)~="table"  then error( "(expected) table expected, got "..type( expected ), 2 ) end
      
      -- pcall line
      result = { pcall( unpack( testCall ) ) }
      pass = true
      if result[1] == false then
        if callback == nil then
          for _,v in pairs(throwbacks) do
            result[2] = result[2]:gsub(v,"")
          end
        else
          result[2] = result[2]:gsub(callback,"")
        end
      end
      for i = 1, math.max( #result, #expected ) do
        if result[i] ~= expected[i] then pass = false end
      end
      local line
      if pass then line = tag..": PASS"
      else
        line = tag..": FAIL"
        for i = 1, math.max( #result, #expected ) do
          line = string.format("%s\n-- arg %i: exp(%s) got(%s)",
                               line, i, tostring( expected[i]), tostring(result[i] ) )
        end
      end
      append( _filename, line )
      self.testCount = self.testCount + 1
      if not pass then
        self.failCount = self.failCount + 1
        if terminal then
          term.redirect(terminal)
          print( line )
          term.restore()
        end
      end
      return pass
    end,
    tryWrite = function( tag, tbl, key, value, expected, callback )
      return self.try( tag, { _write, tbl, key, value }, expected, callback )
    end,
    tryRead = function( tag, tbl, key, expected, callback )
      return self.try( tag, { _read, tbl, key }, expected, callback )
    end,
    note = function(text, header)
      append(_filename, header or "-------------- ", text)
    end,
    final = function()
      return string.format( "Finished %i tests with %i failures.", self.testCount, self.failCount )
    end
  }
  return self
end