-- Mad-Experience
-------------------------------------Service-----------------------------------------------------
-------------------------------------------------------------------------------------------------

local lightning = game:GetService("Lighting")
local ts = game:GetService("TweenService")
local rs = game:GetService("RunService")
local soundservice = game:GetService("SoundService")

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local Camera = game.Workspace.CurrentCamera
Camera.FieldOfView = 65

local speed =  1 --배속 -- rs:IsStudio() and 10 or

--------------------------------------Docs-------------------------------------------------------
-------------------------------------------------------------------------------------------------
local gui = script:WaitForChild("Intro"):Clone()
gui.Parent = player.PlayerGui

local dissolve = gui:WaitForChild("Dissolve")

local logo = gui:WaitForChild("Logo")
local presents = gui:WaitForChild("Presents")
local presents_2 = gui:WaitForChild("Presents2")
local background = gui:WaitForChild("Background")

-- $ define
local conn1 : RBXScriptConnection | any
local conn2 : RBXScriptConnection | any
local conn3 : RBXScriptConnection | any
local IntroCameraMovement:RBXScriptConnection|nil

local intro_sound = soundservice:WaitForChild("Intro")
intro_sound.PlaybackSpeed *= speed

local flame = game.Workspace:WaitForChild("Intro"):WaitForChild("3_candle_low"):WaitForChild("Flame_1"):WaitForChild("PointLight")


--------------------------------------Lighting---------------------------------------------------
-------------------------------------------------------------------------------------------------
local color_correction = Instance.new("ColorCorrectionEffect")
color_correction.Name, color_correction.Parent, color_correction.Saturation, color_correction.TintColor, color_correction.Brightness
	= "_intro_", Camera, -1, Color3.fromRGB(11, 11, 11), -.05
-- 흑백 관련한건 Saturation 건들면 됨

local blur = require(script.Parent.BlurManager):new("IntroBlur")
blur:ChangeSize(6) -- 얜 blur size 바꾸는거고

--------------------------------------Info-------------------------------------------------------
-------------------------------------------------------------------------------------------------

local Logo_info = TweenInfo.new(20)
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

--------------------------------------Create-----------------------------------------------------
-------------------------------------------------------------------------------------------------

local phase1 = ts:Create(logo,Logo_info,{Size=UDim2.new(1,0,1,0)})
local zoomCam = ts:Create(Camera, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
	FieldOfView = 65
})
local tintBolder = ts:Create(color_correction, TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
	TintColor = Color3.fromRGB(190, 190, 190)	
})


---------------------------------------Main------------------------------------------------------
-------------------------------------------------------------------------------------------------

--0이 검은화면 46이 투명

local coreCall do
	local MAX_RETRIES = 8

	local StarterGui = game:GetService('StarterGui')
	local RunService = game:GetService('RunService')

	function coreCall(method, ...)
		local result = {}
		for retries = 1, MAX_RETRIES do
			result = {pcall(StarterGui[method], StarterGui, ...)}
			if result[1] then
				break
			end
			RunService.Stepped:Wait()
		end
		return unpack(result)
	end
end

coreCall('SetCore','ResetButtonCallback',false)

local phase1_cam = game.Workspace:WaitForChild("Intro"):WaitForChild("Cam")
local CameraSensitivity = 100
local IntroInitialOrient = phase1_cam.Orientation
local ViewportSize = Camera.ViewportSize
local function keepScriptable()
	Camera.CameraType = Enum.CameraType.Scriptable
end
rs:BindToRenderStep('KeepScriptable', Enum.RenderPriority.Camera.Value + 1, keepScriptable)


local function Dissolve(trans:"In"|"Out")
	if typeof(trans) ~= "string" then error("parameter must be String") end	
	if trans == "In" then
		for i=46, 0, -1 do
			dissolve[tostring(i)].Size = UDim2.new(1,0,1,0)
			task.wait(0.025/speed)
			dissolve[tostring(i)].Size = UDim2.new(0,0,0,0)
			if i == 0 then
				dissolve[tostring(i)].Size = UDim2.new(1,0,1,0)
			end
		end
	elseif trans == "Out" then
		for i=0, 46 do
			dissolve[tostring(i)].Size = UDim2.new(1,0,1,0)
			task.wait(0.025/speed)
			dissolve[tostring(i)].Size = UDim2.new(0,0,0,0)
		end
	else
		error("catched weirdo parameter, "..trans)
	end
end


function StartCameraMovement()
	IntroCameraMovement = rs.RenderStepped:Connect(function()
		local ViewportXOffset = ViewportSize.X/2 - mouse.X
		local ViewportYOffset = ViewportSize.Y/2 - mouse.Y
		ts:Create(phase1_cam, tweenInfo, {Orientation = IntroInitialOrient + Vector3.new(ViewportYOffset/CameraSensitivity,ViewportXOffset/CameraSensitivity,0)}):Play()
		Camera.CFrame = phase1_cam.CFrame
	end)
end

function StopCameraMovement()
	if IntroCameraMovement then
		IntroCameraMovement:Disconnect()
		IntroCameraMovement = nil
	end
end

---------------------------------------------------------------------

intro_sound:Play()

task.wait(3/speed)

local complete_size = UDim2.new(0.8, 0, 0.8, 0)
conn1 = rs.RenderStepped:Connect(function()
	logo.Size += UDim2.new(0.0001,0,0.0001,0)
end)

Dissolve("Out")

task.wait(2.5/speed)

Dissolve("In")

task.wait(.2/speed)

conn1:Disconnect()
conn1 = nil

task.wait(1/speed)

logo.Size = UDim2.new(0,0,0,0)

local button_gui = script:WaitForChild("Buttons"):Clone()
button_gui.Parent = player.PlayerGui
---------------------------------------------------------------------
--presents_2.Size = UDim2.new(0.73,0,0.288,0)
--conn2 = rs.RenderStepped:Connect(function()
--	presents_2.Position += UDim2.new(0.00003,0,0,0)
--end)
--Dissolve("Out")
--task.wait(2.5/speed)
--Dissolve("In")
--conn2:Disconnect()
--conn2 = nil
--task.wait(1.2/speed)
--presents_2.Size = UDim2.new(0,0,0,0)
--presents.Size = UDim2.new(0.426,0,0.137,0)
--conn3 = rs.RenderStepped:Connect(function()
--	presents.Position -= UDim2.new(0.000033,0,0,0)
--end)
--Dissolve("Out")
--Camera.CFrame = phase1_cam.CFrame
--task.wait(2.5/speed)
--Dissolve("In")
--conn3:Disconnect()
--conn3 = nil
--task.wait(2.5/speed)
--presents.Size = UDim2.new(0,0,0,0)
---------------------------------------------------------------------
StartCameraMovement()

background.Visible = false

Dissolve("Out")

gui.Enabled = false

tintBolder:Play()
intro_sound.PlaybackSpeed /= speed