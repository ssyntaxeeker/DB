-- Vesp_Ithon

local module = {}

module.arrayToDict = function(array)
	local dict = {}
	
	for _, v in array do
		dict[v] = v
	end

	return dict
end

module.arrayToLUT = function(array)
	local dict = {}

	for _, v in array do
		dict[v] = v
	end

	return dict
end

return module
