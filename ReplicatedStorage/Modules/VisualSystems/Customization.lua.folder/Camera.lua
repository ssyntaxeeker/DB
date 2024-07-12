-- Vesp_Ithon

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local module = {}
local Camera = workspace.CurrentCamera

local isServer = RunService:IsServer()

if isServer then warn("\"you have no reason to work wih cameras on the server\" - DylWithIt, probably") return end

-- TODO: Ask Dylan how should I sort out the cameras like camera priority and where to save attributes like "Busy"
-- Also ask how to save attributes like "Stunned"

local cameraCFrame = workspace.fakeCharacterCamera.CFrame
local charStand = workspace.fakeCharacterStand

module.enterCustomization = function()
	Camera = workspace.CurrentCamera
	Camera.CameraType = Enum.CameraType.Scriptable
	
	Camera.CFrame = CFrame.lookAt(
		cameraCFrame.Position + cameraCFrame.RightVector * 5,
		charStand.Position + charStand.CFrame.UpVector * 2)
	
	TweenService:Create(Camera, TweenInfo.new(1, Enum.EasingStyle.Cubic), {
		CFrame = CFrame.lookAt(
			cameraCFrame.Position,
			charStand.Position + charStand.CFrame.UpVector * 2 + charStand.CFrame.RightVector * 3)
	}):Play()
end

module.stopCustomization = function()
	Camera = workspace.CurrentCamera
	
	repeat
		task.wait()
		Camera.CameraType = Enum.CameraType.Custom
	until Camera.CameraType == Enum.CameraType.Custom
end

return module
