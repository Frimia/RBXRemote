local Server	= game:GetService'RunService':IsServer(); -- Yeah.
local Network	= setmetatable({}, {__metatable = 'NetworkObject', __tostring = function() return 'Socket'; end});
local Internal	= Instance.new'BindableEvent'; -- For threading.
local Rems		= {}; -- Remotes.
local Num		= 3; -- #Remotes.

local print		= print; -- I am lazy so just localize this for that extra 0.000001 second performance.
local tick		= tick;
local Sub		= string.sub;
local Rand		= math.random;
local Concat	= table.concat;
local Instance	= Instance.new;
local Random	= function(Pref, Len) local Return = {Pref or '', '~>'}; for Idx = 1, Len do Return[Idx + 1] = Rand(33, 126); end; return Concat(Return); end;

math.randomseed(tick()); -- This is just common sense.

if Server then
	for Nm = 1, Num do -- Create multiple just so one won't get flooded. :)
		local So		= Instance'RemoteEvent';

		Rems[Nm]		= So;

		So.Name			= 'RemEv';
		So.Archivable	= false;
		So.Parent		= script;
	end;

	local Fire		= Rems[1].FireClient;
	local FireA		= Rems[1].FireAllClients;
	local typeof	= typeof;
	local select	= select;

	function Network.Get(Client, ...)
		local Yield	= Instance'BindableEvent';
		local Time	= tick();
		local Key	= Random('S', 15);
		local Net	= Rems[Rand(1, Num)];

		local IntE; IntE	= Net.OnServerEvent:Connect(function(C, Case, ...)
			if (C == Client) and (Case == Key) then
				Yield:Fire(...);

				IntE:Disconnect();
			elseif ((Time + 10) < tick()) then
				Yield:Fire(nil);

				IntE:Disconnect();
			end;
		end);

		Fire(Net, Client, Key, ...);

		return Yield.Event:wait();
	end;

	function Network.Send(Client, ...)
		return Fire(Rems[Rand(1, Num)], Client, Random(nil, 20), ...);
	end;

	function Network.SendAll(...)
		return FireA(Rems[Rand(1, Num)], Random(nil, 20), ...);
	end;

	function Network.Connect(F)
		return Internal.Event:Connect(F);
	end;

	for R = 1, Num do
		local Net	= Rems[R];

		Net.OnServerEvent:Connect(function(Player, Reason, ...)
			local Call	= Sub(Reason, 1, 1);

			if (Call == 'C') and Network.Hook then
				Fire(Net, Player, Reason, Network.Hook(Player, ...));
			elseif (Call == 'F') then
				local Client	= (...);
				local Yield		= Instance'BindableEvent';
				local Time		= tick();
				local Ret		= 'V' .. Reason;

				if (Player == Client) or (typeof(Client) ~= 'Instance') or (not Client:IsA'Player') then
					return;
				end;

				local IntE; IntE	= Net.OnServerEvent:Connect(function(C, Case, ...)
					if (C == Client) and (Case == Ret) then
						Yield:Fire(...);

						IntE:Disconnect();
					elseif ((Time + 20) < tick()) then
						Yield:Fire(nil);

						IntE:Disconnect();
					end;
				end);

				Fire(Net, Client, Reason, Player, select(3, ...));
				Fire(Net, Player, Reason, Yield.Event:wait());
			elseif (Call ~= 'V') then
				Internal:Fire(Player, ...);
			end;
		end);
	end;
else
	local Fire	= Instance'RemoteEvent'.FireServer;

	for Idx = 1, Num do
		local So	= script:WaitForChild'RemEv';

		So.Name		= 'Net';

		Rems[Idx]	= So;
	end;

	function Network.Fetch(Player, Returns, ...) -- First arg should be the player receiving!
		local Key	= Random('F', 7); -- It's the same as Get just a F and smaller key ok.

		if Returns then
			local Yield	= Instance'BindableEvent';
			local Time	= tick();

			local Net	= Rems[Rand(1, Num)];

			local IntE; IntE	= Net.OnClientEvent:Connect(function(Case, ...)
				if (Case == Key) then
					Yield:Fire(...);

					IntE:Disconnect();
				elseif ((Time + 20) < tick()) then -- Also should have a bigger timeout.
					Yield:Fire(nil);

					IntE:Disconnect();
				end;
			end);

			Fire(Net, Key, Player, Returns, ...);

			return Yield.Event:wait();
		else
			return Fire(Rems[Rand(1, Num)], Key, Player, Returns, ...);
		end;
	end;

	function Network.Get(...)
		local Yield	= Instance'BindableEvent';
		local Time	= tick();
		local Key	= Random('C', 15);
		local Net	= Rems[Rand(1, Num)];

		local IntE; IntE	= Net.OnClientEvent:Connect(function(Case, ...)
			if (Case == Key) then
				Yield:Fire(...);

				IntE:Disconnect();
			elseif ((Time + 10) < tick()) then
				Yield:Fire(nil);

				IntE:Disconnect();
			end;
		end);

		Fire(Net, Key, ...);

		return Yield.Event:wait();
	end;

	function Network.Send(...)
		return Fire(Rems[Rand(1, Num)], Random(nil, 20), ...);
	end;

	function Network.Connect(F)
		return Internal.Event:Connect(F);
	end;

	for Idx = 1, Num do
		local Net	= Rems[Idx];

		Net.OnClientEvent:Connect(function(Reason, ...)
			local Call	= Sub(Reason, 1, 1);

			if (Call == 'S') and Network.Hook then
				Fire(Net, Reason, Network.Hook(...));
			elseif (Call == 'F') and Network.Cross then
				Fire(Net, 'V' .. Reason, Network.Cross(...));
			else
				Internal:Fire(...);
			end;
		end);
	end;
end;

return Network;
