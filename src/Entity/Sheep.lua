local Object = require("libs.classic")
local Sheep = Object:extend()
local Draws = require("libs.Draws")
local Feeding = require("src.Entity.Behavior.Feeding")
local Reproduction = require("src.Entity.Behavior.Reproduction")
local Movement = require("src.Entity.Behavior.Movement")
local Sleep = require("src.Entity.Behavior.Sleep")
local Social = require("src.Entity.Behavior.Social")
local LifeCycle = require("src.Entity.Attributes.LifeCycle")
local Genome = require("src.Entity.Attributes.Genome")
local Phenotype = require("src.Entity.Attributes.Phenotype")
local index = 1

function Sheep:new(tx, ty, tiles, scale, worldClock)
    self.index = index
    self.name = "Sheep"
    self.tx = tx
    self.ty = ty
    self.targetTx = nil
    self.targetTy = nil
    self.scale = scale / 16
    self.size = 10
    self.moveCooldown = 0
    self.feeding = Feeding()
    self.lifeCycle = LifeCycle(worldClock:getMonth(), worldClock:getYear(), 120)
    self.visionRange = 5
    self.circadian = "Diurnal"
    self.sleep = false
    self.adjacentTiles = {}
    local seasonsPreffered = { "Autumn" }
    self.reproduction = Reproduction(5, 7, seasonsPreffered)
    self.social = Social()
     self.woolColor=love.math.random(1,16)
     self.genome = Genome()

   
    local tile = Movement.getTile(tiles, self)
    Movement.setTile(tiles, tile, self)
    Phenotype.setPhenotype(self, self.genome)
    index = index + 1
end

function Sheep:getIndex()
    return self.index
end

function Sheep:getSex()
    return self.reproduction.sex
end

function Sheep:getGestationDuration()
    return self.reproduction.gestationDuration
end

function Sheep:getDuplicationSeasons()
    return self.reproduction.duplicationSeasons
end

function Sheep:getMaxAgeMonths()
    return self.lifeCycle.maxAgeMonths
end

function Sheep:getCircadian()
    return self.circadian
end

function Sheep:getVisionRange()
    return self.visionRange
end

function Sheep:getGenome()
    return self.genome
end
function Sheep:getWoolColor()
    return self.woolColor
end
function Sheep:setSex(sex)
    if type(sex) == "string" then
        self.reproduction.sex = sex
    else
        print("Invalid value passed to setSex: ", sex)
        return
    end
end
function Sheep:setWoolColor(color)
    self.woolColor=color
end
function Sheep:setGestationDuration(duration)
    if type(duration) == "number" then
        self.reproduction.gestationDuration = duration
    end
end

function Sheep:setDuplicationSeasons(seasonsArray)
    if type(seasonsArray) == "table" then
        self.reproduction.duplicationSeasons = seasonsArray
    else
        print("Invalid value passed to setDuplicationSeasons: ", seasonsArray)
        return
    end
end

function Sheep:setMaxAgeMonths(maxAgeMonths)
    if type(maxAgeMonths) == "number" then
        self.lifeCycle.maxAgeMonths = maxAgeMonths
    else
        print("Invalid value passed to setMaxAgeMonths: ", maxAgeMonths)
        return
    end
end

function Sheep:setCircadian(circadian)
    if type(circadian) == "string" then
        self.circadian = circadian
    else
        print("Invalid value passed to setCircadian: ", circadian)
        return
    end
end

function Sheep:setVisionRange(visionRange)
    if type(visionRange) == "number" then
        self.visionRange = visionRange
    else
        print("Invalid value passed to setVisionRange: ", visionRange)
    end
end

function Sheep:printGenome()
    return self.genome:print()
end

function Sheep:checkMutation()
    return Phenotype.checkIfGeneIsLethal(self.genome)
end

function Sheep:draw(tiles, entities)
    local tile = Movement.getTile(tiles, self)
    if tile then
        love.graphics.setColor(1, 1, 1)
        Draws.sheep(tile.x, tile.y, self.scale, self)
        self.social:draw(self, tiles, entities)
        --love.graphics.rectangle("fill", tile.x + self.size, tile.y + self.size, self.size, self.size)
        love.graphics.setColor(1,0,0)
        love.graphics.print(self.index,tile.x,tile.y)
        love.graphics.setColor(1, 1, 1)
    end
end

function Sheep:checkActions(dt, tiles, Sheeps, tile, worldClock)
    local actionMate, actionMother, actionFind = false, false, false
    self.moveCooldown = math.max(self.moveCooldown - dt, 0)
    self.feeding:update(dt)
    -- does the sheep is eating ?
    if not Sleep.sleep(self, worldClock) and not self.feeding:graze(self, tile, dt) and self.moveCooldown <= 0 and self.feeding.energy >= 0.25 then
        --if in couple
        if not self.social.isSingle then
            local mate=nil
            for _, sheep in ipairs(Sheeps)do
                if sheep.index==self.social.mate then
                    mate=sheep
                    break
                end
            end
            --mutation ?
            if mate and self.reproduction.sex == mate.reproduction.sex then
                self.social.mate = nil
                mate.social.mate = nil
                self.social.isSingle = true
                mate.social.isSingle = true
            end
            actionMate = self.social:followMate(self, Sheeps, tiles)
        else
            --if single
            --and young / else adult
            if self.lifeCycle.ageMonths < self.reproduction.adultAgeMonths then
                actionMother = self.social:followMother(self, Sheeps, tiles)
            else
                actionFind = self.social:findMate(self, Sheeps, tiles)
            end
        end
        --check if no action was rightly executed
        if (not (actionMate and self.social.mate and
                    self.lifeCycle.ageMonths >= self.reproduction.adultAgeMonths) and
                not (actionMother and self.social.mother and
                    self.lifeCycle.ageMonths < self.reproduction.adultAgeMonths) and
                not (actionFind and self.social.isSingle and
                    self.lifeCycle.ageMonths >= self.reproduction.adultAgeMonths))
            and not self.reproduction:update(self, tiles, Sheeps, Sheep, worldClock) then
            --last remaining action is to eat
            Movement.moveToBestHerb(tiles, self)
        end

        self.moveCooldown = 0.5
    end
end

function Sheep:update(dt, tiles, Sheeps, worldClock, stats)
    Movement.getAdjacentTiles(self.tx, self.ty, self, tiles)
    local tile = Movement.getTile(tiles, self)
    if self.lifeCycle:update(self, Sheeps, worldClock, stats) then
        if self.reproduction.pregnant then
            self.reproduction.monthPregnant = self.reproduction.monthPregnant + 1
        end
        Phenotype.mutate(self.genome, self)
    end
    --look if the sheep need to sleep
    Sleep.sleep(self, worldClock)
    --then test Actions
    self:checkActions(dt, tiles, Sheeps, tile, worldClock)
    --then search for join the last target!
    if self.targetTx and self.targetTy and self.moveCooldown <= 0 then
        Movement.moveToTarget(self, self.targetTx, self.targetTy, tiles)
        self.moveCooldown = 0.5
    end
end

return Sheep
