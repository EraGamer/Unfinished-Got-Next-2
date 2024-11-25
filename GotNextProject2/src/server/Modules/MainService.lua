local ServerScriptService = game:GetService("ServerScriptService")

local packages = game.ReplicatedStorage.Packages;
local knit = require(packages.Knit);

local ProfileTemplate = {
    Coins = 0;
    Items = {};
    LogInTimes = 0;
    Rank = 'Rookie 1';
    MMR = 100;
    Level = 1;
    XP = 100;
}

local PS = require(game.ServerScriptService.Server.Modules.ProfileService);
local Players = game:GetService('Players');
local ProfileStore = PS.GetProfileStore(
    "GotNextData2",
    ProfileTemplate
);

local MainService = knit.CreateService {
    Name = 'MainService';
    Profiles = {};
    Client = {
        SendRank = knit.CreateSignal();
    };
};

local function AddLogInTime(plr: Player, profile: Instance): Player
    profile.Data.LogInTimes += 1;
    warn('You\'ve logged in '..profile.Data.LogInTimes ..' times!');
end


function MainService:GrabData(plr: Player): Player
    return self.Profiles;
end


function MainService:PlayerAdded(plr: Player): Player
    local profile = ProfileStore:LoadProfileAsync("Player_" .. plr.UserId);
    if profile ~= nil then
        profile:AddUserId(plr.UserId);
        profile:Reconcile();
        profile:ListenToRelease(function()
            self.Profiles[plr] = profile;

            plr:Kick('Data may have been loaded in another server! Please rejoin!');
        end)
        if plr:IsDescendantOf(Players) == true then
            self.Profiles[plr] = profile;

            AddLogInTime(plr, profile);
            print(profile.Data.Level)
            self.Client.SendRank:FireAll(profile.Data.Level,profile.Data.Rank);
        else
            profile:Release();
        end
    else
        plr:Kick('Data couldn\'t load possibly due to other servers trying to load this Data at the same time!');
    end
end



function MainService:KnitStart()


    workspace.Game.Pads.Field1:SetAttribute('Pad1',false);
    workspace.Game.Pads.Field1:SetAttribute('Pad2',false);
    workspace.Game.Pads.Field1:SetAttribute('Squad',false);

    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(self:PlayerAdded(), player);
    end

    Players.PlayerAdded:Connect(function(plr: Player): Player
        plr:SetAttribute('Field_On', 'nil');
        plr:SetAttribute('ClickablePrompt', true);
        self:PlayerAdded(plr);
    end)

    Players.PlayerRemoving:Connect(function(plr: Player): Player
        local profile = self.Profiles[plr];
        if profile ~= nil then
            profile:Release();
        end
    end)
end

function MainService:KnitInit()

end



return MainService;