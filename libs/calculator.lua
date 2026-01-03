local Calculator={}
Calculator.array={}
Calculator.text=""
--convert to bool in order to do and /or test
local function convertToBin(array)
    local response={}
    for x, value in ipairs(array) do
        if value==1 then
            response[x]=true
        else
            response[x]=false
        end
    end
    return response
end
--convert a int number to binary
function Calculator.toBinary(number,length)
    local array={}
    for x=length, 1, -1 do
        array[x]=0
    end
    local rest=0
    local quotient=number
    local index=#array
    while quotient~=0 do
        rest=quotient%2
        quotient=(quotient-rest)/2
        array[index]=rest
        index=index-1
    end
    return array
end


function Calculator.intersect(array1,array2)
    Calculator.array={}
    local bin1=convertToBin(array1:getArray())
    local bin2=convertToBin(array2:getArray())
    local newArray={}
    for x=1,#bin1 do
        newArray[x]=bin1[x] and bin2[x]
    end
    for x, value in ipairs(newArray) do
        if value==true then
            Calculator.array[x]=1
        else
            Calculator.array[x]=0
        end
    end
    return Calculator.array
end

function Calculator.jonction(array1,array2)
    Calculator.array={}
    local bin1=convertToBin(array1)
    local bin2=convertToBin(array2)
    local newArray={}
    --math.random to make a random transmission
    for x=1,#bin1 do
        newArray[x]=love.math.random(1,2) < 2 and bin1[x] or bin2[x]
    end
    for x, value in ipairs(newArray) do
        if value==true then
            Calculator.array[x]=1
        else
            Calculator.array[x]=0
        end
    end
    return Calculator.array
end
function Calculator.add(array1,array2)
    local value=array1:getValue()+array2:getValue()
    Calculator.array=Calculator.toBinary(value,array1:getLength())
    return Calculator.array
end
function Calculator.mutate(gene)
    --need to do a copy in order to don't affect the real state of original array
    local newArray={}
    for _, value in ipairs(gene)do
        table.insert(newArray,value)
    end
    --now we can modify a random value in our array
    local index=love.math.random(1,#gene)

    local allele=newArray[index]==1 and 0 or 1
    --then place the mutated 'gene' into our array
    newArray[index]=allele

    return newArray
end
function  Calculator.returnValue(gene)
    local sum=0
    local length=#gene
    for x=1, length do
        sum=sum+gene[x]*(2^(length-x))
    end
    return sum
end
return Calculator