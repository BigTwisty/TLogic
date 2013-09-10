h = http.get("https://api.github.com/repos/BigTwisty/TLogic/blob/working/files.txt")
if not h then error("Could not load working files.", 0) end

local function assert(value, message)
  if not value then error(message, 0)
  return value
end

if fs.exists("TLogic") then fs.delete("/TLogic") end
fs.makeDir("TLogic")

function git(path)
  h = 