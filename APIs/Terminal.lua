--[[

  API Name: Terminal
  Author:   BigTwisty
  
  Notes:
    
    This provides an interface to a specific terminal.  This can
    be either the main computer screen, or any attached monitor.
    It supports one main context and multiple overlays.
    
    Main context:
    
      Typically an application.
      
    Overlays:
    
      Can be Menus or Forms.
      
    Required APIs:
    
      - sys
      - Class
      - Context
      
--]]

if not sys then os.loadAPI("TLogic/sys") end
if not sys then error("Cannot load base API (sys)", 0)

sys.loadAPI("Class", "Context")

function new(context, isMain)
  local _self
  
  
  sys.validate( "context", "table", context, 2 )
  sys.assert(  type(context) == "table" and
              type(context.write) == "function",
              "Terminal.new(context, [isMain]) Invalid context", 2 )
  
  local _mainContext
  do
    local width, height = context.getSize()
    if isMain then
      height = height - 1
    end
    _mainContext = Context.new(width, height)
  end
  
  local _overlays = { }
  