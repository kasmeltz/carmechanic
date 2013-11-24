module('customerFactory', package.seeall)

function _M:new()
	local o = {}
	
	self.__index = self
	
	return setmetatable(o, self)
end

function blankTable(t)
	for k in pairs (t) do
		t [k] = nil
	end
end

function _M:initialize()
	local data = {}

	blankTable(data)	
	self._sexes = {}
	for line in love.filesystem.lines('data/sexes.dat') do
		table.insert(data, line)
	
		if #data == 5 then
			local o = {}			
			o.name = data[1]		
			o.stats = { tonumber(data[2]), tonumber(data[3]), tonumber(data[4]), tonumber(data[5]) }
			table.insert(self._sexes, o)
			blankTable(data)
		end
	end	
	
	blankTable(data)	
	self._ageRanges = {}
	for line in love.filesystem.lines('data/age_range.dat') do
		table.insert(data, line)
	
		if #data == 7 then
			local o = {}			
			o.range = { tonumber(data[1]), tonumber(data[2]) }
			o.frequency = tonumber(data[3])			
			o.stats = { tonumber(data[4]), tonumber(data[5]), tonumber(data[6]), tonumber(data[7]) }
			table.insert(self._ageRanges, o)
			blankTable(data)
		end
	end	
	
	blankTable(data)	
	self._vehicleAges = {}
	for line in love.filesystem.lines('data/vehicle_ages.dat') do
		table.insert(data, line)
	
		if #data == 3 then
			local o = {}			
			o.range = { tonumber(data[1]), tonumber(data[2]) }
			o.frequency = tonumber(data[3])			
			table.insert(self._vehicleAges, o)
			blankTable(data)
		end
	end	
	
	self._maleFirstNames = {}
	for line in love.filesystem.lines('data/first_names_m.dat') do
		table.insert(self._maleFirstNames, line)
	end	

	self._femaleFirstNames = {}
	for line in love.filesystem.lines('data/first_names_f.dat') do
		table.insert(self._femaleFirstNames, line)
	end	
	
	self._lastNames = {}
	for line in love.filesystem.lines('data/last_names.dat') do
		table.insert(self._lastNames, line)
	end
		
	blankTable(data)
	self._vehicleTypes = {}	
	for line in love.filesystem.lines('data/vehicles.dat') do
		table.insert(data, line)
		
		if #data == 3 then
			local o = {}			
			o.name = data[1]		
			o.firstYear = tonumber(data[2])
			o.frequency = tonumber(data[3])			
			table.insert(self._vehicleTypes, o)
			blankTable(data)
		end
	end
end


function _M:newCustomer(gameDate)
	local value	
	local o = {}

	local fr = 0	
	local s1l = 0
	local s1h = 100	
	local s2l = 0
	local s2h = 100
	local s3l = 0
	local s3h = 0
	
	o.readStats = {}

	-- last name
	value = math.random(1, #self._lastNames)
	o.lastName = self._lastNames[value]
	
	-- sex 
	value = math.random(1, #self._sexes)
	o.sex = self._sexes[value]

	s1l = o.sex.stats[1]
	s1h = o.sex.stats[2]
	s2l = o.sex.stats[3]
	s2h = o.sex.stats[4]
	
	-- first name
	if o.sex.name == 'Male' then
		value = math.random(1, #self._maleFirstNames)
		o.firstName = self._maleFirstNames[value]
	else
		value = math.random(1, #self._femaleFirstNames)
		o.firstName = self._femaleFirstNames[value]
	end
	
	-- age
	fr = 0
	for _, ar in ipairs(self._ageRanges) do
		fr = fr + ar.frequency
	end		
	
	value = math.random(1, fr)	
	
	local ageRange = nil
	
	fr = 0	
	for _, ar in ipairs(self._ageRanges) do
		fr = fr + ar.frequency
		if value <= fr then
			ageRange = ar
			break
		end
	end
	
	s1l = s1l + ageRange.stats[1]
	s1h = s1h + ageRange.stats[2]
	s2l = s2l + ageRange.stats[3]
	s2h = s2h + ageRange.stats[4]
	
	o.age = math.random(ageRange.range[1], ageRange.range[2])		
	o.ageRange = ageRange	
	
	-- stats
	s1l = math.max(s1l, 0)
	s1h = math.min(s1h, 100)
	
	s2l = math.max(s2l, 0)
	s2h = math.min(s2h, 100)
	
	local s1 = math.random(s1l, s1h)
	local s2 = math.random(s2l, s2h)
	
	o.realStats =
	{
		s1, s2
	}
	
	-- vehicle
	o.vehicle = {}
	
	-- vehicle age
	fr = 0
	for _, va in ipairs(self._vehicleAges) do
		fr = fr + va.frequency
	end		
	
	value = math.random(1, fr)	
	
	local vehicleAge = nil
	
	fr = 0	
	for _, va in ipairs(self._vehicleAges) do
		fr = fr + va.frequency
		if value <= fr then
			vehicleAge = va
			break
		end
	end
	
	value = math.random(vehicleAge.range[1], vehicleAge.range[2])
	o.vehicle.year = gameDate.year - value	
	
	-- vehicle type
	fr = 0
	local possibleTypes = {}
	for _, vt in ipairs(self._vehicleTypes) do
		if vt.firstYear <= o.vehicle.year then
			table.insert(possibleTypes, vt)
			fr = fr + vt.frequency
		end		
	end
		
	value = math.random(1, fr)
	
	fr = 0	
	for _, vt in ipairs(possibleTypes) do
		fr = fr + vt.frequency
		if value <= fr then
			o.vehicle.type = vt.name
			break
		end
	end
	
	return o
end

return _M