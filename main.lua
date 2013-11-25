require 'table_ext'
require 'string_ext'

local customerFactory = require 'customer_factory'
local vehicleFactory = require 'vehicle_factory'
local problemFactory = require 'problem_factory'

-------------------------------------------------------------------------------
-- customers
local KNOWLEDGE_STAT = 1
local GULLIBLE_STAT = 2

local pastCustomers = {}
local currentCustomers = {}
local scheduledCustomers = {}

-------------------------------------------------------------------------------
-- skillls
local READING_PEOPLE = 1

local skillList =
{
	{ 
		name = 'Reading People', levels = 
		{
			{ 10, 20, 30, 40, 50, 65, 80 },
			{ 90, 80, 70, 60, 50, 40, 30 }
		}	
	}		
}

local skillLevels =
{
	5
}

function getSkill(skill, subSkill)
	local skillLevel = skillLevels[skill]
	return skillList[skill].levels[subSkill][skillLevel]
end

function readingPeopleAccuracy()
	local maxAccuracy = getSkill(READING_PEOPLE, 1)
	return maxAccuracy - 10, maxAccuracy
end

function readingPeopleMaxDifference()
	return getSkill(READING_PEOPLE, 2)
end


function readPerson(person)
	local min, max = readingPeopleAccuracy()
	local maxDifference = readingPeopleMaxDifference() 
	
	local accuracy = math.random(min, max)
	local accurateScore = math.random(1, 100)
		
	for i = 1, #person.realStats do
		if (accurateScore <= accuracy) then
			person.readStats[i] = person.realStats[i]
		else	
			local differentScore = -maxDifference + 
				math.random(1, maxDifference * 2)
				
			local v = math.floor(person.realStats[i] + 
				differentScore)		
			v = math.max(v, 0)
			v = math.min(v, 100)
			
			person.readStats[i] = v
		end
	end
end

-------------------------------------------------------------------------------
-- game world time
local gameSeconds
local gameDate
local oldGameDate

local timeRates = 
{
	{ name = 'slow', timeFactor = 0.5 },
	{ name = 'regular', timeFactor = 1 },
	{ name = 'fast', timeFactor = 10 },
	{ name = 'faster', timeFactor = 1000 },
	{ name = 'fastest', timeFactor = 10000 }
}

local holidays = 
{
	{ 
		name = 'Christmas', month = 12, day = 25 
	},
	{
		name = 'New Years Day', month = 1, day = 1
	}
}

local currentTimeRate = 2

-------------------------------------------------------------------------------
local currentCustomer

function love.load()

	gameSeconds = os.time { year = 2013, month = 1, day = 2 }	
	oldGameDate = os.date('*t', gameSeconds)	

	customerFactory.initialize()
	vehicleFactory.initialize()
	problemFactory.initialize()
end

function love.update(dt)
	gameSeconds = gameSeconds + dt * timeRates[currentTimeRate].timeFactor
	
	gameDate = os.date('*t', gameSeconds)		
	
	-- the day has advanced
	if(oldGameDate.day ~= gameDate.day) then
	end
	
	-- the month has advanced
	if(oldGameDate.month ~= gameDate.month) then
	end
	
	-- the year has advanced
	if (oldGameDate.year ~= gameDate.year) then
	end
	
	oldGameDate = gameDate	
end

function love.draw()
	love.graphics.print(timeRates[currentTimeRate].name, 0, 0)
	love.graphics.print(os.date('%B %d, %Y', gameSeconds), 0, 25)
	love.graphics.print(os.date('%I:%M:%S %p', gameSeconds), 0, 50)
	
	if currentCustomer then
		love.graphics.print(currentCustomer.firstName .. ' ' .. currentCustomer.lastName, 0, 150)
		love.graphics.print(currentCustomer.ageRange.range[1] .. ' - ' .. currentCustomer.ageRange.range[2] .. ' ( ' .. currentCustomer.age .. ' )', 0, 175)
		love.graphics.print(currentCustomer.ethnicity.name, 0, 200)
		
		local sx = 0
		for k, v in pairs(currentCustomer.face) do
			love.graphics.print(k .. ': ' .. v, sx, 225)
			sx = sx + 125
		end
		
		love.graphics.print('Knowledge: ' .. 
			currentCustomer.readStats[KNOWLEDGE_STAT], 0, 250)
		
		love.graphics.print('Gullability: ' .. 
			currentCustomer.readStats[GULLIBLE_STAT], 0, 275)

		local min, max = readingPeopleAccuracy()
	
		love.graphics.print('There is a ' .. min ..
			' - ' .. max .. '% chance your readings are accurate', 0, 300)	

		love.graphics.print('An inaccurate reading will be within ' .. 
			readingPeopleMaxDifference() .. ' points of the real value', 0, 325)
			
			love.graphics.print('Knowledge: ' .. 
			currentCustomer.realStats[KNOWLEDGE_STAT], 0, 400)
		
		love.graphics.print('Gullability: ' .. 
			currentCustomer.realStats[GULLIBLE_STAT], 0, 425)
			
		love.graphics.print(currentCustomer.vehicle.year .. ' ' .. 
			currentCustomer.vehicle.type .. ' ' .. 
			currentCustomer.vehicle.kms .. ' kms', 0, 500)	

		local sy = 520
		for _, v in ipairs(currentCustomer.vehicle.problems) do
			love.graphics.print(v.name, 0,sy)	
			sy = sy + 20
		end
		
	
	end
end

function love.keyreleased(key)
	if key == 'right' then
		currentTimeRate = currentTimeRate + 1
		if currentTimeRate > #timeRates then
			currentTimeRate = #timeRates
		end
	elseif key == 'left' then
		currentTimeRate = currentTimeRate -1
		if currentTimeRate < 1 then
			currentTimeRate = 1
		end
	end	
	
	if key == 'a' then
		currentCustomer = customerFactory.newCustomer(gameDate)
		readPerson(currentCustomer)
	end
end