module = "semesterplannerlua"
typesetexe = "lualatex"
unpackexe = "luatex"

installfiles = {"*.lua", "*.sty"}
sourcefiles = {"*.dtx", "*.ins", "semesterplannerlua_calendar.lua", "semesterplannerlua_dmenu.lua", "semesterplannerlua_timetable.lua"}
excludefiles = {".link.md", "*~","build.lua","config-*.lua"}
