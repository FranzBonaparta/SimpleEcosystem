local Object = require("libs.classic")
local Social = Object:extend()
local Movement = require("src.Entity.Behavior.Movement")

function Social:new()
    self.size = 16
    self.isSingle = true
    self.mate = nil
    self.mother = nil
    self.father = nil
end

local function getTile(tx, ty, tiles)
    for _, line in ipairs(tiles) do
        for _, tile in ipairs(line) do
            if tile.tx == tx and tile.ty == ty then
                return tile
            end
        end
    end
end
local function getEntity(index, entities)
    for _, entity in ipairs(entities) do
        if entity.index == index then
            return entity
        end
    end
end
function Social:isValidMate(entity, other)
    return other.lifeCycle.ageMonths >= other.reproduction.adultAgeMonths
        and other.social.isSingle
        and other.reproduction.sex ~= entity.reproduction.sex
        and entity.social.mate ~= other.index
        and other.social.mate ~= entity.index
end
function Social:findCloserMate(entity, allEntities, tiles)
        Movement.getAdjacentTiles(entity.tx, entity.ty, entity, tiles)
    for _, tile in ipairs(entity.adjacentTiles) do
        if tile.isHabitedBy then
            for _, other in ipairs(allEntities) do
                if tile.isHabitedBy == other.index
                    and self:isValidMate(entity, other) then
                    self.mate = other.index
                    other.social.mate = entity.index
                    self.isSingle = false
                    other.social.isSingle = false
                    print("Sheep " .. entity.index .. " and " .. other.index .. " love 💗 each other!")
                    return true
                end
            end
        end
    end
end 
function Social:findFarerMate(entity, allEntities, tiles)
    local currentDist = #tiles
    local nextDist = 0
    local selectedEntity = nil
    for _, other in ipairs(allEntities) do
        if self:isValidMate(entity, other) then
            nextDist = Movement.getGridDistance(entity.tx,entity.ty, other.tx, other.ty)
            if nextDist < currentDist and nextDist > math.sqrt(2) then
                currentDist = nextDist
                selectedEntity = other
            end
        end
    end
    if selectedEntity and currentDist <= entity.visionRange then
        Movement.moveToTarget(entity, selectedEntity.tx, selectedEntity.ty, tiles)
        return true
    end
    return false
end
function Social:findMate(entity, allEntities, tiles)
    local found=self:findCloserMate(entity,allEntities,tiles)
    if not found then
        found=self:findFarerMate(entity,allEntities,tiles)
    end
    return found
end

function Social:followMate(entity, allEntities, tiles)
    Movement.getAdjacentTiles(entity.tx, entity.ty, entity, tiles)
    if not self.mate then 
        return false end
    for _, other in ipairs(allEntities) do
        if other.index == self.mate then
            local currentDist = Movement.getGridDistance(entity.tx,entity.ty, other.tx, other.ty)
            if currentDist <= 2 then
                -- déjà à côté
                return false
            else
                -- déplacement vers le partenaire
                Movement.moveToTarget(entity, other.tx, other.ty, tiles)
                return true
            end
        end
    end
end

function Social:followMother(entity, allEntities, tiles)
    Movement.getAdjacentTiles(entity.tx, entity.ty, entity, tiles)

    if not self.mother then 
        return false end
    for _, other in ipairs(allEntities) do
        if other.index == self.mother then
            local currentDist = Movement.getGridDistance(entity.tx,entity.ty, other.tx, other.ty)
            if currentDist <=2 then
                -- déjà à côté
                return false
            else
                -- déplacement vers le partenaire
                Movement.moveToTarget(entity, other.tx, other.ty, tiles)
            end
            return true
        end
    end
end

function Social:draw(entity, tiles, entities)
    if self.mate and entity.reproduction.sex == "Female" then
        local entityTile = getTile(entity.tx, entity.ty, tiles)
        local mate = getEntity(self.mate, entities)
        local mateTile = getTile(mate.tx, mate.ty, tiles)
        love.graphics.setColor(0, 0, 1)
        love.graphics.line(entityTile.x + self.size / 2, entityTile.y + self.size / 2,
            mateTile.x + self.size / 2, mateTile.y + self.size / 2)
    end
    if entity.lifeCycle.ageMonths < entity.reproduction.adultAgeMonths and self.mother then
        local entityTile = getTile(entity.tx, entity.ty, tiles)
        local mother = getEntity(self.mother, entities)
        local motherTile = getTile(mother.tx, mother.ty, tiles)
        love.graphics.setColor(1, 1, 0)
        love.graphics.line(entityTile.x + self.size / 2, entityTile.y + self.size / 2,
            motherTile.x + self.size / 2, motherTile.y + self.size / 2)
    end
end


return Social
