-- Vesp_Ithon

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local CustomizationRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Customization")
local CustomizationAssets = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Customization")

local DataFolder = Modules:WaitForChild("Data")
local CustomizationSync = CustomizationRemotes:WaitForChild("CustomizationSync")
local CustomizationAssets = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Customization")

local PlayerDataModule = require(DataFolder:WaitForChild("PlayerData"))
local GlobalModule = require(Modules:WaitForChild("Global"))

local module = {}
module.Data = {}

local CustomizationData = {}

local isServer = RunService:IsServer()

if not isServer then return end

local function getRandomIndex(t)
	return math.random(1, #t)
end

local function getRandomValue(t)
	return t[math.random(1, #t)]
end

local constrainFunctions = {
	Outfit = function(playerData)
		local Outfits = CustomizationAssets.Outfits:GetChildren()
		
		return playerData.Outfit > #Outfits and getRandomIndex(Outfits) or playerData.Outfit 
	end,
	
	Face = function(playerData)
		local CustomizationAssets = CustomizationAssets[playerData.Race]
		local Faces = CustomizationAssets[playerData.Gender].Faces:GetChildren()
		
		return playerData.Face > #Faces and getRandomIndex(Faces) or playerData.Face
	end,
	
	Hair = function(playerData)
		local CustomizationAssets = CustomizationAssets[playerData.Race]
		local Hairs = CustomizationAssets[playerData.Gender].Hairs:GetChildren()

		return playerData.Hair > #Hairs and getRandomIndex(Hairs) or playerData.Hair
	end,
	
	EyeColor = function(playerData)
		local eyeColors = {}
		
		local CustomizationAssets = CustomizationAssets[playerData.Race]
		
		for _, eyeColor in CustomizationAssets.EyeColors:GetChildren() do
			table.insert(eyeColors, (tostring(eyeColor.Value):gsub(" ", ""))) 
		end
		
		return table.find(eyeColors, playerData.EyeColor) and playerData.EyeColor or getRandomValue(eyeColors)
	end,
	
	SkinColor = function(playerData)
		local skinColors = {}
		
		local CustomizationAssets = CustomizationAssets[playerData.Race]
		
		for _, skinColor in CustomizationAssets.SkinColors:GetChildren() do
			table.insert(skinColors, (tostring(skinColor.Value):gsub(" ", ""))) 
		end

		return table.find(skinColors, playerData.SkinColor) and playerData.SkinColor or getRandomValue(skinColors)
	end,
}

local constrainEnum 

local function constrainData(player)
	local playerData = CustomizationData[player]
	
	if not constrainEnum then
		local enumTable = {}

		for name, _ in playerData do
			table.insert(enumTable, name)
		end

		constrainEnum = GlobalModule.Enum(enumTable)
	end

	for _, dataName in constrainEnum.list do
		if not constrainFunctions[dataName] then warn(`E- Erm no function? :megamind: | {dataName}`) continue end
		
		playerData[dataName] = constrainFunctions[dataName](playerData)
	end
end

local function setShadowTable(player)
	local metaTable = {}
	local playerData = CustomizationData[player]
	
	metaTable.__index = function(_, index)
		rawget(playerData, index)
	end
	
	metaTable.__newindex = function(_, index, value)
		playerData[index] = value
		player:SetAttribute(index, value)
	end

	setmetatable(module.Data, metaTable)
end

local function loadPlayer(player)
	repeat task.wait(1) until PlayerDataModule.Profiles[player]

	local playerProfile = PlayerDataModule.Profiles[player]
	
	CustomizationData[player] = playerProfile.Data.Customization
	module.Data[player] = CustomizationData[player]

	for name, value in CustomizationData[player] do
		player:SetAttribute(name, value)
	end
	
	constrainData(player)
	setShadowTable(player, CustomizationData[player])
	
	player:SetAttribute("Ready", true)
end

if isServer then
	for _, player in Players:GetPlayers() do
		loadPlayer(player)
	end
	
	Players.PlayerAdded:Connect(function(player)
		loadPlayer(player)
	end)
	
	CustomizationSync.OnServerEvent:Connect(function(player, data) -- TODO: Add some sanity checks
		CustomizationData[player] = data 
	end)
end


return module
