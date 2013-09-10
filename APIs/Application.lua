--[[

  API Name: Application
  Author:   BigTwisty
  Project:  TLogic
  
  Notes:
  
    Provides an interface for a running application.
    
--]]

local function setChanged(class, item, value)
  if type(class.onChange) == "function" then
    class.onChange(item, value)
  end
end

local function AppSettings(appType, title)
  local _self = Class.new()
  local _title = title or "Application"
  local _type = "standard"
  local function _setChanged(interface, value)
    if type(_self.onChange) == "function" then
      _self.onChange(interface, value)
    end
  end
  _self._newProperty = { "name",
                         type = "string"
                         get = function(return _name) end,
                         set = function(v)
                           _name = v
                           setChanged(_self, "name", v)
                         end }
  _self._newProperty = { "type",
                         get = function(return _type) end }
  return _self
end

local function start(r, path, ...)
  if not fs.exists(path) then return false, "File not found" end
  r.co = coroutine.create( function(...) shell.run(filepath, ...) end )
  r.path = path
  return coroutine.resume(...)
end
 
function update(r, ...)
  if coroutine.status(r.co) == "dead"
  v = { coroutine.resume(...) }
  result = table.remove(v, 1)
  if result == false then
    r.running = false
  end
end
  
function new(appType)
  tr.validate("appType", "string", appType, 2)
  local function _update(item, value)
    if item == "title" then
      -- add code to update title
    end
  end
  
  local _self = Class.new()
  local _routine = { }
  _routine._newMethod   { "onChange", _update }
  _self._newProperty =  { "status",
                          get = function()
                            return _routine ~= nil and coroutine.status(_routine) or "not started"
                          end }
  _self._
  
  return _self
end