-- Vesp_Ithon

-- TODO: Rewrite DefaultData as a function I can call from other places due to Dylan wanting this to be SOLID or sum

local module = {}
module.Profiles = {} 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DataTag = script.DataTag
local DataVersion = 2

local IsServer = RunService:IsServer()
local isStudio = RunService:IsStudio()

if not IsServer then warn("\"you have no reason to load profiles on the client\" - DylWithIt") return end

if isStudio then DataTag.Value = "MOCK"..DataVersion else DataTag.Value ..= DataVersion end

local ProfileService = require(script.ProfileService)

local DefaultData = {
	Customization = {
		Outfit = 1,
		Hair = 1,
		Face = 1,
		SkinColor = "255,255,255",
		EyeColor = "1,1,1",
		Race = "Human",
		Gender = "Male",
	},
	Stats = {},
	Levelling = {},
	Economy = {}
}

local ProfileStore = ProfileService.GetProfileStore(`PlayerData_{DataTag.Value}`, DefaultData)

module.new = function(player : Player)
	local uuid = player.UserId
	
	local playerProfile = ProfileStore:LoadProfileAsync("Player_"..uuid)
	
	if playerProfile == nil then player:Kick("Data could not load, please rejoin") return end 
	
	playerProfile:AddUserId(uuid) 
	playerProfile:Reconcile() 

	playerProfile:ListenToRelease(function()
		module.Profiles[player] = nil
		player:Kick()
	end)
	
	if not player:IsDescendantOf(Players) then
		playerProfile:Release()
		return
	end
	
	module.Profiles[player] = playerProfile
end

for _, player in Players:GetPlayers() do
	module.new(player)
end

Players.PlayerAdded:Connect(module.new)

Players.PlayerRemoving:Connect(function(player)
	local profile = module.Profiles[player]

	if profile then
		profile:Release()
	end
end)


return module
