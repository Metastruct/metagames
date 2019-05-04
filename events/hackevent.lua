// ShockMeta
--Event 1

local plymeta = FindMetaTable( "Player" )
if not plymeta then Error("FAILED TO FIND PLAYER TABLE") return end


PrecacheParticleSystem("rd_bot_impact_sparks")

Metavent = Metavent or {}

local rand = math.random
    
function table.Shuffle(t)
	local n = #t
		while n > 2 do
			local k = rand(n)
			t[n], t[k] = t[k], t[n]
			n = n - 1
		end
	    
	return t
end

if SERVER then
	
	Metavent.Players = {}
	Metavent.LoadingPlys = Metavent.LoadingPlys or {}
	Metavent.IsPreparing = false
	Metavent.IsReady = false
	
	Metavent.BloodPos = Vector (-4578.84375, 10073.924804688, 2062.3400878906)
	Metavent.DoorPos = Vector (-5372.9848632812, 9671.638671875, 2853.6076660156)

	util.AddNetworkString( "Starteventmeta" )
	util.AddNetworkString( "PreloadSound" )
	util.AddNetworkString( "ldFinished" )
	util.AddNetworkString( "SoundCommand" )
	util.AddNetworkString( "PlayWebMusic" )
	    
	util.AddNetworkString( "PreloadComplete" ) 
	
	util.AddNetworkString( "LightControl" ) 
    // PLAYER
    
    // "" = Stop ALL
    // "idblabla" = Stop This
    function plymeta:StopMusic(id)
    	net.Start("SoundCommand")
    		net.WriteString(id)
    	net.Send(self)
    end
    
    function plymeta:RestrainPlayer()
    	if !IsValid(self) then return end
    	if self:GetNWBool("RestrictedMg") then return end
    	
    	--self:Spawn()
    	    	
    	self:SetNWBool("RestrictedMg",true)
    	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    	
        self:ShouldDropWeapon( false )
        self:StripWeapons()
        self:Give("hands")
            
        self:ExitVehicle()
        self:GodDisable()
        
        //self:ConCommand("pac_enable 0")
        self:ConCommand("playx_enabled 0")
        self:SetSolid(2)

        //self.OldPACSize = self:GetModelScale()
        self.OldModel = self:GetModel()
        
        //pac.SetPlayerSize(self,1) // Reset pac size

        //self:SetNWInt("pac_size",self.OldPACSize)
        self:SetNWBool("HideNames",true)
        self:SetNWBool("HideTyping",true)
        self:SetColor(Color(255,255,255,255))
        
        self:SprintDisable()
        
        self:ExitVehicle()
        
        // Disable Thirdperson
        self:SendLua([[ctp:Disable()]])
        
        self:ConCommand("r_cleardecals")
        self:SetMoveType(MOVETYPE_WALK)
  
        self:SetAllowNoclip(false, "hackevent")
        self:SetAllowBuild(false, "hackevent")
        
        self:SetSuperJumpMultiplier(0,false) // Anti-bhop

        self.canWATT = false
        self.nossjump = true
        self.noleap = true
        self.last_rip = 99999999
        self.double_jump_allowed = false
        self.DisableSit = true
        
        self:SetHealth(100)
        
        self:StripAmmo()
        
        self:SetNotSolid(true)
    	self:SetNoDraw(true)
        
    end

	function plymeta:ReleasePlayer()
    	if !IsValid(self) then return end
    	if !self:GetNWBool("RestrictedMg") then return end
    	
    	self:SetNWBool("RestrictedMg",false)
    	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
    	
    	self:SetAllowNoclip(true, "hackevent")
        self:SetAllowBuild(true, "hackevent")
        
        self:SetSuperJumpMultiplier(1.5,false)
        self:SetWalkSpeed(200)
        self:SetRunSpeed(400)
        self:SetJumpPower(200)
        self:CrosshairEnable()
        
        self:Freeze(false)
        
        self:SetNWBool("HideNames",false)
        self:SetNWBool("HideTyping",false)
        
        self.nossjump = false
        self.noleap = false
        self.DisableSit = false
        
        self:SprintEnable()
        
        //local Oldsize = self.OldPACSize or 1
        //pac.SetPlayerSize(self,Oldsize) // Reset pac size
        //self.pac_player_size = Oldsize
        self.double_jump_allowed = true
        
        self.last_rip = CurTime()
        
        self:ShouldDropWeapon( false )
        self:StripWeapons()
        
        //self:ConCommand("pac_enable 1")
        self:ConCommand("playx_enabled 1")
        
        self:SetNotSolid(false)
    	self:SetNoDraw(false)
        
        self:SetGravity(1)
    end
    
    function plymeta:SetLight(bri,con,mult)
    	net.Start("LightControl")
    		net.WriteDouble(bri)
    		net.WriteDouble(con)
    		net.WriteDouble(mult)
    	net.Send(self)
    end
    
    function SetGlobalLight(bri,con,mult)
    	for _,v in pairs(Metavent.Players) do
	    	if !IsValid(v) then continue end
	    	v:SetLight(bri,con,mult)
    	end
	end

	function DoCommand(cmd)
		for _,v in pairs(Metavent.Players) do
	    	if !IsValid(v) then continue end
	    	net.Start("SoundCommand")
    			net.WriteString(cmd)
    		net.Send(v)
    	end	
	end
    
    function TeleTo(pos)
	   	for _,v in pairs(Metavent.Players) do
	   		if !IsValid(v) then continue end
	   		v:SetPos(pos)
	   	end
    end
    
    function GlobalRequest(id,override)
    	for _,v in pairs(Metavent.Players) do
    		if !IsValid(v) then continue end
	    	net.Start("PlayWebMusic")
				net.WriteString(id)
				net.WriteBool(override)
			net.Send(v)
    	end
	end

	function GlobalShake()
		for _,v in pairs(Metavent.Players) do
			if !IsValid(v) then continue end
			net.Start("SoundCommand")
				net.WriteString("shake")
			net.Send(v)
		end
	end
    
    function StopMusics()
    	net.Start("SoundCommand")
    		net.WriteString("")
    	net.Broadcast()
    end
    
    function plymeta:requestMusic(id,override)
		net.Start("PlayWebMusic")
			net.WriteString(id)
			net.WriteBool(override)
		net.Send(self)
	end
	
	function plymeta:preloadMusic(id,url,vol)
		net.Start("PreloadSound")
			net.WriteString(id)
			net.WriteString(url)
			net.WriteDouble(vol)
		net.Send(self)
	end

	function HackDataSYSTEMS()
		
		Metavent.IsPreparing = false
		Metavent.IsReady = false
		
		
		for _,v in pairs(player.GetAll()) do
			if !IsValid(v) then continue end
			if v:GetNWBool("in pac3 editor") or v == ukgamer then continue end
			table.insert(Metavent.Players,v) 
		end
	
		/*
		for v,i in pairs(ms.GetTrigger("lobby"):GetPlayers()) do
            if !IsValid(v) then continue end
            if v:GetNWBool("in pac3 editor") then continue end
			table.insert(Metavent.Players,v)
        end
*/
		
		StopMusics()
		Preparemap()
		
		SilentLoad()

		for _,v in pairs(Metavent.Players) do
			net.Start("Starteventmeta")
			net.Send(v)	
		end

	end
	
	function BloodAll(mdl)
		local Bou = ents.FindByModel(mdl)

		for _,v in pairs(Bou) do
			if IsValid(v:CPPIGetOwner()) and v:CPPIGetOwner():SteamID() == "STEAM_0:1:20785590" then
				if v:GetMaterial() != "models/debug/debugwhite" then
					v:SetMaterial("models/flesh")	
				end
			end
		end
	end

	function Preparemap()
		
		BloodAll("models/props_coalmines/boulder5_large.mdl")
		BloodAll("models/hunter/plates/plate16x16.mdl")
		BloodAll("models/props_swamp/rock001_swamp.mdl")
		BloodAll("models/props_swamp/rock007_swamp.mdl")
		BloodAll("models/props_swamp/rock004_swamp.mdl")
		
		BloodAll("models/props_foliage/tree_pine_small.mdl")
		

	end
	
	function SilentLoad()
		
		if Metavent.IsPreparing then return end
		Metavent.IsPreparing = true
		
		for _,v in pairs(Metavent.Players) do
    		if !IsValid(v) then continue end
    		
			v:preloadMusic("ambient_inside","https://failcake.ams3.digitaloceanspaces.com/public/random_sounds/EVENT/ambientinside.ogg",0.5)
			v:preloadMusic("ambient_start","https://failcake.ams3.digitaloceanspaces.com/public/random_sounds/EVENT/ambientstart.ogg",0.5)
			
			v:preloadMusic("announce_data","https://failcake.ams3.digitaloceanspaces.com/public/random_sounds/EVENT/announce_data.ogg",0.8)
			v:preloadMusic("announce_outro","https://failcake.ams3.digitaloceanspaces.com/public/random_sounds/EVENT/announce_outro.ogg",0.8)
			v:preloadMusic("announce_start","https://failcake.ams3.digitaloceanspaces.com/public/random_sounds/EVENT/announce_start.ogg",0.8)
			v:preloadMusic("announce_start_2","https://failcake.ams3.digitaloceanspaces.com/public/random_sounds/EVENT/announce_start_2.ogg",0.8)
			v:preloadMusic("flashback","https://failcake.ams3.digitaloceanspaces.com/public/random_sounds/EVENT/flashback_outro.ogg",1)
			
			v:preloadMusic("static","https://failcake.ams3.digitaloceanspaces.com/public/random_sounds/EVENT/static.ogg",0.7)
			v:preloadMusic("final","https://failcake.ams3.digitaloceanspaces.com/public/random_sounds/EVENT/final.ogg",1)
			
    		table.insert(Metavent.LoadingPlys,v)
    		
    	end	
	end
	
	
	 net.Receive("PreloadComplete",function(len,ply)
    	
    	if !IsValid(ply) or !ply:IsPlayer() then return end
    	
		print(ply:Name() .. " finished loading.")
		table.RemoveByValue(Metavent.LoadingPlys,ply)
		
		if #Metavent.LoadingPlys <= 0 then
			
			print("Finished Loading.")
			
			timer.Simple(3,function()
				StartEvent()
			end)
			
		end
		
	end)
	
	 function ExtractManuallight()
    	print("==== Extraction Start ====")
    	
    	local Rocks = ents.FindByModel("models/hunter/blocks/cube025x025x025.mdl")
    	
    	for l,v in pairs(Rocks) do
    		if IsValid(v) then
               	if IsValid(v:CPPIGetOwner()) and v:CPPIGetOwner():SteamID() == "STEAM_0:1:20785590" then
               		local Pos = v:GetPos()
               		local Comm = ""
               		
               		if l < #Rocks then
               			Comm = ","
               		end
               		v:Remove()
               		print("{Pos = Vector("..Pos.x..","..Pos.y..","..Pos.z..")}"..Comm)
               	end
            end
        end
        print("==== Extraction End ====")
    end


	function StartEvent()
		
		print("STARTING")
		
		GlobalRequest("ambient_start",true)
		
		timer.Simple(2,function() GlobalRequest("announce_start_2",false) end)
		
		timer.Simple(20,function() 
			GlobalRequest("announce_start",false) 
		end)
		
		timer.Simple(22,function()
			
			GlobalShake()
			DoCommand("spark")

		end)
		
		timer.Simple(24,function()
			DoCommand("powerup")
		end)
		
		timer.Simple(30,function()
			
			GlobalRequest("announce_data",false)
			GlobalShake()
			DoCommand("boom")
			
		end)
		
		timer.Simple(38,function()
			GlobalShake()
			SetGlobalLight(-1,1,1)
			DoCommand("powerdown")
		end)
		
		timer.Simple(38,function()
			GlobalShake()
			DoCommand("boom")
			DoCommand("powerup")
		end)
		
		timer.Simple(50,function()
			StopMusics()
			GlobalRequest("ambient_inside",true)
			SetGlobalLight(-0.72,4.86,2)
			GlobalRequest("flashback",false)
			DoCommand("screenS")
			
			for _,v in pairs(Metavent.Players) do
    			if !IsValid(v) then continue end
    			    v:SetWalkSpeed(100)
			        v:SetRunSpeed(100)
			        v:SetJumpPower(0)
			        v:SetGravity(0.2)
			        v:RestrainPlayer()
			end
		end)
		
		timer.Simple(52,function()
			GlobalRequest("announce_outro",false)
		end)
		
		timer.Simple(67,function()
			DoCommand("screenSk_static")
			
			for _,v in pairs(Metavent.Players) do
    			if !IsValid(v) then continue end
    			v.oldPOSTE = v:GetPos()
    		end
			
			TeleTo(Metavent.BloodPos)
		end)
		
		timer.Simple(85,function()
			
			DoCommand("screenSk_static")
			TeleTo(Metavent.DoorPos)
			
		end)
		
		timer.Simple(89,function()
			
			DoCommand("screenSk_static")
			
			for _,v in pairs(Metavent.Players) do
    			if !IsValid(v) then continue end
			    v:SetPos(v.oldPOSTE)
			    v:SetGravity(1)
			end
			
		end)
		
		timer.Simple(107,function()
			
			SetGlobalLight(-1,1,1)
			DoCommand("screenSk_static")
			DoCommand("powerdown")
			
			GlobalRequest("final",false)
		end)
		
		timer.Simple(123,function() 
			DoCommand("END")
			
			for _,v in pairs(Metavent.Players) do
    			if !IsValid(v) then continue end
			    v:ReleasePlayer()
			    v:SetGravity(1)
			end
			
		end)
		
	end
	
end


if CLIENT then

	Metavent.URLMusics = Metavent.URLMusics or {}
	Metavent.Players = Metavent.Players or {}
	Metavent.LoadingMusic = {}
	Metavent.LastMusic = ""
	Metavent.LoadInit = false
	Metavent.AlreadyLOADING = false
	Metavent.INSIDE = false
	Metavent.Static = false
	
	Metavent.LightPos = {
		{Pos = Vector(-15130.420898438,-1439.1865234375,14505.6640625)},
		{Pos = Vector(-15403.561523438,-1416.4056396484,14505.729492188)},
		{Pos = Vector(-14847.255859375,-1885.4200439453,14464.849609375)},
		{Pos = Vector(-14074.146484375,-1887.4943847656,14465.232421875)},
		{Pos = Vector(-14017.28125,-1211.3748779297,14462.166015625)},
		{Pos = Vector(-14789.797851562,-1205.5866699219,14464.885742188)},
		{Pos = Vector(-15467.524414062,-1257.7442626953,14505.615234375)},
		{Pos = Vector(-15658.1796875,-1249.9229736328,14489.642578125)},
		{Pos = Vector(-15957.110351562,-1206.2309570312,14489.717773438)},
		{Pos = Vector(-16001.741210938,-921.95306396484,14489.59765625)},
		{Pos = Vector(-15998.172851562,-571.57672119141,14489.61328125)},
		{Pos = Vector(-15996.368164062,-185.50270080566,14489.650390625)},
		{Pos = Vector(-15998.416015625,165.64945983887,14489.594726562)},
		{Pos = Vector(-16002.4453125,545.94885253906,14489.614257812)},
		{Pos = Vector(-15992.073242188,725.06298828125,14489.59375)},
		{Pos = Vector(-15767.889648438,736.91168212891,14489.604492188)},
		{Pos = Vector(-15453.302734375,731.84777832031,14489.66796875)},
		{Pos = Vector(-15130.299804688,734.35797119141,14489.64453125)},
		{Pos = Vector(-14911.208984375,735.68701171875,14489.620117188)},
		{Pos = Vector(-14943.540039062,505.74957275391,14489.645507812)},
		{Pos = Vector(-14622.39453125,574.33996582031,14489.631835938)},
		{Pos = Vector(-14240.229492188,570.36706542969,14489.625976562)},
		{Pos = Vector(-13849.565429688,576.45355224609,14489.59375)},
		{Pos = Vector(-13466.875976562,574.78863525391,14489.6484375)},
		{Pos = Vector(-13281.294921875,552.00354003906,14489.619140625)},
		{Pos = Vector(-12848.234375,586.46533203125,14489.594726562)},
		{Pos = Vector(-13248.075195312,331.27978515625,14489.622070312)},
		{Pos = Vector(-13310.844726562,31.717021942139,14553.669921875)},
		{Pos = Vector(-13024.551757812,30.734420776367,14553.594726562)},
		{Pos = Vector(-14117.54296875,291.59622192383,14649.59375)},
		{Pos = Vector(-13248.426757812,-315.1171875,14489.608398438)},
		{Pos = Vector(-13249.327148438,-509.05706787109,14489.685546875)},
		{Pos = Vector(-13488.073242188,-468.96005249023,14425.600585938)},
		{Pos = Vector(-13527.592773438,-275.60073852539,14425.711914062)},
		{Pos = Vector(-13094.365234375,-998.03497314453,14515.490234375)},
		{Pos = Vector(-13353.599609375,-1000.2767333984,14516.626953125)},
		{Pos = Vector(-13353.65234375,-1474.2340087891,14513.1640625)},
		{Pos = Vector(-13094.391601562,-1471.7221679688,14514.009765625)},
		{Pos = Vector(-12929.943359375,-1540.3983154297,14419.030273438)},
		{Pos = Vector(-12651.672851562,-1545.2010498047,14418.939453125)},
		{Pos = Vector(-12744.999023438,-1673.3975830078,14407.372070312)},
		{Pos = Vector(-12926.704101562,-1807.3203125,14407.282226562)},
		{Pos = Vector(-12927.290039062,-1916.2763671875,14406.668945312)},
		{Pos = Vector(-12567.559570312,-1798.7784423828,14406.9375)},
		{Pos = Vector(-12572.533203125,-1912.2860107422,14407.493164062)},
		{Pos = Vector(-13463.059570312,-1402.6704101562,14553.651367188)},
		{Pos = Vector(-13768.96484375,-1409.7033691406,14553.669921875)},
		{Pos = Vector(-15909.234375,-1432.8321533203,14425.655273438)},
		{Pos = Vector(-15776.393554688,-2047.8343505859,14425.717773438)},
		{Pos = Vector(-15704.770507812,-1664.8616943359,14425.651367188)},
		{Pos = Vector(-15347.3828125,-1005.6447753906,14405.846679688)},
		{Pos = Vector(-15486.595703125,-999.54046630859,14406.11328125)},
		{Pos = Vector(-15236.671875,-912.68994140625,14401.666015625)},
		{Pos = Vector(-15234.346679688,-352.26174926758,14401.602539062)},
		{Pos = Vector(-14713.779296875,-345.00796508789,14400.729492188)},
		{Pos = Vector(-14398.823242188,-319.0016784668,14425.59375)},
		{Pos = Vector(-14671.022460938,-481.16650390625,14417.614257812)},
		{Pos = Vector(-14040.3515625,-531.73211669922,14417.666992188)},
		{Pos = Vector(-14076.016601562,-948.79840087891,14417.63671875)},
		{Pos = Vector(-14273.35546875,-959.95611572266,14417.6171875)},
		{Pos = Vector(-14785.098632812,-934.20733642578,14425.630859375)},
		{Pos = Vector(-14630.805664062,-764.73614501953,14425.603515625)},
		{Pos = Vector(-14936.713867188,-771.79290771484,14425.625)},
		{Pos = Vector(-14773.673828125,-645.70690917969,14425.721679688)},
		{Pos = Vector(-13562.123046875,-807.88195800781,14632.275390625)},
		{Pos = Vector(-14038.423828125,-714.79376220703,14625.39453125)},
		{Pos = Vector(-14505.587890625,-2604.3046875,14362.944335938)},
		{Pos = Vector(-14505.677734375,-2284.2687988281,14365.256835938)},
		{Pos = Vector(-14294.35546875,-2278.7744140625,14369.43359375)},
		{Pos = Vector(-14294.40625,-2608.7319335938,14371.04296875)}
	}
	
	Metavent.LightSettings = {
    	[ "$pp_colour_addr" ] = 0, 
    	[ "$pp_colour_addg" ] = 0, 
    	[ "$pp_colour_addb" ] = 0, 
    	[ "$pp_colour_brightness" ] = 0, 
    	[ "$pp_colour_contrast" ] = 1, 
    	[ "$pp_colour_colour" ] = 1, 
    	[ "$pp_colour_mulr" ] = 0, 
    	[ "$pp_colour_mulg" ] = 0, 
    	[ "$pp_colour_mulb" ] = 0
    }
	
	net.Receive( "Starteventmeta", function()
		
		Metavent.LoadInit = false
		Metavent.AlreadyLOADING = false
		
		Metavent.LightSettings.Bright = 0
		Metavent.LightSettings.Mult = 1
		Metavent.LightSettings.Con = 1
		
		Metavent.INSIDE = false
		Metavent.Static = false
		
		UNMeatEverything()
	
        hook.Add("PreChatSound", "alone", function(ply)
			return !Metavent.INSIDE
		end)
     
        hook.Add("Think","LoadStuff",LoadThink)
        
		StopAllSounds()
	
		hook.Add("PrePlayerDraw","Alone",function()
			return Metavent.INSIDE
		end)

		hook.Add("PlayerFootstep","alone",function(ply,pos,foot,sound,vol,filter)
			if !Metavent.INSIDE then return end
			ply:EmitSound("player/footsteps/mud"..math.random(1,6)..".wav",75)
			return true
		end)

	    hook.Add("RenderScreenspaceEffects","ScrEffScary",function()
		 	DrawColorModify( Metavent.LightSettings )
		 	
		 	if Metavent.INSIDE then
		 		DrawBloom( 0.90, 0, 30, 30, 0, 3.8, 167, 0, 0 )	
		 		DrawMotionBlur( 0.4, 0.8, 0.01 )
		 		DrawToyTown( 3, ScrH()/2 )
		 	end
		 	
		 	if Metavent.Static then
		 		DrawMaterialOverlay( "effects/tvscreen_noise001a",1 )
		 	end
		 	
		 	
		end)
		

		
	end)

	function STOPEVENT()
		hook.Remove("Think","LoadStuff")
		hook.Remove("RenderScreenspaceEffects","ScrEffScary")
		hook.Remove("PrePlayerDraw","Alone")
		hook.Remove("PreChatSound", "alone")
		hook.Remove("PlayerFootstep","alone")
		StopAllSounds()
		UNMeatEverything()
	end

	//////////////
	// MUSIC
	//////////////
	function StopAllSounds()
		for i,v in pairs(Metavent.URLMusics) do
			if v != nil and v.Station != nil then
				v.Station:Pause()
				v.Station:SetTime(0)
			end
		end
	end

	function LoadThink()
		
		if #Metavent.LoadingMusic <= 0 then 
			
			if !Metavent.LoadInit then
		
				Metavent.LoadInit = true
				
				net.Start("PreloadComplete")
				net.SendToServer()
				
				hook.Remove("Think","LoadStuff")
			end
			
			return 
		end
		
		if !Metavent.AlreadyLOADING then
			Metavent.AlreadyLOADING = true
			LoadSound(Metavent.LoadingMusic[1])
		end
		
	end

	net.Receive("PreloadSound",function()
		
		local id = net.ReadString()
		Metavent.IsLoading = true
		
		if Metavent.URLMusics[id] != nil then 
			print("Music " .. id .. " already loaded!")
			return 
		end
		
		local lodtb = {}
		lodtb.id = id
		lodtb.snd = net.ReadString()
		lodtb.vol = net.ReadDouble() or 1
		
		table.insert(Metavent.LoadingMusic,lodtb)
		
	end)
	
	function LoadSound(dt)
		
		local id = dt.id
		local snd = dt.snd
		local vol = dt.vol
		
		sound.PlayURL (snd, "noblock noplay", function( station )
    			if IsValid( station ) then
    				
    				if Metavent.URLMusics[id] != nil then
    					if Metavent.URLMusics[id].Station != nil then 
    						Metavent.URLMusics[id].Station:Stop()
    					end
					else
						Metavent.URLMusics[id] = {}
					end

    				Metavent.URLMusics[id].Station = station
    				Metavent.URLMusics[id].Volume = vol
    				Metavent.URLMusics[id].ID = id
    				
    			    print("Music " .. id .. " loaded!")
    			else
    				print("Failed to load Music " .. id)
    			end

    			table.remove(Metavent.LoadingMusic,1)
    			Metavent.AlreadyLOADING = false
	    end)
	
	end
	
	function StopLoad()
		Metavent.IsLoading = false
		
		if Metavent.LoadMusic != nil then
			Metavent.LoadMusic:Stop()	
		end
		
	end

	function MeatEverything()
		for _,v in pairs(game.GetWorld():GetMaterials()) do
			materials.ReplaceTexture(v,"models/flesh") 
		end
		
		materials.ReplaceTexture("metastruct_2/lobbyfloor","models/flesh")
		materials.ReplaceTexture("metastruct_2/tunnelplaster0","models/flesh")
		materials.ReplaceTexture("cs_italy/plasterwall0","models/flesh")
		materials.ReplaceTexture("concrete/concretefloor023","models/flesh")
		materials.ReplaceTexture("concrete/concretefloor039","models/flesh")
	end

	function UNMeatEverything()
		materials.RestoreAll()
	end

	function StopMusic(id)
	
		if Metavent.URLMusics[id] == nil then 
			print("Music Not Found!")
			return 
		end
		
		local Station = Metavent.URLMusics[id].Station
		
		if !Station:IsValid() then 
			print("Station not Found! Music could not be pre-loaded?")
			Metavent.URLMusics[id] = nil
			return 
		end
		
		Station:Pause()
		Station:SetTime(0)
		
	end
	
	function PlayMusic(id,override)
	
		if Metavent.URLMusics[id] == nil then 
			print("Music Not Found!")
			return 
		end
		
		local Station = Metavent.URLMusics[id].Station
		
		if !Station:IsValid() then 
			print("Station not Found! Music could not be pre-loaded?")
			Metavent.URLMusics[id] = nil
			return 
		end
		
		local Vol = Metavent.URLMusics[id].Volume or 1
		
		if override and Metavent.LastMusic != "" then
			StopMusic(Metavent.LastMusic)	
		end
		
		Station:Play()
		Station:SetVolume(Vol)
		
		Metavent.LastMusic = id
	end
	
	net.Receive("LightControl",function()
		
		Metavent.LightSettings[ "$pp_colour_brightness" ] = net.ReadDouble()
	    Metavent.LightSettings[ "$pp_colour_contrast" ] = net.ReadDouble() 
	    Metavent.LightSettings[ "$pp_colour_colour" ] = net.ReadDouble()

	end)
	
	net.Receive("SoundCommand",function()
		local msd = net.ReadString()
		if msd == "" then
			StopAllSounds()
		elseif msd == "shake" then
			util.ScreenShake( LocalPlayer():GetPos(), math.random(2,10), math.random(2,10), 5, 50000 )
        	surface.PlaySound("ambient/materials/rock"..math.random(2,3)..".wav")
        elseif msd == "boom" then
        	
        	timer.Create("alarm",2,math.random(3,4),function()
    			surface.PlaySound("ambient/alarms/doomsday_lift_alarm.wav")
    		end)
    		
    		timer.Simple(3,function()
        		surface.PlaySound("ambient/explosions/exp"..math.random(1,4)..".wav")
			end)
			
		elseif msd == "powerdown" then
			surface.PlaySound("ambient/energy/powerdown2.wav")
			surface.PlaySound("ambient/energy/newspark11.wav")
		elseif msd == "powerup" then
			surface.PlaySound("ambient/explosions/explode_"..math.random(1,9)..".wav")
		elseif msd == "screenS" then
			Metavent.INSIDE = true
			MeatEverything()
		elseif msd == "screenSk_static" then
			Metavent.Static = true
			PlayMusic("static",false)
			
			timer.Simple(0.5,function()
				Metavent.Static = false
				StopMusic("static")
			end)
			
		elseif msd == "END" then
			STOPEVENT()
		elseif msd == "spark" then
			DoLightSpark()
		else
			StopMusic(msd)		
		end
	end)
	
	net.Receive("PlayWebMusic",function()
		
		local Music = net.ReadString()
		local Ovr = net.ReadBool()
		
		PlayMusic(Music,Ovr)
		
	end)

	function DoLightSpark()
		
		Metavent.SparkIndx = 1
		Metavent.LightPos = table.Shuffle(Metavent.LightPos)
		
		if timer.Exists("Spark") then timer.Destroy("Spark") end
		
		timer.Create("Spark",0.1,#Metavent.LightPos,function()
			--fuse_sparks
			local Pos = Metavent.LightPos[Metavent.SparkIndx].Pos
			ParticleEffect( "rd_bot_impact_sparks", Pos, Angle(0,0,0), NULL )
			
			EmitSound("ambient/energy/newspark0"..math.random(1,9)..".wav",Pos,0,CHAN_AUTO,0.3,0,0,100)
			Metavent.SparkIndx = Metavent.SparkIndx + 1
			
		end)
		
	end
	
end
