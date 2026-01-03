local Phenotype = {}
local Calculator = require("libs.calculator")
--[[
List all attributes depending on a genome and which can be transmitted
to child:
-- non implemented attributes:
woolColor ?
]]
local function isPair(number)
    return number % 2 == 0
end
function Phenotype.setSex(entity, genome)
    local sex = entity:getSex() == "Male" and 1 or 2
    local number
    repeat
        number = love.math.random(1, 15)
    until number % 2 == sex % 2
    local sexArray = Calculator.toBinary(number, 4)
    genome:setSex(sexArray)
end

function Phenotype.setGestationDuration(entity, genome)
    local duration = entity:getGestationDuration()
    local durationarray = Calculator.toBinary(duration, 4)
    genome:setGestationDuration(durationarray)
end
function Phenotype.setWoolColor(entity,genome)
    
local color=entity:getWoolColor()
local colorArray=Calculator.toBinary(color,4)
genome:setWoolColor(colorArray)
end
function Phenotype.setDuplicationSeasons(entity, genome)
    local seasons = { "Spring", "Summer", "Autumn", "Winter" }
    local seasonArray = { 0, 0, 0, 0 }
    local lovedSeasons = entity:getDuplicationSeasons()
    for i, value in ipairs(seasons) do
        for _, lovedSeason in ipairs(lovedSeasons) do
            if value == lovedSeason then
                seasonArray[i] = 1
                break
            end
        end
    end
    genome:setDuplicationSeasons(seasonArray)
end

function Phenotype.setMaxAgeMonths(entity, genome)
    --60 in prevision for futur animal with bigger longevity
    --so the minimum is 5 years and the maximum 75 years
    local maxAgeMonths = entity:getMaxAgeMonths() / 60
    local maxAgeArray = Calculator.toBinary(maxAgeMonths, 4)
    genome:setMaxAgeMonths(maxAgeArray)
end

function Phenotype.setCircadian(entity, genome)
    local circadian = entity:getCircadian() == "Diurnal" and 1 or 2
    local number
    repeat
        number = love.math.random(1, 15)
    until number % 2 == circadian % 2
    local circadianArray = Calculator.toBinary(number, 4)
    genome:setCircadian(circadianArray)
end

function Phenotype.setVisionRange(entity, genome)
    local visionrange = entity:getVisionRange()
    local rangeArray = Calculator.toBinary(visionrange, 4)
    genome:setVisionRange(rangeArray)
end

function Phenotype.setPhenotype(entity, genome)
    Phenotype.setSex(entity, genome)
    Phenotype.setCircadian(entity, genome)
    Phenotype.setDuplicationSeasons(entity, genome)
    Phenotype.setGestationDuration(entity, genome)
    Phenotype.setMaxAgeMonths(entity, genome)
    Phenotype.setVisionRange(entity, genome)
    Phenotype.setWoolColor(entity,genome)
end

function Phenotype.procreate(mother, father, newEntity)
    local sex = (Calculator.returnValue(mother.genome:getSex())+
    Calculator.returnValue(father.genome:getSex())+love.math.random(1,15))%16
    local circadian = Calculator.jonction(mother.genome:getCircadian(), father.genome:getCircadian())
    local duplicationSeasons = Calculator.jonction(mother.genome:getDuplicationSeasons(),
        father.genome:getDuplicationSeasons())
    local gestationDuration = Calculator.jonction(mother.genome:getGestationDuration(),
        father.genome:getGestationDuration())
    local maxAgeMonths = Calculator.jonction(mother.genome:getMaxAgeMonths(), father.genome:getMaxAgeMonths())
    local visionRange = Calculator.jonction(mother.genome:getVisionRange(), father.genome:getVisionRange())
    local woolColor=Calculator.jonction(mother.genome:getWoolColor(),father.genome:getWoolColor())
    --apply cross genomes to newEntity's genome
    local sexArray=Calculator.toBinary(sex,4)
    local genome = newEntity:getGenome()
    genome:setSex(sexArray)
    genome:setCircadian(circadian)
    genome:setDuplicationSeasons(duplicationSeasons)
    genome:setGestationDuration(gestationDuration)
    genome:setMaxAgeMonths(maxAgeMonths)
    genome:setVisionRange(visionRange)
    genome:setWoolColor(woolColor)
    Phenotype.mutate(genome,newEntity)
end

function Phenotype.decodeGenomeToEntity(genome, entity)
    --translate genome to attributes
    local sexValue = Calculator.returnValue(genome:getSex()) % 2 == 0 and "Female" or "Male"
    local circadianValue = Calculator.returnValue(genome:getCircadian()) % 2 == 0 and "Nocturnal" or "Diurnal"
    local seasons = { "Spring", "Summer", "Autumn", "Winter" }
    local seasonArray = {}
    local genomeSeasons = genome:getDuplicationSeasons()
        for i=1,#genomeSeasons do
            if genomeSeasons[i] == 1 then
                table.insert(seasonArray, seasons[i])
            end
        end
    
    local gestationDurationValue = Calculator.returnValue(genome:getGestationDuration())
    local maxAgeMonthsValue = Calculator.returnValue(genome:getMaxAgeMonths()) * 60
    local visionRangeValue = Calculator.returnValue(genome:getVisionRange())
    local woolColor = Calculator.returnValue(genome:getWoolColor())
    --then apply them to newEntity
    entity:setSex(sexValue)
    entity:setCircadian(circadianValue)
    entity:setDuplicationSeasons(seasonArray)
    entity:setGestationDuration(gestationDurationValue)
    entity:setMaxAgeMonths(maxAgeMonthsValue)
    entity:setVisionRange(visionRangeValue)
    entity:setWoolColor(woolColor)
end

function Phenotype.mutate(genome, entity)
    local random = love.math.random()
    if random <= 0.01 then
        local getters = { function() return genome:getSex() end,
            function() return genome:getGestationDuration() end,
            function() return genome:getDuplicationSeasons() end,
            function() return genome:getMaxAgeMonths() end,
            function() return genome:getCircadian() end,
            function() return genome:getVisionRange() end }
        local setters = { function(val) genome:setSex(val) end,
            function(val) genome:setGestationDuration(val) end,
            function(val) genome:setDuplicationSeasons(val) end,
            function(val) genome:setMaxAgeMonths(val) end,
            function(val) genome:setCircadian(val) end,
            function(val) genome:setVisionRange(val) end }

        local index = love.math.random(1, #getters)

        local geneChosen = getters[index]()
        local newGene = Calculator.mutate(geneChosen)
        local newGeneValue=Calculator.returnValue(newGene)
        --check if the entity change it's sex and if it's pregnant!
        if index==1 and newGeneValue%2 ~= Calculator.returnValue(geneChosen)%2 and entity.reproduction.pregnant then
            entity.reproduction.pregnant=false
        end
        setters[index](newGene)
        Phenotype.decodeGenomeToEntity(genome, entity)
        local geneNames={"Sex", "Gestation","Season", "MaxAge","Circadian", "VisionRange"}
        local text = string.format("Entity #%i has mutated %s gene [%s] became [%s]",
            entity:getIndex(), geneNames[index], table.concat(geneChosen, ","), table.concat(newGene, ","))
        print(text)
        genome:setMutated()
    end
end
function Phenotype.checkIfGeneIsLethal(genome)
            local getters = { function() return genome:getSex() end,
            function() return genome:getGestationDuration() end,
            function() return genome:getDuplicationSeasons() end,
            function() return genome:getMaxAgeMonths() end,
            function() return genome:getCircadian() end,
            function() return genome:getVisionRange() end }
            for _, getter in ipairs(getters)do
                local geneTested=getter()
                local value=Calculator.returnValue(geneTested)
                if value==0 then
                    return true
                end
            end
            return false
end
return Phenotype
