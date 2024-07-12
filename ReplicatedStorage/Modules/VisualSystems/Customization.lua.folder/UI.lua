-- Vesp_Ithon

-- TODO: Revamp the design of the UI, I mean please it's a Dragon Ball game not 1968
-- TODO: Ask Dylan how to make a good camera manipulation module 

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local CustomizationAssets = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Customization")

local GlobalModule = require(Modules:WaitForChild("Global"))
local HookupModule = require(script.Hookups)

local player = game.Players.LocalPlayer

--local CustomizationCharacterModule = require(script.Parent.Character) -- TODO: Ask if this is, overall a good idea

local module = {}

local defaultPositions = {
	MainButton = UDim2.fromScale(0.913, 0.869),
}
local ViewportTemplate = script.ViewportTemplate

local tweenFunctions = { -- TODO: Ask Dylan if I should cache this or something cause I'm making tweens every charAdd
	Generic = function(Frame, Position, t) -- I know I'm supposed to do it on a per frame basis but this is just simpler
		t = t or 0.7
		local Tween = TweenService:Create(Frame, TweenInfo.new(t, Enum.EasingStyle.Cubic), {Position = Position})
		Tween:Play()
		
		return Tween
	end,
	
	--[[MainButton = function(Button, Position)
		local Tween = TweenService:Create(Button, TweenInfo.new(0.7, Enum.EasingStyle.Cubic), {Position = Position})
		Tween:Play()
	end,
	
	MainFrame = function(Button, Position)
		local Tween = TweenService:Create(Button, TweenInfo.new(0.7, Enum.EasingStyle.Cubic), {Position = Position})
		Tween:Play()
	end,--]]
}

local viewportFrames = {
	Hair = function(Hairs)
		
	end,
}

local function setupViewportFrames(SelectionFrame)
	local HairGrid = SelectionFrame:WaitForChild("HairGrid")
	local HairGridCellSize = HairGrid.UIGridLayout.CellSize
	
	local dataNeeded = {
		"Outfit",
		"Hair", "Face",
		"EyeColor", "SkinColor",
		"Race",	"Gender",
	}
	
	local customizationData = {}
	
	for _,data in dataNeeded do
		customizationData[data] = player:GetAttribute(data)
	end
	
	local Outfits = CustomizationAssets:WaitForChild("Outfits")	
	
	local playerSpecificAssets = 
		CustomizationAssets:WaitForChild(customizationData.Race):WaitForChild(customizationData.Gender)
	
	local Faces = playerSpecificAssets.Faces:GetChildren()
	local Hairs = playerSpecificAssets.Hairs:GetChildren()
	
	HairGrid.CanvasSize = UDim2.fromOffset(HairGridCellSize.X.Offset * #Hairs, HairGridCellSize.Y.Offset)
	
	for _, hair in Hairs:GetChildren() do
		
	end
end

local function load(player)
	local PlayerGui = player.PlayerGui
	local CustomizationGUI = PlayerGui:WaitForChild("Customization")
	
	local startFrames = {
		"MainButton",
		"MainFrame"
	} 
	
	local framesEnum = GlobalModule.Enum(startFrames)
	
	for _, UI in CustomizationGUI:GetDescendants() do
		local cln = UI.ClassName
		
		if not string.find(cln, "Label") and not string.find(cln, "Button")
			and not string.find(cln, "Frame") and not string.find(cln, "Box") then
			
			continue
		end
		
		UI:SetAttribute("Origin", UI.Position)
	end
	
	for i, frame in framesEnum.list do
		local frameGUI = CustomizationGUI:FindFirstChild(frame)
		
		local defaultPos = defaultPositions[frame]
		
		if not defaultPos then 
			frameGUI.Position += UDim2.fromScale(frameGUI.Position.X.Scale > 0.5 and 1 or -1, 0) 
			continue 
		end
		
		frameGUI.Position += UDim2.fromScale(defaultPos.X.Scale > 0.5 and 1 or -1, 0)
		
		local tween = tweenFunctions.Generic(frameGUI, defaultPos)
		
		--[[if i == #framesEnum.list then -- TODO: Ask Dylan for a better way to wait so that it doesn't mess
			-- with the positions when rigging the UI
			tween.Completed:Wait()
		end--]]
	end
	
	setupViewportFrames(CustomizationGUI:WaitForChild("MainFrame2"))
	
	HookupModule.rigUI(CustomizationGUI:WaitForChild("MainButton"), "MainButtonFrame")
	
	local MainFrame = CustomizationGUI:WaitForChild("MainFrame")
	
	HookupModule.rigUI(CustomizationGUI:WaitForChild("MainButton").Exec, "MainButtonExec", MainFrame)
end

for _, player in Players:GetPlayers() do
	local character = player.Character or player.CharacterAdded:Wait()
	
	load(player)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		load(player)
	end)
end)

return module
