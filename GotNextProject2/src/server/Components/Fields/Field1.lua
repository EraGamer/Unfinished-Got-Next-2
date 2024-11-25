local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Pad1, Pad2 = game.Workspace.Game.Pads.Field1.Pad1, game.Workspace.Game.Pads.Field1.Pad2

local Field1 = Knit.CreateService({
	Name = "Field1",

	On_Field = {},

	On_Pad1 = {},
	On_Pad2 = {},

	Is_Pad1 = false,
	Is_Pad2 = false,
	IsSquad = false,

	Team1 = {},
	Team1_Score = 0,
	Team1_Clock = 30,
	Team2 = {},
	Team2_Score = 0,
	Team2_Clock = 30,

	Position = -90, --(30 yards left from center field)

	Client = {
		ShowRank_ = Knit.CreateSignal(),
	},
})

function Field1:PositionPlayers()
	local positions = { { 15, -15 }, { 30, 0 }, { 15, 15 } }

	for i, v in ipairs(self.Team1) do
		v.Character.HumanoidRootPart.CFrame = CFrame.new(self.Position + positions[i][2], 3, positions[i][2])
	end

	for i, v in ipairs(self.Team2) do
		v.Character.HumanoidRootPart.CFrame = CFrame.new(self.Position + (-1 * positions[i][2]), 3, positions[i][2])
	end
end

function Field1:ShowRank(plr: Player): Player
	local MainService = Knit.GetService("MainService");
	for _, v in ipairs(Pad1.Parent.Team1:GetChildren()) do
		plr.PlayerGui:WaitForChild("PlayerUI").Adornee = v;
	end

	for i = 1, #self.Team1 do
		local myData = MainService:GetData(self.Team1[i]);
		plr.PlayerGui:WaitForChild("PlayerUI").MainFrame.Level_.Text = tostring(myData.Level);
		plr.PlayerGui:WaitForChild("PlayerUI").MainFrame.Name_.Text = tostring(self.Team1[i]);
		plr.PlayerGui:WaitForChild("PlayerUI").MainFrame.Rank.Text = tostring(myData.Rank);
	end
end

function Field1.Client:ShowRank(plr: Player): Player
	self.Server:ShowRank(plr);
end

function Field1:StartGame()
	for i, v in ipairs(self.Team1) do
		v.Character.HumanoidRootPart.CFrame = CFrame.new(
			Pad1.Parent.Team1["Part" .. tostring(i)].Position + Vector3.new(0, 3, 0),
			Vector3.new(Pad1.Parent.Team1["Part" .. tostring(i)].Position - Vector3.new(15, 0, 0))
		)
	end

	for i, v in ipairs(self.Team2) do
		v.Character.HumanoidRootPart.CFrame = CFrame.new(
			Pad2.Parent.Team1["Part" .. tostring(i)].Position + Vector3.new(0, 3, 0),
			Vector3.new(Pad2.Parent.Team1["Part" .. tostring(i)].Position + Vector3.new(15, 0, 0))
		)
	end

	self.Client.ShowRank:FireAll()

	--Tween Camera
	local targets = {
		CFrame.new(Vector3.new(0, 5.5, 315), Vector3.new(15, 6.87, 315)),
		CFrame.new(Vector3.new(0, 5.5, 295), Vector3.new(-15, 6.87, 295)),
	}
	local cframes = {
		CFrame.new(Vector3.new(0, 5.5, 295), Vector3.new(15, 5.5, 295)),
		CFrame.new(Vector3.new(0, 5.5, 315), Vector3.new(-15, 5.5, 315)),
	}

	local instance = workspace.Game.Camera.Cam
	local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear)

	for i = 1, 2 do
		instance.CFrame = cframes[i]

		task.wait(1)

		local propertyTable = {
			CFrame = targets[i],
		}

		local tween = TweenService:Create(instance, tweenInfo, propertyTable)
		tween:Play()
		tween.Completed:Wait()

		task.wait(1)
	end
	--Tween Camera finished
	self.Position = -30
	self:PositionPlayers() --setup players at the 20
end

function Field1:HopOn(plr: Player, spot: Instance): Player
	print("HopOn")
	local NS = Knit.GetService("NetworkService")
	local char = plr.Character or plr.CharacterAdded:Wait()

	if Pad1.Parent:GetAttribute("Pad1") then
        print('a')
		return
	elseif Pad1.Parent:GetAttribute("Pad2") then
		return
	end

	char.HumanoidRootPart.CFrame = spot.CFrame + Vector3.new(0, 2, 0)
	char.Humanoid.WalkSpeed = 0
	char.HumanoidRootPart.Anchored = true
	NS:hopOn(plr)

	if spot.Parent.Name == "Pad1" then
		table.insert(self.On_Pad1, plr.Name)
	elseif spot.Parent.Name == "Pad2" then
		table.insert(self.On_Pad2, plr.Name)
	end

	if #self.On_Pad1 == 3 then
		self.Is_Pad1 = true
	end

	if #self.On_Pad2 == 3 then
		self.Is_Pad2 = true
	end

	if self.Is_Pad1 and self.Is_Pad2 then
		for i, v in ipairs(self.On_Pad1) do
			table.remove(self.On_Pad1, i)
			v:SetAttribute("SpotOn", i)
			table.insert(self.Team1, v.Name)
		end

		for i, v in ipairs(self.On_Pad2) do
			table.remove(self.On_Pad2, i)
			v:SetAttribute("SpotOn", i)
			table.insert(self.Team2, v.Name)
		end
	elseif self.Is_Pad1 and self.IsSquad then
		for i, v in ipairs(self.On_Pad1) do
			table.remove(self.On_Pad1, i)
			v:SetAttribute("SpotOn", i)
			table.insert(self.Team1, v.Name)
		end
	end

	self:StartGame()
end

function Field1:KnitStart()
    print("Field1 Service Started")
end

function Field1:KnitInit()
	for PAD_NUM = 1, 2 do
		local pad = workspace.Game.Pads.Field1["Pad" .. tostring(PAD_NUM)]
		for PART_NUM = 1, 3 do
			pad["Part" .. tostring(PART_NUM)].ProximityPrompt.Triggered:Connect(function(plr: Player): Player
				if plr:GetAttribute("ClickablePrompt") then
					plr:SetAttribute("ClickablePrompt", false)
					self:HopOn(plr, pad["Part" .. tostring(PART_NUM)])
				end
			end)
		end
	end
    print("Field1 Service init'd")
end

return Field1
