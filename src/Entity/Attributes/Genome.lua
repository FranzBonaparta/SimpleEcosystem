local Object = require("libs.classic")
local Genome = Object:extend()

function Genome:new()
    self.sex = { 0, 0, 0, 0 }
    self.gestationDuration = { 0, 0, 0, 0 }
    self.duplicationSeasons = { 0, 0, 0, 0 }
    self.maxAgeMonths = { 0, 0, 0, 0 }
    self.circadian = { 0, 0, 0, 0 }
    self.visionRange = { 0, 0, 0, 0 }
    self.woolColor={0,0,0,0}
    self.hadMutated=false
    -- non implemented attributes:
    --woolColor ?
end
function Genome:getMutated()
    return self.hadMutated
end
function Genome:setMutated()
    self.hadMutated=not self.hadMutated
end
function Genome:setSex(array)
    self.sex = array
end
function Genome:setWoolColor(array)
    self.woolColor=array
end
function Genome:setGestationDuration(array)
    self.gestationDuration = array
end

function Genome:setDuplicationSeasons(array)
    self.duplicationSeasons = array
end

function Genome:setMaxAgeMonths(array)
    self.maxAgeMonths = array
end

function Genome:setCircadian(array)
    self.circadian = array
end

function Genome:setVisionRange(array)
    self.visionRange = array
end

function Genome:getSex()
    return self.sex
end
function Genome:getWoolColor()
    return self.woolColor
end
function Genome:getGestationDuration()
    return self.gestationDuration
end

function Genome:getDuplicationSeasons()
    return self.duplicationSeasons
end

function Genome:getMaxAgeMonths()
    return self.maxAgeMonths
end

function Genome:getCircadian()
    return self.circadian
end

function Genome:getVisionRange()
    return self.visionRange
end

function Genome:print()
    local text = string.format("DNA:\n[%s] [%s] [%s] [%s] [%s] [%s] [%s]",
        table.concat(self.sex, ","),
        table.concat(self.gestationDuration, ", "),
        table.concat(self.duplicationSeasons, ", "),
        table.concat(self.maxAgeMonths, ", "),
        table.concat(self.circadian, ", "),
        table.concat(self.visionRange, ", "),
        table.concat(self.woolColor,",")
    )
    return text
end

return Genome
