#!/usr/bin/env texlua

----------------------
-- HELPER_FUNCTIONS --
----------------------
local function check_installed(prog)
    local r = os.execute("which " .. prog .. "&> /dev/null")
    return r
end

local function help()
    print("Displays a dmenu prompt with the last, current and next events and copies location/url [+password] to the clipboard")
    print()
    print("USAGE:")
    print(string.format("\t%s dataFile [ignoreType ...]", arg[0]))
    print()
    print("OPTIONS:")
    print()
    print("ARGS:")
    print(string.format("\t%-12s\t%s", "<dataFile>",   "path to the input csv file with 'start', 'end', 'title', 'location', 'password', 'type' headers (not written in the file)"))
    print(string.format("\t%-12s\t%s", "",   "location may contain '\\href{location}{url}' in which casethe two fields are extracted"))
    print(string.format("\t%-12s\t%s", "<ignoreType>", "entries with that type are ignored"))
end

local function dur2str(dur)
    return string.format("%02d:%02d", dur//60, dur%60)
end

local function contains(t, ele)
    for _,v in pairs(t) do
        if v == ele then return true end
    end
    return false
end

-------------------
-- PREREQUISITES --
-------------------
if not check_installed("dmenu") then
    print("Error: dmenu has to be installed (options -l, -i and -p required, but these are in the default anyway)")
    os.exit(-1)
end
if not check_installed("xsel") then
    print("Error: xsel has to be installed")
    os.exit(-1)
end

if #arg < 1 then
    print("Error: At least one argument has to be given")
    print()
    help()
    os.exit(-1)
end
if arg[1] == "-h" or arg[1] == "--help" then
    help()
    os.exit(0)
end

local type_exclude = {}
for i=1,#arg do
    table.insert(type_exclude, arg[i])
end

-----------
-- MAIN --
----------

local maxes = {title=0, location=0, type=0}

local before = {diff=25*60*7}
local after  = {diff=25*60*7}

local c = {}

local current   = os.date("*t")
local today     = tonumber(os.date("%u")) - 1
current.minutes = current.min + (today*24 + current.hour)*60

local inputs = loadfile(arg[1], "t", {})() -- easy loading comes with the disadvantage that arbitrary code which is in that file gets executed
for _,ele in ipairs(inputs) do
    if not contains(type_exclude, ele["type"]) then
        ele.start, ele["end"] = tonumber(ele.start), tonumber(ele["end"])
        ele.url      = ele.location:match([[\href ?{(.*)}{.*}]])
        ele.location = ele.location:match([[\href ?{.*}{(.*)}]]) or ele.location

        if maxes.title    < #ele.title    then maxes.title    = #ele.title    end
        if maxes.location < #ele.location then maxes.location = #ele.location end
        if maxes.type     < #ele.type     then maxes.type     = #ele.type     end

        if current.minutes > ele.start and current.minutes < ele["end"] then
            ele.diff = current.minutes-ele["start"]
            table.insert(c, ele)
        elseif current.minutes < ele.start then
            if ele.start - current.minutes < before.diff then
                before = {diff=ele.start-current.minutes}
            end
            if ele.start - current.minutes <= before.diff then
                ele.diff = before.diff
                table.insert(before, ele)
            end
        elseif current.minutes > ele["end"] then
            if current.minutes - ele["end"] < after.diff then
                after = {diff=current.minutes-ele["end"]}
            end
            if current.minutes - ele["end"] <= after.diff then
                ele.diff = after.diff
                table.insert(after, ele)
            end
        end
    end
end

maxes = {title=maxes.title < 100 and maxes.title or 99, location=maxes.location < 100 and maxes.location or 99, type=maxes.type < 100 and maxes.type or 99}

local dmenu_in,map = {},{}
for _,x in ipairs(after) do
    local s = string.format("%-".. maxes.title+1+maxes.type .."s %-".. maxes.location+2 .."s # ended %s ago", x.title.."-"..x.type, "("..x.location..")", dur2str(x.diff))
    table.insert(dmenu_in, s)
    map[s] = x
end

for _,x in ipairs(c) do
    local s = string.format("%-".. maxes.title+1+maxes.type .."s %-".. maxes.location+2 .."s # began %s ago", x.title.."-"..x.type, "("..x.location..")", dur2str(x.diff))
    table.insert(dmenu_in, s)
    map[s] = x
end

for _,x in ipairs(before) do
    local s = string.format("%-".. maxes.title+1+maxes.type .."s %-".. maxes.location+2 .."s # begins in %s", x.title.."-"..x.type, "("..x.location..")", dur2str(x.diff))
    table.insert(dmenu_in, s)
    map[s] = x
end

local dmenu_ins = table.concat(dmenu_in, "\n")

print(dmenu_ins)
-- TODO check for forbidden strings in dmenu_in
local proc = io.popen(string.format("echo '%s' | dmenu -i -l %d -p 'Select entry'", dmenu_ins, #dmenu_in), "r")
local dmenu_out = proc:read("l")
if not dmenu_out then
    os.execute("notify-send 'Uni' 'Nothing selected'")
    os.exit()
end

local sel = map[dmenu_out]
assert(sel, "Error building/reading the lookup table")
if sel.url and sel.url ~= "" then
    os.execute(string.format("echo -n '%s' | xsel -b && notify-send -h string:x-canonical-private-synchronous:uni 'Uni' 'Copied URL to clipboard'", sel.url))
elseif sel.location and sel.location ~= "" then
    os.execute(string.format("echo -n '%s' | xsel -b && notify-send -h -- string:x-canonical-private-synchronous:uni 'Uni' 'Copied URL to clipboard'", sel.location))
    os.execute(string.format("echo -n 'https://portal.mytum.de/campus/roomfinder/search_room_results?searchstring=%s&building=Alle&search=Suche+starten' | xsel -b && notify-send -h string:x-canonical-private-synchronous:uni 'Uni' 'Copied Roomfinder-url to clipboard'", sel.location))
end

if sel.password and sel.password ~= "" then
    os.execute(string.format("sleep 3 && echo -n '%s' | xsel -b && notify-send -h string:x-canonical-private-synchronous:uni 'Uni' 'Copied password to clipboard'", sel.password))
end
