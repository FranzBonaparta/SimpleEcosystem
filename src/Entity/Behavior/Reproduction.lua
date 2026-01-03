local Object = require("libs.classic")
local Reproduction = Object:extend()
local Phenotype = require("src.Entity.Attributes.Phenotype")

function Reproduction:new(duration, adultAgeMonths, seasons)
    local random = love.math.random(1, 2)
    self.sex = random == 1 and "Male" or "Female"
    self.pregnant = false
    self.monthPregnant = nil
    self.genitor = nil
    self.gestationDuration = duration
    self.adultAgeMonths = adultAgeMonths
    self.duplicationSeasons = {}
    for _, season in ipairs(seasons) do
        table.insert(self.duplicationSeasons, season)
    end
end

function Reproduction:canMate(entity, allEntities)
    for _, tile in ipairs(entity.adjacentTiles) do
        if tile.isHabitedBy then
            for _, other in ipairs(allEntities) do
                if other.reproduction.sex ~= self.sex and tile.isHabitedBy == other.index
                    and other.lifeCycle.ageMonths >= other.reproduction.adultAgeMonths then
                    self.genitor = other
                    local taboo = other.index == entity.social.father or entity.index == other.social.mother
                    local text = taboo and "😱 " or ""
                    if entity.social.isSingle and other.social.isSingle then
                        print(text .. entity.index .. " and " .. other.index .. " are doing some 🔥 stuff!")
                        return true
                    elseif entity.social.mate == other.index then
                        print(text .. entity.index .. " and " .. other.index .. " (partners) are doing some 🔥 stuff!")
                        return true
                    else
                        local random = love.math.random(1, 5) -- 1 chance sur 5 d'infidélité
                        if random == 1 then
                            print(text .. entity.index .. " is cheating with " .. other.index .. " 😳")
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

function Reproduction:isPregnant(entity, allEntities)
    if self:canMate(entity, allEntities) and entity.lifeCycle.ageMonths >= self.adultAgeMonths then
        local pregnant = love.math.random(1, 2)
        if pregnant == 2 then
            self.monthPregnant = 0
            self.pregnant = true
        end
    end
end

function Reproduction:duplicate(tiles, entity, allEntities, constructor, worldClock)
    if not self.pregnant then
        self:isPregnant(entity, allEntities)
    end

    if self.pregnant and self.gestationDuration <= self.monthPregnant then
        local eligleTiles = {}
        for _, adjacentTile in ipairs(entity.adjacentTiles) do
            if not adjacentTile.isHabitedBy then
                table.insert(eligleTiles, adjacentTile)
            end
        end
        if #eligleTiles > 0 then
            local randomTile = eligleTiles[love.math.random(1, #eligleTiles)]
            for y, line in ipairs(tiles) do
                for x, possibleTile in ipairs(line) do
                    if possibleTile.x == randomTile.x and possibleTile.y == randomTile.y then
                        local newEntity = constructor(x, y, tiles, entity.scale * 16, worldClock)
                        newEntity.social.mother = entity.index
                        local father = self.genitor
                        newEntity.social.father = self.genitor.index
                        table.insert(allEntities, newEntity)
                        Phenotype.procreate(entity, father, newEntity)
                        Phenotype.decodeGenomeToEntity(newEntity:getGenome(), newEntity)
                        entity.feeding.apetite = 0.75
                        entity.feeding.energy = 0.25
                        print("New Soul #" ..
                            newEntity.index ..
                            " is born; the mother is " .. entity.index .. ", his father " .. self.genitor.index .. "!")
                        --print("Mother " .. entity:printGenome())
                        --print("Father " .. father:printGenome())
                        print("New Entity "..newEntity:printGenome())
                        self.monthPregnant = nil
                        self.pregnant = false
                        break
                    end
                end
            end
        end
    end
end

local function isIdealSeason(seasonArray, worldSeason)
    for _, season in ipairs(seasonArray) do
        if season == worldSeason then
            return true
        end
    end
    return false
end
--require all tiles to duplicate !
function Reproduction:update(entity, tiles, entities, constructor, worldClock)
    if entity.lifeCycle.ageMonths >= self.adultAgeMonths and
        self.sex == "Female" and not self.pregnant and
        isIdealSeason(self.duplicationSeasons, worldClock:getSeason())
    then
        local potentialMates = 0

        for _, adjacentTile in ipairs(entity.adjacentTiles) do
            for _, other in ipairs(entities) do
                if adjacentTile.isHabitedBy and other.index == adjacentTile.isHabitedBy and
                    other.reproduction.sex ~= self.sex then
                    potentialMates = potentialMates + 1
                end
            end
        end
        if potentialMates > 0 then
            self:duplicate(tiles, entity, entities, constructor, worldClock)
            return true
        end
    elseif self.pregnant then
        self:duplicate(tiles, entity, entities, constructor, worldClock)
    end
    return false
end

return Reproduction
