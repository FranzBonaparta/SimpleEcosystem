local HUD = {}
HUD.sheep = nil
function HUD.separate(string)
    local length = string.len(string)
    local separator = "\n"
    for x = 1, length do
        separator = separator .. "-"
    end
    separator = separator .. "\n"
    return separator
end

function HUD.drawEntityArray(EntityArray, separator, stats)
    local hud = string.format("Total of %q: %i ", EntityArray[1].name, #EntityArray)

    local young = 0
    local adult = 0
    local pregnant = 0
    local males = 0
    local females = 0
    for _, entity in ipairs(EntityArray) do
        if entity.lifeCycle.ageMonths < entity.reproduction.adultAgeMonths then
            young = young + 1
        else
            adult = adult + 1
        end
        if entity.reproduction.pregnant then
            pregnant = pregnant + 1
        end
        if entity.reproduction.sex == "Male" then
            males = males + 1
        else
            females = females + 1
        end
    end

    local text = string.format("Adults: %i, Youngs: %i, Pregnants: %i,\nMales: %i, Females: %i, Deads: %i",
        adult, young, pregnant, males, females, stats.deads)

    return hud .. separator .. text
end

function HUD.draw(entitiesArrays, worldClock, stats)
    local speed = string.format("Speed: x%i\n", stats.speed)
    for x = 1, stats.speed do
        speed = speed .. ">"
    end
    local hud = worldClock:getTime()
    local separator = HUD.separate(hud)

    hud = speed .. separator .. hud .. separator
    if #entitiesArrays > 0 then
        for _, array in ipairs(entitiesArrays) do
            hud = hud .. HUD.drawEntityArray(array, separator, stats)
        end
    end

    love.graphics.printf(hud, 700, 20, 300)
end

function HUD.printDetail(entity)
    love.graphics.setColor(1, 1, 1)
    local seasonsArray=entity:getDuplicationSeasons()
    local seasons=table.concat(seasonsArray,",")
    local text = string.format(
        "%s #%i, %s [%.2i, %.2i]\nAgeMonths=%i, MaxAgeMonths=%i months,\nVisionRange: %i\nCircadian rythm: %s, GestationDuration: %i, DuplicateSeasons: %s",
        entity.name, entity.index, entity.reproduction.sex, entity.tx, entity.ty,
        entity.lifeCycle.ageMonths, entity.lifeCycle.maxAgeMonths,entity.visionRange,
        entity.circadian, entity.reproduction.gestationDuration,
        seasons
    )
    local genome=entity:getGenome()
    --sex/gestation/duplication/maxAge/circadian/visionRange
    local dna=string.format("DNA:\n[%s] [%s] [%s] [%s] [%s] [%s]",
    table.concat(genome:getSex(),","),
    table.concat(genome:getGestationDuration(),", "),
    table.concat(genome:getDuplicationSeasons(),", "),
    table.concat(genome:getMaxAgeMonths(),", "),
    table.concat(genome:getCircadian(),", "),
    table.concat(genome:getVisionRange(),", ")
)

    text=text.."\n"..dna
    love.graphics.printf(text, 10, 700, 800)
end

function HUD.updateHoveredSheep(mx, my, tiles, sheeps)
    for _, line in ipairs(tiles) do
        for _, tile in ipairs(line) do
            if tile:mouseIsHover(mx, my) and tile.isHabitedBy and love.mouse.isDown(1) then
                for _, sheep in ipairs(sheeps) do
                    if sheep.index == tile.isHabitedBy then
                        HUD.sheep = tile.isHabitedBy
                        return
                    end
                end
            end
        end
    end
end

return HUD
