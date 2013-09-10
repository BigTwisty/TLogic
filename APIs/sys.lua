--[[

  API Name:   sys
  Author:     BigTwisty
  
  Notes:
   
    Provides commonly used functions used across TLogic source code
    Name shortened to sys as these functions will be used often

--]]

-- Provides error(msg, throwback) functionality to lua assert command
function assert(value, message, throwback)
  throwback = throwback == 0 and 0 or throwback and (throwback + 1) or 2
  if not value then
    error(message, throwback)
  end
  return value
end

-- Validates a value against a given datatype
-- Multiple datatypes separated by pipe "|" supported '
-- Not nil supported via "!nil" datatype
function validate( name, datatype, value, throwback )
  throwback = throwback == 0 and 0 or throwback and (throwback + 1) or 2
  local pass = false
  local expected = nil
  if datatype == "!nil" then
    expected = "not nil"
    pass = value ~= nil
  else
    for subtype in datatype:gmatch("[^|]+") do
      expected = expected and ( expected.." or "..datatype ) or datatype
      if type( value ) == datatype then 
        pass = true
      end
    end
  end
  return assert( pass, "("..name..") "..expected.." expected, got "..type(value), throwback )
end

-- Provides feedback while loading an API
function loadAPI(...)
  for _,api in ipairs( {...} )
    if _G[api] ~= "table" then 
      assert(fs.exists("TLogic/APIs"..api), "Could not find "..api", 0)
      assert(os.loadAPI("TLogic/APIs"..api), "Could not load "..api", 0)
    end
  end
end