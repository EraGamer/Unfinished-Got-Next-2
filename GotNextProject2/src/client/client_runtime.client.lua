local packages = game.ReplicatedStorage.Packages;
local knit = require(packages.Knit);

require(script.Parent.Controllers.NetworkController);
require(script.Parent.Controllers.InterfaceController);

knit.Start({ServicePromises = false}):catch(warn):await();