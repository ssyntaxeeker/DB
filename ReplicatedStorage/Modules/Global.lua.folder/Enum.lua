-- Vesp_Ithon

local Util = require(script.Parent.Util)

return function(t, list, lut)
	list = if list then list else true
	lut = if lut then lut else true

	return setmetatable(Util.arrayToDict(t), {
		__index = {
			list = if list then t else nil,
			lut = if lut then Util.arrayToLUT(t) else nil
		}
	})
end
