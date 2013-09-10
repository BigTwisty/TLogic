local function assert(value, message)
  if not value then error(message, 0)
  return value
end

if fs.exists("TLogic") then fs.delete("/TLogic") end
fs.makeDir("TLogic")


function git(path)
  h = http.get("https://raw.github.com/BigTwisty/TLogic/working/"..path)
  if not h then return false end
  file = h.readAll()
  h.close()
  return h
end

files = assert(git("filelist.txt"), "Error downloading filelist.txt from github")
print(files)