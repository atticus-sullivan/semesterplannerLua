local dateLib = require "date"
function init(clear)
    -- clean up first
    -- global variable
    if clear then
        EVENTS = {}
    end
end

text = {
    print = function(s)
        -- print("\"" .. s .. "\"")
        tex.print(s)
    end
}

function genDot(opts)
    dot = ""
    if opts.draw then
        dot = string.format([[\tikz[baseline=(X.base)]\node (X) [fill opacity=.5,fill=red,circle,inner sep=0mm, %s] {\phantom{D}};]], opts.tikz)
    end
    return dot
end

function addEvent(opts)
    opts.inputlineno = tex.inputlineno
    -- print(string.format("collecting from line %d", opts.inputlineno))
    if opts.draw then
        assert(opts.date ~= nil and opts.tikz ~= nil, "date and tikz has to be given")
        if opts.endDate == nil or opts.endDate == '' then
            table.insert(EVENTS, {shift=opts.shift,date=dateLib(opts.date), tikz=opts.tikz, period=opts.period, endDate=nil, inputlineno=opts.inputlineno})
        else
            table.insert(EVENTS, {shift=opts.shift,date=dateLib(opts.date), tikz=opts.tikz, period=opts.period, endDate=dateLib(opts.endDate), inputlineno=opts.inputlineno})
        end
    end
end

function addAppointment(opts)
    addEvent(opts)
    dot = genDot(opts)
    if opts.print then
        tex.sprint(string.format([[\textit{%s} & %s & %s%s & %s & %s & %s\\]], opts.date, opts.time, dot, opts.course, opts.desc, opts.room, opts.prio))
    else
        tex.sprint("%")
    end
end

function addExam(opts)
    addEvent(opts)
    dot = genDot(opts)
    if opts.print then
        tex.sprint(string.format([[\textit{%s} & %s & %s%s & %s & %s \\]], opts.date, opts.time, dot, opts.course, opts.type, opts.desc))
    else
        tex.sprint("%")
    end
end

function addDeadline(opts)
    addEvent(opts)
    dot = genDot(opts)
    if opts.print then
        tex.sprint(string.format([[\textit{%s} & %s%s & %s & %s \\]], opts.date, dot, opts.course, opts.desc, opts.prio))
    else
        tex.sprint("%")
    end
end

function drawCalendar(minDate, maxDate, cols)
    minDate = dateLib(minDate)
    maxDate = dateLib(maxDate)
    text.print([[\begin{tikzpicture}[every calendar/.style={day headings=red!50,day letter headings,inner sep=2pt, week list, month label above centered, month text={\textcolor{red}{\%mt} \%y-}, every month/.style={yshift=3ex}}] ]])
    text.print([[\matrix[column sep=1em, row sep=1em]{]])
        local i = 1
        running = true
        while running do
            -- derive end from start, then check if maxDate is reached
            endDate = minDate:copy():addmonths(1):setday(1):adddays(-1)
            if endDate >= maxDate then
                endDate = maxDate
                running = false
            end
            text.print(string.format(
            [[\calendar (%04d-%02d) [dates=%04d-%02d-%02d to %04d-%02d-%02d] if (Sunday) [red] if (Saturday) [red!50!white] if (equals=\year-\month-\day) [nodes={inner sep=.25em,rectangle,line width=1pt,draw}] if (at least=\year-\month-\day) {} else [nodes={strike out, draw}]; ]],
                    minDate:getyear(), minDate:getmonth(), minDate:getyear(), minDate:getmonth(), minDate:getday(), endDate:getyear(), endDate:getmonth(), endDate:getday()))

            minDate:addmonths(1)
            minDate:setday(1)

            if i % cols == 0 or not running then
                text.print([[\\]])
            else
                text.print([[&]])
            end
            i = i + 1
        end
        text.print([[ }; ]])

        local usedDates = {}
        text.print([[\begin{scope}[on background layer] ]])
        for i,ele in ipairs(EVENTS) do
            -- print(string.format("Drawing item from line %d", ele.inputlineno))
            while ele.date <= maxDate and (ele.endDate == nil or ele.date <= ele.endDate) do
                local xshift = 0
                if ele.shift then
                    if usedDates[tostring(ele.date)] ~= nil then
                        xshift = math.ceil(usedDates[tostring(ele.date)] / 2)
                        if usedDates[tostring(ele.date)] % 2 == 0 then
                            xshift = -xshift
                        end
                        usedDates[tostring(ele.date)] = usedDates[tostring(ele.date)] + 1
                    else
                        usedDates[tostring(ele.date)] = 1
                    end
                end
                text.print(string.format([[\node[xshift=%d mm, fill opacity=.5,fill=red,circle,text width=0ex,inner sep=1.1ex, %s] at (%04d-%02d-%04d-%02d-%02d) {};]],
                    xshift, ele.tikz, ele.date:getyear(), ele.date:getmonth(), ele.date:getyear(), ele.date:getmonth(), ele.date:getday()))
                if ele.period == nil then break end
                ele.date:adddays(ele.period)
            end
        end
        text.print([[\end{scope}]])
    text.print([[\end{tikzpicture}]])
end

semesterplannerLuaCal = {
    init = init,
    addAppointment = addAppointment,
    addDeadline = addDeadline,
    addExam = addExam,
    drawCalendar = drawCalendar,
}
return semesterplannerLuaCal
