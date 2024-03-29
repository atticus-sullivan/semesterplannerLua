# Readme for the package semesterplannerLua

Author: Lukas Heindl (`oss.heindl+latex@protonmail.com`).

CTAN page: not yet

## License
The LaTeX package `semesterplannerLua` is distributed under the LPPL 1.3 license.

## Description

The LaTeX package `semesterplannerLua` adds commands to print timetables, lists
of appointments and exams including a calendars of specified ranges.

## Installation

For a manual installation:

* put the files `semesterplannerLua.ins` and `semesterplannerLua.dtx` in the
same directory;
* run `latex semesterplannerLua.ins` in that directory.

The file `semesterplannerLua.sty` will be generated.

In addition to the `semesterplannerLua.sty` the files
`semesterplannerLua_calendar.lua` and `semesterplannerLua_timetable.lua` are
also required. 
You have to put them in the same directory as your document or (best) in a `texmf` tree. 

### dmenu script
There is also the `semesterplannerLua_dmenu.lua` script which will display the
previous and next (and currently running) item from your timetable via dmenu,
copying the url or the link to the TUM roomfinder(if set) to your clipboard if
selected.

You might want to adapt the roomfinder behaviour.


Simplified version:

* run `l3build unpack` to generate the `.sty` (and the `.lua` files) in
`build/unpacked/`
