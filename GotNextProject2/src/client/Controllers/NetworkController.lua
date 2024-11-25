local packages = game.ReplicatedStorage.Packages;
local knit = require(packages.Knit);

local SG = game:GetService('StarterGui');
local bindable = Instance.new('BindableFunction');

local NetworkController = knit.CreateController {
    Name = 'NetworkController';
};

function bindable.OnInvoke(response)
    print(response .. " chosen");
end

function NetworkController:hopOn(msg: string): string
    SG:SetCore('SendNotification', {
        Title = 'Got Next 2 Notification',
        Text = 'You\'ve hopped on a Field!',
        Duration = 10,
        Callback = bindable,
    });
end

function NetworkController:gameJoin(msg: string): string
    SG:SetCore('SendNotification', {
        Title = 'Got Next 2 Notification',
        Text = 'Welcome to Got Next 2! Enjoy your time here!',
        Duration = 10,
        Callback = bindable,
    });
end


function NetworkController:KnitStart()

end

function NetworkController:KnitInit()
    local NS = knit.GetService('NetworkService');
    NS.sendNotification:Connect(function(notifyType: string)
        self[notifyType]();
    end)
end


--[[



]]


return NetworkController;