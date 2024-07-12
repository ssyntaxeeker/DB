-- Vesp_Ithon
-- "old one is old and wife one is fluffy and fairly healthy but keeps getting into scraps outside" - DylWithIt 2024

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local CustomizationRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Customization")
local CustomizationAssets = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Customization")

local isServer = RunService:IsServer()

local CustomizationDataModule = isServer and require(script.Parent.Data)
local GlobalModule = require(Modules.Global)

local module = {}

local fakeCharacterIdleAnimation = script.fakeCharacterIdle

local playerData = isServer and CustomizationDataModule.Data

local function changeClothes(character, outfit, needBra)
	if character.Vanity:FindFirstChild("Outfit") then
		character.Vanity.Outfit:Destroy()	
	end
	
	if not character.Vanity:FindFirstChild("Bra") and needBra then
		local Bra = CustomizationAssets:WaitForChild("Bra"):Clone()
		Bra.CFrame = character.Torso.CFrame
		
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = character.Torso
		weld.Part1 = Bra
		weld.Parent = Bra
		
		Bra.Parent = character.Vanity
	end
	
	if not outfit then return end
	
	local body = outfit:Clone()
	
	for _, bodyPart in body:GetChildren() do
		local characterPart = character[bodyPart.Name]
		
		bodyPart.CFrame = characterPart.CFrame
		bodyPart.Transparency = 1
		
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = characterPart
		weld.Part1 = bodyPart
		weld.Parent = bodyPart
	end
	
	body.Name = "Outfit"
	body.Parent = character.Vanity
end

local function changeHair(character, hair)
	if character.Vanity:FindFirstChild("BaseHair") then
		character.Vanity.BaseHair:Destroy()
	end
	
	if not hair then return end
	
	for _, accessory in character:GetChildren() do
		if not accessory:IsA("Accessory") then continue end
		
		accessory:Destroy()
	end
	
	local charHair = hair.Hair:Clone()
	charHair.Name = "BaseHair"
	charHair.Parent = character.Vanity
	character.Humanoid:AddAccessory(charHair)
	
	charHair.Handle.CFrame = character.Head.CFrame * CFrame.new(charHair.AttachmentPoint.Position)
	
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = character.Head
	weld.Part1 = charHair.Handle
	weld.Parent = charHair
	
end

local function changeFace(character, face)
	for _, decal in character.Head:GetChildren() do
		if not decal:IsA("Decal") then continue end
		
		decal:Destroy()
	end
	
	character.Head.Reflectance = 0.02
	
	for _, decal in face:GetChildren() do
		decal:Clone().Parent = character.Head
	end
end

local function changeSkinColor(character, color)
	for _, part in character:GetChildren() do
		if not part:IsA("BasePart") then continue end
		
		part.Color = color
	end
end

local function changeEyeColor(character, color)
	local Head = character.Head
	
	if not Head:FindFirstChild("Pupils") then return end
	
	Head.Pupils.Color3 = color
end

local function getProperties(customizationInfo)
	local Properties = {}
	
	local Race = customizationInfo.Race
	local Gender = customizationInfo.Gender
	
	local AssetsFolder = CustomizationAssets[Race][Gender]
	
	Properties.Outfit = CustomizationAssets.Outfits[customizationInfo.Outfit]
	Properties.Hair = AssetsFolder.Hairs[customizationInfo.Hair]
	Properties.Face = AssetsFolder.Faces[customizationInfo.Face]
	
	Properties.SkinColor = Color3.new(unpack(customizationInfo.SkinColor:split(",")))
	Properties.EyeColor = Color3.new(unpack(customizationInfo.EyeColor:split(",")))
	
	return Properties
end

local function updateCharacter(character, customizationInfo)
	local Properties = getProperties(customizationInfo)
		
	changeClothes(character, Properties.Outfit, customizationInfo.Gender == "Female")
	changeHair(character, Properties.Hair)
	changeFace(character, Properties.Face)
	
	changeSkinColor(character, Properties.SkinColor)
	changeEyeColor(character, Properties.EyeColor)
end

local function getCustomizationInfo(player)
	local dataNeeded = {
		"Outfit",
		"Hair", "Face",
		"EyeColor", "SkinColor",
		"Race",	"Gender",
	}
	
	local dataRetrieved = {}
	
	for _, data in dataNeeded do
		if isServer then
			dataRetrieved[data] = tostring(playerData[player][data])
		else
			dataRetrieved[data] = tostring(player:GetAttribute(data))
		end
	end
	
	return dataRetrieved
end

module.getCustomizationInfo = getCustomizationInfo

module.enterCustomization = function(player)
	local fakeCharacter = CustomizationAssets.fakeCharacter:Clone()
	fakeCharacter.Name = `fakeCharacter_{player.Name}`
	fakeCharacter.HumanoidRootPart.CFrame = workspace.fakeCharacterStand.CFrame * CFrame.new(0, 5, 0)
	fakeCharacter.Parent = workspace

	local customizationInfo = getCustomizationInfo(player)

	updateCharacter(fakeCharacter, customizationInfo)
	
	local idleTrack = fakeCharacter.Humanoid.Animator:LoadAnimation(fakeCharacterIdleAnimation)
	idleTrack:Play()
end

module.stopCustomization = function(player)
	local fakeCharacter = workspace:FindFirstChild(`fakeCharacter_{player}`)
	fakeCharacter:Destroy()
end

for _, player in Players:GetPlayers() do
	player.CharacterAdded:Connect(function(character)
		repeat task.wait(1) until isServer and playerData[player] or player:GetAttribute("Ready")

		local customizationInfo = getCustomizationInfo(player)

		updateCharacter(character, customizationInfo)
	end)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		repeat task.wait(1) until isServer and playerData[player] or player:GetAttribute("Ready")
		
		local customizationInfo = getCustomizationInfo(player)
		
		updateCharacter(character, customizationInfo)
	end)
end)

return module
