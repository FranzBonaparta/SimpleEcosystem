local Object=require("libs.classic")
local WorldClock=Object:extend()

function WorldClock:new()
    self.totalTime = 0       -- in seconds
    self.dayLength = 60      -- seconds = 1 day
    self.daysPerMonth = 30
    self.monthsPerYear = 12
    self.dayTime=1
    self.monthTime=1
    self.yearTime=1
    self.hourTime=1
end
function WorldClock:update(dt)
    self.totalTime = self.totalTime + dt
    if self.totalTime>=60 then
        self.totalTime=0
        self.hourTime=self.hourTime+1
    end
    if self.hourTime>23 then
        self.hourTime=1
        self.dayTime=self.dayTime+1
    end
    if self.dayTime>self.daysPerMonth then
        self.dayTime=1
        self.monthTime=self.monthTime+1
    end
    if self.monthTime>self.monthsPerYear then
        self.monthTime=1
        self.yearTime=self.yearTime+1
    end
end

function WorldClock:getDay()
    return self.dayTime
end

function WorldClock:getMonth()
    return self.monthTime
end

function WorldClock:getYear()
    return self.yearTime
end

function WorldClock:getSeason()
    local month = self:getMonth()
    if month == 12 or month <= 2 then
        return "Winter"
    elseif month <= 5 then
        return "Spring"
    elseif month <= 8 then
        return "Summer"
    else
        return "Autumn"
    end
end
function WorldClock:getTime()
    local time=string.format("Hour: %.2i Date: %.2i/%.2i/%.4i\n%q",
    self.hourTime,self:getDay(),self:getMonth(),self:getYear(),self:getSeason())
    return time
end

return WorldClock