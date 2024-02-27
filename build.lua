module = "semesterplannerLua"
typesetexe = "lualatex"
unpackexe = "luatex"

installfiles = {"*.lua", "*.sty"}
sourcefiles = {"*.dtx", "*.ins", "semesterplannerLua_calendar.lua", "semesterplannerLua_dmenu.lua", "semesterplannerLua_timetable.lua"}
excludefiles = {".link.md", "*~","build.lua","config-*.lua"}
