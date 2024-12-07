--[[
	사용 예시
	```lua
	local p
	p = PreloadModule.new("image", 121077772270923, function()
		print("====IM LOADED!!!!!==================")
		p = nil -- 포인터 참조 제거 (gc되도록)
	end)
	```
]]

--!strict
local preloader = {}
preloader.__index = preloader

local queue = {
	currentlyWorking = nil,
}

local ContentProvider = game:GetService("ContentProvider")

local _screenContainer = Instance.new("ScreenGui")
_screenContainer.Name, _screenContainer.ResetOnSpawn, _screenContainer.Archivable, _screenContainer.Parent 
	= "__preload_container__", false, false, game:GetService("Players").LocalPlayer.PlayerGui
local _soundContainer = Instance.new("SoundGroup")
_soundContainer.Name, _soundContainer.Volume, _soundContainer.Archivable, _soundContainer.Parent
	= "__preload_container__", 0, false, game:GetService("SoundService")

local function makeInstance(type:"audio"|"image", assetId:number)
	local instanceType = (type=="audio" and "Sound") or (type=="image" and "ImageLabel") or nil
	if instanceType == nil then error("not vaild type.") end
	
	local targetInstance = Instance.new(instanceType)
	if type=="audio" then
		targetInstance.Volume = 0
		targetInstance.SoundGroup = _soundContainer
		targetInstance.SoundId = "rbxassetid://"..assetId
	elseif type == "image" then
		targetInstance.Image = "rbxassetid://"..assetId
		targetInstance.Size = UDim2.new(0,0,0,0)
		targetInstance.Visible = true
		targetInstance.BorderSizePixel = 0
		--targetInstance.BackgroundTransparency = 1
		--targetInstance.ImageTransparency = 1
	end
	targetInstance.Parent = (type=="audio" and _soundContainer) or (type=="image" and _screenContainer)
	return targetInstance
end

local function step()
	local self = queue[1]
	--print("STEP DETECTED")
	if not queue.currentlyWorking and self then
		--print("STARTING TO STEP")
		queue.currentlyWorking = self
		ContentProvider:PreloadAsync({self.instance}, function()
			table.remove(queue, 1)
			self.loaded = true
			queue.currentlyWorking = nil
			--print("PRELOAD ENDED, STEPPING NEXT WORK")
			step()
		end)
	end
end

function preloader._registQueue(self, priority:number?)
	if priority then
		table.insert(queue, priority, self)
	else
		table.insert(queue, self)
	end
	step()
end

function preloader.wait(self)
	if not self.loaded then
		repeat task.wait() until self.loaded
	end
	--print("loaded completed ==================================")
	self:destroy()
end

function preloader.destroy(self)
	if self.awaitThread then
		task.cancel(self.awaitThread)
	end
	if self.instance then
		self.instance:Destroy()
	end
	table.clear(self)
end

function preloader.new(type:"audio"|"image", assetId:number, callback:()->()?, autoInit:false?) : self
	local this = {}
	this.instance = makeInstance(type, assetId)
	this.loaded = false
	
	setmetatable(this, preloader)
	
	if autoInit ~= false then
		this:_registQueue()
		this.awaitThread = task.spawn(function()
			this:wait()
			if callback then callback()	end
		end)
	end
	
	return this
end

type x = {
	instance : Instance,
	loaded : boolean,
	awaitThread:thread?,
}
type y = {
	__index : y,
	new:(type:"audio"|"image", assetId:number, callback:()->()?, autoInit:false?) -> self,
	wait:(self)->(),
	destroy:(self)->(),
	_registQueue:(self, priority:number?)->()
}

export type self = typeof(setmetatable({}::x, {}::y))

return preloader