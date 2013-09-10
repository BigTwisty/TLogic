-- link = "https://www.dropbox.com/s/f4kxl20t60bun62/Validation.lua"

os.loadAPI("TLogic/sys")
os.loadAPI("TLogic/Validation")


local mon 
if peripheral.getType("top")=="monitor" then
  mon = peripheral.wrap("top")
  mon.setTextScale(0.5)
else

local test = Validation.new( "output.txt", mon )

local subnote = "=> "

print("start test")
test.note("assert")
test.try( " 1.0", { sys.assert, true, "test" }, { true, true } )
test.try( " 1.1", { sys.assert, false, "test", 1 }, { false, "test" }, "pcall: " )
test.try( " 1.2", { sys.assert, false, "test", 2 }, { false, "test" } )
test.try( " 1.3", { sys.assert, false, "test", 0 }, { false, "test" }, "" )
test.try( " 1.4", { sys.assert, nil, "test" }, { false, "test" } )
test.try( " 1.5", { sys.assert, 33, "test" }, { true, 33 } )

test.note("validate")
test.try( " 2.0", { sys.validate, "name", "string", "asdf" }, { true, true } )
test.try( " 2.1", { sys.validate, "name", "string", 33 }, { false, "(name) string expected, got number" } )
test.try( " 2.2", { sys.validate, "nmb", "number", 22 }, { true, true } )
test.try( " 2.3", { sys.validate, "nmb", "number", {22} }, { false, "(nmb) number expected, got table" } )
test.try( " 2.4", { sys.validate, "any", "!nil", 33 }, { true, true } )
test.try( " 2.5", { sys.validate, "any", "!nil" }, { false, "(any) not nil expected, got nil" } )

test.note("loadAPI")

function createAPI(name, bad)
  h = assert(fs.open("TLogic/"..name, "w"), "Could not create API: "..name)
  if not bad then
    h.write("function test(x) return x end")
  else
    h.write("asdf asdf")
  end
  h.close()
end

function createBadAPI(name)
  h = assert(fs.open("TLogic/"..name
function deleteAPI(name)
  fs.delete("TLogic/"..name)
end

test.try( " 3.0", { sys.loadAPI, "testNone" }, { false, "Could not find testNone" }, "" )
if test.try( " 3.1", { createAPI, "testBad", true } ) then
  test.try ( " 3.2", { sys.loadAPI, "testBad" }, { false, "Could not load testBad" }, "" )
end

if test.try( " 3.3", {createAPI, "test" } ) and test.try( " 3.1", { createAPI, "test2" } ) then
  test.try( " 3.4", { sys.loadAPI, "testNil" }, { false
  test.try( " 3.5", { test.test, 3 }, { true, 3 } )
  test.try( " 3.6", { test2.test, 6 }, { true, 6 } )
  test.try( " 3.7", { sys.loadAPI, "test", "test2" } )
  test.try( " 3.8", { sys.loadAPI, "test", "test2", "testBad" }, { false, "Could not load testBad" }, "" )
end

test.note( test.final() )
print( test.final() )