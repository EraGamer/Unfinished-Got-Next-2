local packages = game.ReplicatedStorage.Packages;
local knit = require(packages.Knit);

require(script.Parent.Modules.MainService);
require(script.Parent.Service.NetworkService);
require(script.Parent.Components.Fields.Field1);


knit.Start({ServicePromises = false}):catch(warn):await()