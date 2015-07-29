--[[
		Filename: TenFootInterface.lua
		Written by: jeditkacheff
		Version 1.0
		Description: Setups up some special UI for ROBLOX TV gaming
--]]
-------------- CONSTANTS --------------
local HEALTH_GREEN_COLOR = Color3.new(27/255, 252/255, 107/255)

-------------- SERVICES --------------
local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

------------------ VARIABLES --------------------
local tenFootInterfaceEnabled = false
do
	local platform = UserInputService:GetPlatform()

	tenFootInterfaceEnabled = (platform == Enum.Platform.XBoxOne or platform == Enum.Platform.WiiU or platform == Enum.Platform.PS4 or 
		platform == Enum.Platform.AndroidTV or platform == Enum.Platform.XBox360 or platform == Enum.Platform.PS3 or
		platform == Enum.Platform.Ouya or platform == Enum.Platform.SteamOS)
end

local Util = {}
do
	function Util.Create(instanceType)
		return function(data)
			local obj = Instance.new(instanceType)
			for k, v in pairs(data) do
				if type(k) == 'number' then
					v.Parent = obj
				else
					obj[k] = v
				end
			end
			return obj
		end
	end
end

local function CreateModule()
	local this = {}

	-- setup base gui
	do
		this.Container = Util.Create'ImageButton'
		{
			Name = "TopRightContainer";
			Size = UDim2.new(0, 250, 0, 100);
			Position = UDim2.new(1,-260,0,10);
			AutoButtonColor = false;
			Image = "";
			BackgroundTransparency = 1;
			Parent = RobloxGui;
		};
	end

	function this:CreateHealthBar()
		local healthContainer = Util.Create'Frame'{
			Name = "HealthContainer";
			Size = UDim2.new(1, -66, 0, 29);
			Position = UDim2.new(0, 67, 0, 0);
			BorderSizePixel = 0;
			BackgroundColor3 = Color3.new(0,0,0);
			BackgroundTransparency = 0.5;
			Parent = this.Container;
		};

		local healthFill = Util.Create'Frame'{
			Name = "HealthFill";
			Size = UDim2.new(1, -10, 1, -10);
			Position = UDim2.new(0, 5, 0, 5);
			BorderSizePixel = 0;
			BackgroundColor3 = HEALTH_GREEN_COLOR;
			Parent = healthContainer;
		};

		local healthText = Util.Create'TextLabel'{
			Name = "HealthText";
			Size = UDim2.new(0, 65, 0, 29);
			BackgroundTransparency = 0.5;
			BackgroundColor3 = Color3.new(0,0,0);
			Font = Enum.Font.SourceSans;
			FontSize = Enum.FontSize.Size24;
			Text = "Health";
			TextColor3 = Color3.new(1,1,1);
			BorderSizePixel = 0;
			Parent = this.Container;
		};

		return this.Container, username, healthContainer, healthFill
	end

	function this:SetupPlayerList()
		local displayedStat = nil
		local displayedStatChangedCon = nil
		local displayedStatParentedCon = nil
		local tenFootInterfaceStat = nil

		local function makeTenFootInterfaceStat()
			if tenFootInterfaceStat then return end

			tenFootInterfaceStat = Util.Create'Frame'{
				Name = "OneStatFrame";
				Size = UDim2.new(1, 0, 0, 36);
				Position = UDim2.new(0, 0, 0, 32);
				BorderSizePixel = 0;
				BackgroundTransparency = 1;
				Parent = this.Container;
			};
			local statName = Util.Create'TextLabel'{
				Name = "StatName";
				Size = UDim2.new(1,0,0,24);
				BackgroundTransparency = 1;
				Font = Enum.Font.SourceSans;
				FontSize = Enum.FontSize.Size24;
				TextStrokeColor3 = Color3.new(104/255, 104/255, 104/255);
				TextStrokeTransparency = 0;
				Text = " StatName:";
				TextColor3 = Color3.new(1,1,1);
				TextXAlignment = Enum.TextXAlignment.Left;
				BorderSizePixel = 0;
				Parent = tenFootInterfaceStat;
			};
			local statValue = statName:clone()
			statValue.Name = "StatValue"
			statValue.Text = "123,643,231"
			statValue.TextXAlignment = Enum.TextXAlignment.Right
			statValue.Parent = tenFootInterfaceStat
		end

		local function tenFootInterfaceRemoveStat( statToRemove )
			if statToRemove == displayedStat then
				displayedStat = nil

			end
		end

		local function setDisplayedStat(newStat)
			if displayedStatChangedCon then displayedStatChangedCon:disconnect() displayedStatChangedCon = nil end
			if displayedStatParentedCon then displayedStatParentedCon:disconnect() displayedStatParentedCon = nil end

			displayedStat = newStat

			if displayedStat then
				makeTenFootInterfaceStat()
				updateTenFootStat(displayedStat)
				displayedStatParentedCon = displayedStat.AncestryChanged:connect(function() updateTenFootStat(displayedStat, "Parent") end)
				displayedStatChangedCon = displayedStat.Changed:connect(function(prop) updateTenFootStat(displayedStat, prop) end)
			end
		end

		function updateTenFootStat(statObj, property)
			if property and property == "Parent" then
				tenFootInterfaceStat.StatName.Text = ""
				tenFootInterfaceStat.StatValue.Text = ""
				setDisplayedStat(nil)

				tenFootInterfaceChanged()
			else
				tenFootInterfaceStat.StatName.Text = " " .. tostring(statObj.Name) .. ":"
				tenFootInterfaceStat.StatValue.Text = tostring(statObj.Value)
			end
		end

		local function isValidStat(obj)
			return obj:IsA('StringValue') or obj:IsA('IntValue') or obj:IsA('BoolValue') or obj:IsA('NumberValue') or
				obj:IsA('DoubleConstrainedValue') or obj:IsA('IntConstrainedValue')
		end

		local function tenFootInterfaceNewStat( newStat )
			if not displayedStat and isValidStat(newStat) then
				setDisplayedStat(newStat)
			end
		end

		function tenFootInterfaceChanged()
			game:WaitForChild("Players")
			while not game.Players.LocalPlayer do
				wait()
			end

			local leaderstats = game.Players.LocalPlayer:FindFirstChild('leaderstats')
			if leaderstats then
				local statChildren = leaderstats:GetChildren()
				for i = 1, #statChildren do
					tenFootInterfaceNewStat(statChildren[i])
				end
				leaderstats.ChildAdded:connect(function(newStat)
					tenFootInterfaceNewStat(newStat)
				end)
				leaderstats.ChildRemoved:connect(function(child)
					tenFootInterfaceRemoveStat(child)
				end)
			end
		end

		game:WaitForChild("Players")
		while not game.Players.LocalPlayer do
			wait()
		end

		local leaderstats = game.Players.LocalPlayer:FindFirstChild('leaderstats')
		if leaderstats then
			tenFootInterfaceChanged()
		else
			game.Players.LocalPlayer.ChildAdded:connect(tenFootInterfaceChanged)
		end

	end

	return this
end


-- Public API

local moduleApiTable = {}

	local TenFootInterfaceModule = CreateModule()

	function moduleApiTable:IsEnabled()
		return tenFootInterfaceEnabled
	end

	function moduleApiTable:CreateHealthBar()
		return TenFootInterfaceModule:CreateHealthBar()
	end

	function moduleApiTable:SetupPlayerList()
		return TenFootInterfaceModule:SetupPlayerList()
	end

return moduleApiTable