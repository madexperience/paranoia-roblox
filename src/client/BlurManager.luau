local Lightning = game:GetService("Lighting");
local TweenService = game:GetService("TweenService");
local HttpService = game:GetService("HttpService");
local RunService = game:GetService("RunService");

if not RunService:IsClient() then error("This module is for client-side. Do not run this on server-side.") end

local LemonSignal = require(script.Parent:WaitForChild("lemonsignal"))

--------------------------------------
local Blur = {}

--[[
	// Change Size Immediately
]]
function Blur.ChangeSize(self, size)
	self.Size = size
	self.Manager.signal.changeRequest:Fire()
end

--[[
	// Change Size Smoothly
]]
function Blur.TweenSize(self, size, tweenInfo:TweenInfo)
	self.Size = size
	self.Manager.signal.tweenRequest:Fire(tweenInfo or self.TweenInfo)
end

--[[
	// Destroy
]]
function Blur.Destroy(self)
	self.Manager.blurs[self.Id] = nil
	self.Manager = nil
end

--[[
	// Set Tween Info
]]
function Blur.SetDefaultTweenInfo(self, tweenInfo:TweenInfo)
	self.TweenInfo = tweenInfo
end

------------------------------------

local BlurManager = {}

--[[
	// Make Blur
]]
function BlurManager.new(self, name)
	local blur = {}
	
	blur.Size = 0
	blur.Manager = self
	blur.Id = HttpService:GenerateGUID(false)
	blur.TweenInfo = nil
	
	setmetatable(blur, {__index = Blur})
	
	self.blurs[blur.Id] = blur
	
	return blur
end

export type blur = {
	Id: string, -- 고유 식별자 (GUID)
	Size: number, -- Blur 크기
	Manager: manager, -- 해당 Blur 객체를 관리하는 BlurManager 객체
	TweenInfo: TweenInfo?,
	
	ChangeSize : (blur, number) -> (),
	TweenSize : (blur, number, TweenInfo?) -> (),
	Destroy : (blur) -> (),
}

export type manager = {
	blurObject: BlurEffect, -- BlurEffect 인스턴스
	signal: {
		changeRequest: LemonSignal.Signal, -- LemonSignal 인스턴스 (changeRequest 신호)
		tweenRequest: LemonSignal.Signal, -- LemonSignal 인스턴스 (tweenRequest 신호)
	},
	blurs: { [string]: blur }, -- blurs 테이블, 구체적인 타입은 명시되지 않음
	
	new : (manager, string) -> ()
}


return (function()
	local self = {}
	
	self.blurObject = Instance.new("BlurEffect")
	self.blurObject.Name = "__system_blur__"
	self.blurObject.Parent = Lightning
	self.blurObject.Size = 0
	
	self.signal = {}
	self.signal.changeRequest = LemonSignal.new()
	self.signal.tweenRequest = LemonSignal.new()
	
	self.blurs = {}
	
	---------------------------------------
	local function getBiggestSize()
		local maxSize = -99999
		for _, blur in self.blurs do
			if maxSize < blur.Size then
				maxSize = blur.Size
			end
		end
		return maxSize
	end
	
	self.signal.changeRequest:Connect(function()
		local size = getBiggestSize()
		self.blurObject.Size = size
	end)
	
	self.signal.tweenRequest:Connect(function(tweenInfo)
		local size = getBiggestSize()
		if self.blurObject.Size == size then
			return;
		end
		
		TweenService:Create(self.blurObject, tweenInfo or TweenInfo.new(1), {
			Size = size
		}):Play()
	end)
	
	setmetatable(self, {__index = BlurManager})
	
	return self
end)()