local link = "https://www.dropbox.com/s/4z3o5g1efxd7p2u/testClass.lua"
local appName = "testClass"
local appVersion = "1.0"

os.loadAPI("TLogic/APIs/sys")

os.loadAPI("TLogic/APIs/Validation")

local mon = peripheral.wrap("top")
mon.setTextScale(0.5)

local test = btValidation.newTest( "output.txt", mon )

local subnote = "=> "

print("start test")
test.note("assert")
test.try( " 1.0", { btClass.assert, true, "test" }, { true, true } )
test.try( " 1.1", { btClass.assert, false, "test", 1 }, { false, "test" }, "pcall: " )
test.try( " 1.2", { btClass.assert, false, "test", 2 }, { false, "test" } )
test.try( " 1.3", { btClass.assert, false, "test", 0 }, { false, "test" }, "" )
test.try( " 1.4", { btClass.assert, nil, "test" }, { false, "test" } )
test.try( " 1.5", { btClass.assert, 33, "test" }, { true, 33 } )

test.note("validate")
test.try( " 2.0", { btClass.validate, "name", "string", "asdf" }, { true, true } )
test.try( " 2.1", { btClass.validate, "name", "string", 33 }, { false, "(name) string expected, got number" } )
test.try( " 2.2", { btClass.validate, "nmb", "number", 22 }, { true, true } )
test.try( " 2.3", { btClass.validate, "nmb", "number", {22} }, { false, "(nmb) number expected, got table" } )
test.try( " 2.4", { btClass.validate, "any", "!nil", 33 }, { true, true } )
test.try( " 2.5", { btClass.validate, "any", "!nil" }, { false, "(any) not nil expected, got nil" } )

test.note("class")
class = btClass.new()

test.note("class metamethods")
test.tryWrite( " 3.0", class, "_newMetamethod", 2, { false, "(metamethod) table expected, got number" } )
test.tryWrite( " 3.1", class, "_newMetamethod", { 33 }, { false, "(name) string expected, got number" } )
test.tryWrite( " 3.2", class, "_newMetamethod", { "__unsupported" }, { false, "Metamethod not supported: __unsupported" } )
test.tryWrite( " 3.3", class, "_newMetamethod", { "__tostring", "asdf" }, { false, "(function) function expected, got string" } )
test.tryWrite( " 3.4", class, "_newMetamethod", { "__tostring", function() return "asdf" end } )
test.try( " 3.5", { tostring, class }, { true, "asdf" } )

test.note("class members")
test.tryWrite( " 4.0", class, "_newMember", 1, { false, "(member) table expected, got number" } )
test.tryWrite( " 4.1", class, "_newMember", {  }, { false, "(member name) string expected, got nil" } )
test.tryWrite( " 4.2", class, "_newMember", { 1 }, { false, "(member name) string expected, got number" } )
test.tryWrite( " 4.3", class, "_newMember", { "member" }, { false, "(member value) not nil expected, got nil" } )
test.tryWrite( " 4.4", class, "_newMember", { "member", 2 } )
test.tryRead ( " 4.5", class, "member", { true, 2 } )
test.tryWrite( " 4.6", class, "member", 5 )
test.tryRead ( " 4.7", class, "member", { true, 5 } )
test.tryWrite( " 4.8", class, "member", "a", { false, "(member) number expected, got string" } )
test.tryWrite( " 4.9", class, "_newMember", { "member", "str", locked=true } )
test.tryRead ( "4.10", class, "member", { true, "str" } )
test.tryWrite( "4.11", class, "member", "str2" )
test.tryRead ( "4.11", class, "member", { true, "str2" } )
test.tryWrite( "4.12", class, "_newMember", { "member", 22 }, { false, "Cannot override locked member" } )

function tFunc(x)
  return x + 1
end

function foo()
  return "bar"
end

test.note( "class methods" )
test.tryWrite( " 5.0", class, "_newMethod", nil, { false, "(method) table expected, got nil" } )
test.tryWrite( " 5.1", class, "_newMethod", 1,   { false, "(method) table expected, got number" } )
test.tryWrite( " 5.2", class, "_newMethod", { }, { false, "(method name) string expected, got nil" } )
test.tryWrite( " 5.3", class, "_newMethod", { 3 }, { false, "(method name) string expected, got number" } )
test.tryWrite( " 5.4", class, "_newMethod", { "meth" }, { false, "(method function) function expected, got nil" } )
test.tryWrite( " 5.5", class, "_newMethod", { "meth", 3 }, { false, "(method function) function expected, got number" } )
if test.tryWrite( " 5.6", class, "_newMethod", { "meth", tFunc } ) then
  test.try ( " 5.7", { class.meth, 4 }, { true, 5 } )
  test.tryWrite( " 5.8", class, "meth", 3, { false, "Cannot write to a defined method" } )
end
if test.tryWrite( " 5.9", class, "_newMethod", { "meth", foo, locked=true } ) then
  test.try ( "5.10", { class.meth }, { true, "bar"  } )
end
test.tryWrite( "5.11", class, "_newMethod", { "meth", tFunc }, { false, "Cannot override locked method" } )

local val = 40
local obj = { val = 0 }

function tGet()
  return val
end

function tSet(x)
  val = x
end

function tGetS(self)
  return self.val
end

function tSetS(self, v)
  self.val = v
end

test.note( "class properties" )
test.tryWrite( "6.0.0", class, "_newProperty", nil,   { false, "(property) table expected, got nil" } )
test.tryWrite( "6.0.1", class, "_newProperty", 1,     { false, "(property) table expected, got number" } )
test.tryWrite( "6.0.2", class, "_newProperty", { },   { false, "(property name) string expected, got nil" } )
test.tryWrite( "6.0.3", class, "_newProperty", { 1 }, { false, "(property name) string expected, got number" } )
test.tryWrite( "6.0.4", class, "_newProperty", { "prop" }, { false, "(property set with no get) function expected, got nil" } )
test.tryWrite( "6.0.5", class, "_newProperty", { "prop", 3 }, { false, "(property set with no get) function expected, got nil" } )

test.note( "read only", subnote)
if test.tryWrite( "6.1.1", class, "_newProperty", { "prop", get=tGet } ) then
  test.tryRead  ( "6.1.2", class, "prop", { true, 40 } )
  test.tryWrite ( "6.1.3", class, "prop", 50, { false, "Cannot write to a read-only property" } )
  test.tryRead  ( "6.1.4", class, "prop", { true, 40 } )
end
if test.tryWrite( "6.1.5", class, "_newProperty", { "prop", get="foobar" } ) then
  test.tryRead  ( "6.1.6", class, "prop", { true, "foobar" } )
  test.tryWrite ( "6.1.7", class, "prop", "asdf", { false, "Cannot write to a read-only property" } )
end
if test.tryWrite( "6.1.8", class, "_newProperty", { "prop", get=tGetS, self=obj } ) then
  test.tryWrite ( "6.1.9", class, "prop", 20, { false, "Cannot write to a read-only property" } )
  test.tryRead  ( "6.1.10", class, "prop", { true, 0 } )
end
test.tryWrite   ( "6.1.11", class, "_newProperty", { "prop", get="foobar", self=obj }, 
                  { false, "Implicit properties cannot reference a self object" } )
                  
test.note( "write only", subnote )
test.tryWrite   ( "6.2.0", class, "_newProperty", { "prop", tSet}, { false, "(property set with no get) function expected, got nil" } )
test.tryWrite   ( "6.2.1", class, "_newProperty", { "prop", set=3 }, { false, "(property set with no get) function expected, got number" } )
if test.tryWrite( "6.2.2", class, "_newProperty", { "prop", set=tSet } ) then
  test.tryWrite ( "6.2.3", class, "prop", 20 )
  test.try      ( "6.2.4", { tGet }, { true, 20 } )
  test.tryRead  ( "6.2.5", class, "prop", { false, "Cannot read from a write-only property" } )
end
if test.tryWrite( "6.2.6", class, "_newProperty", { "prop", set=tSetS, self=obj } ) then
  test.tryWrite ( "6.2.7", class, "prop", 33 )
  test.try      ( "6.2.8", { tGetS, obj }, { true, 33 } )
  test.tryRead  ( "6.2.9", class, "prop", { false, "Cannot read from a write-only property" } )
end

test.note( "read-write", subnote )
test.tryWrite   ( "6.3.0", class, "_newProperty", { "prop", set=1, get=tGet }, { false, "(property set) function expected, got number" } )
if test.tryWrite( "6.3.1", class, "_newProperty", { "prop", set=tSet, get=tGet } ) then
  test.tryWrite ( "6.3.2", class, "prop", 40 )
  test.tryRead  ( "6.3.3", class, "prop", { true, 40 } )
end
if test.tryWrite( "6.3.4", class, "_newProperty", { "prop", set=tSetS, get=tGetS, self=obj } ) then
  test.tryWrite ( "6.3.5", class, "prop", 72 )
  test.tryRead  ( "6.3.6", class, "prop", { true, 72 } )
end
if test.tryWrite( "6.3.7", class, "_newProperty", { "prop", set=tSet, get="hello" } ) then
  test.tryWrite ( "6.3.8", class, "prop", 23 )
  test.try      ( "6.3.9", { tGet }, { true, 23 } )
  test.tryRead  ( "6.3.10", class, "prop", { true, "hello" } )
end

test.note( "strong typed", subnote )
if test.tryWrite( "6.4.0", class, "_newProperty", { "prop", set=tSet, get=tGet, type="number" } ) then
  test.tryWrite ( "6.4.1", class, "prop", 5 )
  test.tryRead  ( "6.4.2", class, "prop", { true, 5 } )
  test.tryWrite ( "6.4.3", class, "prop", "foo", { false, "(prop) number expected, got string" } )
end

test.note( "locked property", subnote )
if test.tryWrite( "6.5.0", class, "_newProperty", { "prop", set=tSet, get=tGet, locked = true } ) then
  test.tryWrite ( "6.5.1", class, "prop", 99 )
  test.tryRead  ( "6.5.2", class, "prop", { true, 99 } )
  test.tryWrite ( "6.5.3", class, "_newProperty", { "prop", get="bad" }, { false, "Cannot override locked property" } )
end

test.note( "_index: special case" )
local index = { 20, "foo" }
local function getIndex(i)
  return index[i]
end
local function setIndex(i, v)
  index[i] = v
end
local function getIndexS(s, i)
  return s[i]
end
local function setIndexS(s, i, v)
  s[i] = v
end

test.tryWrite   ( " 7.0", class, "_newMember", { "_index", get=getIndex }, 
                  { false, "Reserved interface '_index' must be a property" } )
test.note( "read-only", subnote )
if test.tryWrite( "7.0.0", class, "_newProperty", { "_index", get=getIndex } ) then
  test.tryRead  ( "7.0.2", class, 1, { true, 20 } )
  test.tryRead  ( "7.0.3", class, 2, { true, "foo" } )
  test.tryWrite ( "7.0.4", class, 2, "bar", { false, "Numeric keys are read-only" } )
  test.tryRead  ( "7.0.5", class, 2, { true, "foo" } )
end
if test.tryWrite( "7.0.6", class, "_newProperty", { "_index", get=getIndexS, self=index } ) then
  test.tryRead  ( "7.0.7", class, 1, { true, 20 } )
  test.tryWrite ( "7.0.8", class, 1, "foo", { false, "Numeric keys are read-only" } )
  test.tryRead  ( "7.0.9", class, 1, { true, 20 } )  
end

test.note( "write-only", subnote )
if test.tryWrite( "7.1.0", class, "_newProperty", { "_index", set=setIndex } ) then
  test.tryRead  ( "7.1.1", class, 1, { false, "Numeric keys are write-only" } )
  test.tryWrite ( "7.1.2", class, 4, "foo" )
  test.try      ( "7.1.3", { getIndex, 4 }, { true, "foo" } )
end
if test.tryWrite( "7.1.4", class, "_newProperty", { "_index", set=setIndexS, self=index } ) then
  test.tryRead  ( "7.1.5", class, 1, { false, "Numeric keys are write-only" } )
  test.tryWrite ( "7.1.6", class, 4, "bar" )
  test.try      ( "7.1.7", { getIndex, 4 }, { true, "bar" } )
end

test.note( "read-write", subnote )
if test.tryWrite( "7.2.0", class, "_newProperty", { "_index", set=setIndex, get=getIndex } ) then
  test.tryWrite ( "7.2.1", class, 1, 30 )
  test.tryRead  ( "7.2.2", class, 1, { true, 30 } )
  test.tryWrite ( "7.2.3", class, 1, "foo" )
  test.tryRead  ( "7.2.4", class, 1, { true, "foo" } )
  test.tryRead  ( "7.2.5", class, 50, { true, nil } )
end
if test.tryWrite( "7.2.6", class, "_newProperty", { "_index", set=setIndexS, get=getIndexS, self=index } ) then
  test.tryWrite ( "7.2.7", class, 1, "bar" )
  test.tryRead  ( "7.2.8", class, 1, { true, "bar" } )
end
if test.tryWrite( "7.2.9", class, "_newProperty", { "_index", set=setIndex, get=getIndex, type="number", locked=true } ) then
  test.tryWrite ( "7.2.10", class, 10, 15 )
  test.tryRead  ( "7.2.11", class, 10, { true, 15 } )
  test.tryWrite ( "7.2.12", class, 10, "asdf", { false, "(index) number expected, got string" } )
  test.tryRead  ( "7.2.13", class, 10, { true, 15 } )
end

test.note( test.final() )
print( test.final() )
