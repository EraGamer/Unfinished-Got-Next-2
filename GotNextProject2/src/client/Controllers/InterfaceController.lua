local packages = game.ReplicatedStorage.Packages;
local knit = require(packages.Knit);

local plr = game.Players.LocalPlayer;
local char = plr.Character or plr.CharacterAdded:Wait();

local tbService = require(game.ReplicatedStorage.ClientStorage.Modules.TopbarModule);


local InterfaceController = knit.CreateController {
    Name = 'InterfaceController';
};


function InterfaceController:RankUI(rank_: number, level: string): number
    local rank = plr.PlayerGui:WaitForChild('PlayerUI').MainFrame;
    rank.Parent.Adornee = char.HumanoidRootPart;
    rank.Name_.Text = plr.Name;
    print(rank)
    rank.Level_.Text = tostring(rank_);
    rank.Rank.Text = tostring(level);
end


function InterfaceController:KnitStart()

end


function InterfaceController:KnitInit()
    local MainService = knit.GetService('MainService');
    local Field1 = knit.GetService('Field1');

    local menuButton = tbService:Add('Menu','rbxassetid://7104824634',true);
    local deb = false;


    Field1.ShowRank_:Connect(function() 
        Field1:ShowRank();
    end)

    menuButton.MouseButton1Click:Connect(function()
        if not plr.PlayerGui:WaitForChild('MainMenu').Enabled then
            plr.PlayerGui:WaitForChild('MainMenu').Enabled = true;
            game.Lighting.DepthOfField.Enabled = true;
        else
            plr.PlayerGui:WaitForChild('MainMenu').Enabled = false;
            game.Lighting.DepthOfField.Enabled = false;
        end
    end)

    plr.PlayerGui:WaitForChild('HopOff').HopButton.MouseButton1Click:Connect(function()
        if plr:GetAttribute('Field_On') == 'Field1' then
            if plr:GetAttribute('Field_Spot') == 1 then
                Field1:HopOff(1,plr:GetAttribute('Field_On'));
            elseif plr:GetAttribute('Field_Spot') == 2 then
                Field1:HopOff(2,plr:GetAttribute('Field_On'));
            elseif plr:GetAttribute('Field_Spot') == 3 then
                Field1:HopOff(3,plr:GetAttribute('Field_On'));
            elseif plr:GetAttribute('Field_Spot') ==  4 then
                Field1:HopOff(4,plr:GetAttribute('Field_On'));
            elseif plr:GetAttribute('Field_Spot') == 5 then
                Field1:HopOff(5,plr:GetAttribute('Field_On'));
            elseif plr:GetAttribute('Field_Spot') == 6 then
                Field1:HopOff(6,plr:GetAttribute('Field_On'));
            end
        end
    end)

    MainService.SendRank:Connect(function(rank: number, level: string): string
        self:RankUI(rank,level);
    end)
end


return InterfaceController;