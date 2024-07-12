-- Vesp_Ithon

-- TODO: Ask Dylan if this should be a global function cause it's useful in many scenarios,
-- and if so write the hookupFunctions for each system in their respective modules to make this module not
-- overwhelmed with "responsibility"

-- TODO: Ask Dylan if I should write the way I make tweens any other way

-- TODO: Ask Dylan if I should make a function because the part where I cache the tweens is repetitive

local TweenService = game:GetService("TweenService")

local CustomizationCharacterModule = require(script.Parent.Parent.Character)
local CustomizationCameraModule = require(script.Parent.Parent.Camera)

local module = {}
local tweensCache = {}
module.hookupFunctions = {}

module.rigUI = function(UI, Function, ...)
	if not module.hookupFunctions[Function] then warn(`No hookup function?? :megamind | {Function}`) return end
	
	local args = {...}
	
	for func, call in module.hookupFunctions[Function] do
		UI[func]:Connect(function()
			call(UI, args)
		end)
	end
end

module.hookupFunctions.MainButtonFrame = {
	MouseEnter = function(UI)
		if not tweensCache.MouseEnter then tweensCache.MouseEnter = {} end

		if not tweensCache.MouseEnter[UI] then	
			tweensCache.MouseEnter[UI] = TweenService:Create(
				UI, 
				TweenInfo.new(0.3, Enum.EasingStyle.Cubic),
				{Position = UI.Position + UDim2.fromOffset(-5, -2)})
		end
		
		tweensCache.MouseEnter[UI]:Play()
	end,

	MouseLeave = function(UI)
		if not tweensCache.MouseLeave then tweensCache.MouseLeave = {} end

		if not tweensCache.MouseLeave[UI] then	
			tweensCache.MouseLeave[UI] = TweenService:Create(
				UI, 
				TweenInfo.new(0.3, Enum.EasingStyle.Cubic),
				{Position = UI:GetAttribute("Origin")})
		end
		
		tweensCache.MouseLeave[UI]:Play()
	end,
}

module.hookupFunctions.MainButtonExec = {
	MouseButton1Down = function(UI)
		if not tweensCache.MouseButton1Down then tweensCache.MouseButton1Down = {} end

		if not tweensCache.MouseButton1Down[UI] then
			tweensCache.MouseButton1Down[UI] = TweenService:Create(
				UI, 
				TweenInfo.new(0.3, Enum.EasingStyle.Cubic),
				{Position = UI.Position + UDim2.fromOffset(3, -3)})
		end

		tweensCache.MouseButton1Down[UI]:Play()
	end,

	MouseButton1Up = function(UI, args)
		if not tweensCache.MouseButton1Up then tweensCache.MouseButton1Up = {} end
		
		if not tweensCache.MouseButton1Up[UI] then	
			tweensCache.MouseButton1Up[UI] = TweenService:Create(
				UI, 
				TweenInfo.new(0.3, Enum.EasingStyle.Cubic),
				{Position = UI:GetAttribute("Origin")})
		end
		
		tweensCache.MouseButton1Up[UI]:Play()
		
		local MainFrame = args[1]
		
		if MainFrame.Parent:GetAttribute("Available") == false then return end
		
		-- TODO: Once again, ask Dylan how to make all of these attributes be properly structured like Availability
		
		if MainFrame.Parent:GetAttribute("Busy") == true then
			if not tweensCache.CloseMainFrame then tweensCache.CloseMainFrame = {} end
			
			MainFrame.Parent:SetAttribute("Busy", false)
			MainFrame.Parent:SetAttribute("Available", false)
			
			if not tweensCache.CloseMainFrame[UI] then
				tweensCache.CloseMainFrame[UI] = TweenService:Create(
					MainFrame, 
					TweenInfo.new(0.7, Enum.EasingStyle.Cubic),
					{Position = UDim2.fromScale(-1.018, 0.027)})
			end 
			
			tweensCache.CloseMainFrame[UI]:Play()
			
			CustomizationCameraModule.stopCustomization()
			CustomizationCharacterModule.stopCustomization(game.Players.LocalPlayer)
			
			tweensCache.CloseMainFrame[UI].Completed:Wait()
			MainFrame.Parent:SetAttribute("Available", true)
		else
			if not tweensCache.OpenMainFrame then tweensCache.OpenMainFrame = {} end
			
			MainFrame.Parent:SetAttribute("Busy", true)
			MainFrame.Parent:SetAttribute("Available", false)
			
			if not tweensCache.OpenMainFrame[UI] then
				tweensCache.OpenMainFrame[UI] = TweenService:Create(
					MainFrame, 
					TweenInfo.new(0.7, Enum.EasingStyle.Cubic),
					{Position = UDim2.fromScale(0.018, 0.027)})
			end 

			tweensCache.OpenMainFrame[UI]:Play()
			
			CustomizationCameraModule.enterCustomization()
			CustomizationCharacterModule.enterCustomization(game.Players.LocalPlayer)
			
			tweensCache.OpenMainFrame[UI].Completed:Wait()
			MainFrame.Parent:SetAttribute("Available", true)
		end
	end,
}

module.hookupFunctions.Outfit = {
	MouseEnter = function(UI)

	end,

	MouseLeave = function(UI)

	end,
}

return module
