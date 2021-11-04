.PHONY: clean

master.pdf: master.tex semesterplanner-lua.sty semesterplanner-lua-calendar.lua semesterplanner-lua-timetable.lua tex-aux
	test -d tex-aux # check if tex-aux is really a directory
	cluttex --output-directory=tex-aux -e lualatex master.tex

semesterplanner-lua.sty:
	cp ../semesterplanner-lua.sty ./

semesterplanner-lua-timetable.lua:
	cp ../semesterplanner-lua-timetable.lua ./
semesterplanner-lua-calendar.lua:
	cp ../semesterplanner-lua-calendar.lua ./

tex-aux:
	mkdir tex-aux

clean:
	$(RM) semesterplanner-lua.sty semesterplanner-lua.lua master.pdf
	-test -d tex-aux && $(RM) -r tex-aux

spellA:
	-aspell --home-dir=. --personal=dict.txt -l de_DE -t -c master.tex
	iconv -f ISO-8859-1 -t UTF-8 ./dict.txt > ./dict.txt2
spellT:
	-textidote --check de --remove tikzpicture --replace replacements.txt --dict ./dict.txt2 --output html master.tex > master-texidote.html
