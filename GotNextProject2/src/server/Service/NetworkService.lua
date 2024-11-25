local Players = game:GetService("Players")

local packages = game.ReplicatedStorage.Packages;
local knit = require(packages.Knit);




local NetworkService = knit.CreateService {
    Name = 'NetworkService';
    Client = {
        sendNotification = knit.CreateSignal();
    };
};

function NetworkService:hopOn(plr: Player): Player
    self.Client.sendNotification:Fire(plr,'hopOn');
end


function NetworkService:KnitStart()

end

function NetworkService:KnitInit()
    game.Players.PlayerAdded:Connect(function(plr)
        self.Client.sendNotification:Fire(plr, 'gameJoin');
    end)
end


return NetworkService;