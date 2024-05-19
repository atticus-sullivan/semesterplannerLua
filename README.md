# Readme for the package semesterplannerLua

Author: Lukas Heindl (`oss.heindl+latex@protonmail.com`).

CTAN page: [semesterplannerlua](https://ctan.org/pkg/semesterplannerlua)

## License
The LaTeX package `semesterplannerLua` is distributed under the LPPL 1.3 license.

## Description

The LaTeX package `semesterplannerLua` provides commands to print timetables, lists
of appointments and exams. Also it is possible to draw calendars of specified
ranges (and mark dates which were previously listed).

## Installation

For a manual installation:

* put the files `semesterplannerlua.ins` and `semesterplannerlua.dtx` in the
same directory;
* run `latex semesterplannerlua.ins` in that directory.

The file `semesterplannerlua.sty` will be generated.

In addition to the `semesterplannerlua.sty` the files
`semesterplannerLua_calendar.lua` and `semesterplannerLua_timetable.lua` are
also required. 
You have to put them in the same directory as your document or (best) in a `texmf` tree. 


### Simplified version:

* run `l3build unpack` to generate the `.sty` (and the `.lua` files) in
`build/unpacked/`

### Experimental: dmenu script
There is also the `semesterplannerLua_dmenu.lua` script which will display the
previous and next (and currently running) item from your timetable via dmenu,
copying the url or the link to the TUM roomfinder(if set) to your clipboard if
selected.

You might want to adapt the roomfinder behaviour.
