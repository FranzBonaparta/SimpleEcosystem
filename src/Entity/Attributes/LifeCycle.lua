local Object = require("libs.classic")

local LifeCycle = Object:extend()

function LifeCycle:new(month, year, maxMonths)
    self.ageMonths = 0
    self.birthDateMonth = month
    self.birthDateYear = year
    self.birthDateDay = 1
    self.lastMonthChecked = nil
    self.maxAgeMonths = maxMonths
end

function LifeCycle:update(entity, allEntities, worldClock,stats)
    --to update the age of the sheep
    local currentMonth = worldClock:getMonth()
    local currentYear = worldClock:getYear()
    local absoluteMonth = currentYear * 12 + currentMonth

    if self.lastMonthChecked ~= absoluteMonth then
        self.lastMonthChecked = absoluteMonth
        self.ageMonths = self.ageMonths + 1
        self:testDeath(entity, allEntities, stats)

        return true
    end
    return false
end

function LifeCycle:testDeath(entity, allEntities,stats)
    local random = 0
    local text=""
    if self.ageMonths < self.maxAgeMonths then
        random = love.math.random(1, 500)
        text="mysterious reason"
    else
        --the older he gets, the more likely he is to die
        local over=self.ageMonths-self.maxAgeMonths
        random = love.math.random(1, 100-(over*3))
        text="is too old"
    end
    local genome=entity:getGenome()
    if genome:getMutated() and entity:checkMutation() then
        text="had mutated but the mutation was fatal"
        random=1
    elseif genome:getMutated() and not entity:checkMutation() then
        genome:setMutated()
    end
    --die
    if random == 1 then

        --erase all social links: widows(widowers) are now singles
        for _, other in ipairs(allEntities) do
            if other.social.mate == entity.index then
                other.social.mate = nil
                other.social.isSingle = true
            end
            if other.social.mother == entity.index then
                other.social.mother=nil
            end
        end
        --then remove the dead entity from entityArray
        for i, other in ipairs(allEntities) do
            if other.index == entity.index then
                text = text..string.format("☠️ %q %i just died at age %i years and %i months !\nReason: %s",
                    entity.name, entity.index,
                    math.floor(self.ageMonths / 12), self.ageMonths % 12,text)
                table.remove(allEntities, i)
                stats.deads=stats.deads+1
                print(text)
                break
            end
        end
    end

end

return LifeCycle
