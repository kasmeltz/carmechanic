module('customer', package.seeall)

_M.KNOWLEDGE_STAT = 1
_M.GULLIBLE_STAT = 2

-- returns a new customer object
function _M:new()
	local o = {}

	self.__index = self
	
	return setmetatable(o, self)
end

function _M:update(dt)
end

return _M