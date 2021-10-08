function init(days, min, max)
	-- clean up first
	-- global variables
	EVENTS={}
	DAYS = days -- header with names of the days set from tex currently
	DAYSE = {"M","T","W","Th","F"}
	MIN = 25*60 -- bigger than any allowed value could be
	MAX = 0
	MIN_BYPASS = false
	MAX_BYPASS = false

	if(min == "") then
	else
		assert(min:match("^%d+"), "start time has to be an integer representing the HH*60+MM of the desired start time")
		MIN = tonumber(min)
		MIN_BYPASS = true
	end

	if(max == "") then
	else
		assert(max:match("^%d+"), "end time has to be an integer representing the HH*60+MM of the desired end time")
		MAX = tonumber(max)
		MAX_BYPASS = true
	end
end

-- result are the global variables EVENTS, MIN and MAX
function addEvent(opts)
	if(not checkKeys(opts, {"time", "day", "content", "tikz"})) then
		error("missing argument")
	end

	opts.from,opts.to = dur2Int(opts.time)

	if(not MIN_BYPASS and opts.from < MIN) then MIN = opts.from end
	if(not MAX_BYPASS and opts.to   > MAX) then MAX = opts.to   end

	table.insert(EVENTS, opts)
end

-- parameters are all global variables
function draw(length, width)
	print("length", length)
	print("width", width)
	-- copy relevant variables for working on local copies
	local events = copy_array(EVENTS)
	local days = prepareDays(DAYS)
	local daysE = copy_array(DAYSE)
	local min, minH, max, maxH = prepareMinMax(MIN, MAX)

	assert(length:match("%d*%.?%d*"), "Length must be a valid length measured in cm")
	length = tonumber(length)

	textwidth = width

	tex.print([[\begin{tikzpicture}]])
	tex.print([[\tikzset{defStyle/.style={font=\tiny,anchor=north west,fill=blue!50,draw=black,rectangle}}]])

	-- print the tabular with the weekday headers
	-- TODO -> doc weekday headers do not count to length
	tex.print(string.format([[\foreach \week [count=\x from 0, evaluate=\x as \y using \x+0.5] in {%s}{ ]], table.concat(days, ",")))
	tex.print(string.format([[\node[anchor=south] at (\y/%d* %s, 0) {\week};]], #days, textwidth))
	tex.print(string.format([[\draw (\x/%d * %s, 0cm) -- (\x/%d * %s, %dcm);]], #days, textwidth, #days, textwidth, -length))
	tex.print("}")
	tex.print(string.format([[\draw (%s, 0) -- (%s,%dcm);]], textwidth, textwidth, -length))

	-- TODO -> doc (set this via a length - length.setToWidth(12:30)) timelabels add to the width
	for i=minH,maxH do
		tex.print(string.format([[\node[anchor=east] at (0,%fcm ) {%d:00};]], minuteToFrac(i*60,min,max)*-length, i))
		tex.print(string.format([[\draw (0,%fcm ) -- (%s,%fcm );]], minuteToFrac(i*60,min,max)*-length, textwidth, minuteToFrac(i*60,min,max)*-length))
	end

	local d
	local red = 0.3333 -- calculated in em from inner sep
	local red_y = 0.25 -- calculated in em
	for _,e in ipairs(events) do
		d = search_array(daysE, e.day) - 1
		tex.print(string.format(
			[[\node[defStyle,text width=-%fem+%f%s/%d, text depth=%fcm-%fem, text height=%fem, %s] at (%f*%s,%fcm) {%s};]],
			2*red, -- text width
			e.scale_width, -- text width
			textwidth,
			#days, -- text width
			length*(e.to-e.from)/(max-min), -- text depth
			2*red+red_y, -- text depth
			red_y, -- text height
			e.tikz, -- free tikz code
			(d+e.offset)/#days, -- xcoord
			textwidth,
			minuteToFrac(e.from,min,max)*-length, -- ycoord
			e.content -- content
			)
		)
	end
	tex.print([[\end{tikzpicture}]])
end

function search_array(t, s)
	for k,v in ipairs(t) do
		if(v == s) then return k end
	end
	return nil
end

function minuteToFrac(minute, min, max)
	return (minute-min)/(max-min)
end

function prepareMinMax(min, max)
	local minH = math.floor(min/60)
	local maxH = math.ceil(max/60)
	local min = minH*60
	local max = maxH*60
	return min, minH, max, maxH
end

function checkKeys(t, k)
	for _,x in ipairs(k) do
		if(t[x] == nil) then
			return false
		end
	end
	return true
end

function dur2Int(clk)
	local f1,f2, t1,t2 = clk:match("^(%d%d?):(%d%d)-(%d%d?):(%d%d)$")
	if(f1 ~= nil and f2 ~= nil and t1 ~= nil and t2 ~= nil) then
		f1 = tonumber(f1) f2 = tonumber(f2)
		t1 = tonumber(t1) t2 = tonumber(t2)
		assert(f1 >= 0 and f1 < 24, "Hours have to be >= 0 && < 24")
		assert(f2 >= 0 and f2 < 60, "Mins have to be >= 0 && < 60")
		assert(t1 >= 0 and t1 < 24, "Hours have to be >= 0 && < 24")
		assert(t2 >= 0 and t2 < 60, "Mins have to be >= 0 && < 60")
		return f1*60 + f2, t1*60 + t2
	else
		error("clk string \"" .. clk .. "\" was no valid clock string")
	end
end

function prepareDays(days)
	local ret = {}
	for m in days:gmatch("[^,]+") do
		table.insert(ret, m)
	end
	return ret
end

function copy_array(obj)
	if type(obj) ~= 'table' then return obj end
	local res = {}
	for k, v in pairs(obj) do
		local c = copy_array(v)
		res[copy_array(k)] = c
	end
	return res
end

semesterplanner = {
	init = init,
	addEvent = addEvent,
	draw = draw
}
return semesterplanner
