// By Failcake: https://failcake.me
// =======================================

easylua.StartEntity("hrock")

ENT.PrintName		= "Rock"
ENT.Author			= "FailCake"
ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	
	if SERVER then
			
		self:SetModel("models/props_coalmines/boulder"..math.random(1,3)..".mdl")
		self:SetMaterial("models/xqm/rails/gumball_1.mdl")
		
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_OBB )
		self:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
		self.PhysgunDisabled = true
		
		self:SetTrigger( true )
	
		local phys = self:GetPhysicsObject()
		
		if IsValid(phys) then
			phys:Wake()
			phys:EnableMotion( false )
		end
		
	end
	
end

function ENT:Touch( ent )
	if !IsValid(ent) then return end
	if ent:GetClass() != "hball" then return end
	
	local Spd = ent:GetVelocity():Length()
	
	if Spd > 200 then
		self:EmitSound("physics/glass/glass_largesheet_break"..math.random(1,3)..".wav")
		self:Remove()
	end
	
end

easylua.EndEntity()

easylua.StartEntity("hball")

ENT.PrintName		= "Ball"
ENT.Author			= "FailCake"
ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	

	if SERVER then
			
		self:SetModel("models/hunter/misc/sphere175x175.mdl")
		self:SetMaterial("models/props_halloween/hwn_kart_ball01.mdl")
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:SetColor(Color(255,255,255,130))
			
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_OBB )
		self:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
		self.PhysgunDisabled = true
		
		self:SetTrigger( true )
		self.LastTouch = 0
	
		local phys = self:GetPhysicsObject()
		
		if IsValid(phys) then
			phys:Wake()
			phys:SetMass(500)
			phys:EnableMotion( false )
		end
		
	end
	
end

function ENT:SetMotion( blo )
	if !IsValid(self) then return end
	local phys = self:GetPhysicsObject()
	if !IsValid(phys) then return end
	
	phys:EnableMotion(blo)
	
end

function ENT:Touch( ent )
	
	if !IsValid(ent) or !IsValid(self) then return end
	if ent:GetClass() != "hball" then return end
	
	if CurTime() < self.LastTouch or CurTime() < ent.LastTouch then return end
	
	local vel_ent = ent:GetVelocity()
	local vel_loc = self:GetVelocity()
	
	local py_self = self:GetPhysicsObject()
	if !IsValid(py_self) then return end
	
	if vel_ent:Length() > vel_loc:Length() then
		py_self:AddVelocity(vel_ent)
	end
	
	self:EmitSound("garrysmod/balloon_pop_cute.wav")
	self.LastTouch = CurTime() + 0.3
	ent.LastTouch = CurTime() + 0.3
	
end

easylua.EndEntity()



Tag = "CakeFreeze"

CakeFreeze = CakeFreeze or {}
CakeFreeze.MinPlayers = 2
CakeFreeze.MaxPlayers = 6

CakeFreeze.BaseModel = "models/hunter/plates/plate16x16.mdl"
CakeFreeze.WaterModel = "models/hunter/plates/plate32x32.mdl"

CakeFreeze.Room = easylua.FindEntity("vphysl")

CakeFreeze.Players = {me,nak}
CakeFreeze.OriginalPlayers = {}

CakeFreeze.BANList = {"STEAM_0:1:32471837","STEAM_0:0:37146091","STEAM_0:1:46743640"}
CakeFreeze.WhiteList = {}
CakeFreeze.Base = NULL

CakeFreeze.SpawnLocs = {
	Vector(-2436.823730,2709.277344,-15451.458008),
	Vector(-1894.511475,3263.643311,-15451.582031),
	Vector(-1887.156128,2766.393555,-15451.351563),
	Vector(-2397.855225,3254.849365,-15451.486328),
	Vector(-1846.038208,2989.753174,-15451.487305),
	Vector(-2168.514160,2678.773193,-15451.446289),
	Vector(-2496.398193,3032.967285,-15451.492188),
	Vector(-2144.196533,3337.405518,-15451.526367)
}

CakeFreeze.SpawnLocsCopy = {}

CakeFreeze.Props = CakeFreeze.Props or {}

CakeFreeze.IsPlaying = false
CakeFreeze.IsLoading = false
CakeFreeze.LoadingPlys = {}

CakeFreeze.Walls = {
	{pos = Vector(-2474.5632324219,2669.16015625,-15511.676757812),ang = Angle(1.122239576116e-13,64.952865600586,1.52587890625e-05)},
	{pos = Vector(-2527.2478027344,2698.9626464844,-15511.676757812),ang = Angle(7.8612470537105e-14,45.548900604248,1.52587890625e-05)},
	{pos = Vector(-2545.9445800781,2762.9741210938,-15511.676757812),ang = Angle(6.9960363347158e-16,1.592991232872,1.52587890625e-05)},
	{pos = Vector(-2554.2141113281,2830.7202148438,-15511.676757812),ang = Angle(4.910613795884e-15,-1.3770617246628,1.52587890625e-05)},
	{pos = Vector(-2555.4814453125,2906.4670410156,-15511.676757812),ang = Angle(4.910613795884e-15,-1.3770617246628,1.52587890625e-05)},
	{pos = Vector(-2556.5971679688,2983.234375,-15511.676757812),ang = Angle(5.145697033076e-14,-6.9210062026978,1.52587890625e-05)},
	{pos = Vector(-2554.9245605469,3056.0795898438,-15511.676757812),ang = Angle(-1.230231393746e-15,-0.78305381536484,1.52587890625e-05)},
	{pos = Vector(-2554.8835449219,3135.12890625,-15511.676757812),ang = Angle(3.7102618069898e-15,-1.3770478963852,1.52587890625e-05)},
	{pos = Vector(-2555.7998046875,3195.1423339844,-15511.676757812),ang = Angle(-2.267832883968e-15,-1.1790409088135,1.52587890625e-05)},
	{pos = Vector(-2555.6669921875,3259.1354980469,-15511.676757812),ang = Angle(2.2120487340178e-14,-5.931079864502,1.52587890625e-05)},
	{pos = Vector(-2550.6325683594,3313.9621582031,-15511.676757812),ang = Angle(6.1697020139562e-15,-10.683032989502,1.52587890625e-05)},
	{pos = Vector(-2521.2993164062,3353.7895507812,-15511.676757812),ang = Angle(8.660729604185e-14,-44.639995574951,1.52587890625e-05)},
	{pos = Vector(-2457.0539550781,3380.5793457031,-15511.676757812),ang = Angle(-2.9153112215963e-13,-87.902969360352,1.52587890625e-05)},
	{pos = Vector(-2391.0419921875,3383.4438476562,-15511.676757812),ang = Angle(-1.2145198854865e-13,-92.754005432129,1.52587890625e-05)},
	{pos = Vector(-2329.4194335938,3386.08203125,-15511.676757812),ang = Angle(-4.0417184031007e-13,-90.081031799316,1.52587890625e-05)},
	{pos = Vector(-2262.8071289062,3388.703125,-15511.676757812),ang = Angle(-4.0417184031007e-13,-90.081031799316,1.52587890625e-05)},
	{pos = Vector(-2190.1391601562,3391.5622558594,-15511.676757812),ang = Angle(-4.0417184031007e-13,-90.081031799316,1.52587890625e-05)},
	{pos = Vector(-2129.5825195312,3393.9453125,-15511.676757812),ang = Angle(-4.0417184031007e-13,-90.081031799316,1.52587890625e-05)},
	{pos = Vector(-2053.2749023438,3388.8056640625,-15511.676757812),ang = Angle(2.6581013323583e-13,-88.893043518066,1.52587890625e-05)},
	{pos = Vector(-2000.3426513672,3385.2102050781,-15511.676757812),ang = Angle(-1.7830115368097e-13,-91.467018127441,1.52587890625e-05)},
	{pos = Vector(-1935.1950683594,3385.998046875,-15511.676757812),ang = Angle(-1.7830115368097e-13,-91.467018127441,1.52587890625e-05)},
	{pos = Vector(-1861.9012451172,3374.6882324219,-15511.676757812),ang = Angle(8.5901582071515e-14,-123.1470489502,1.52587890625e-05)},
	{pos = Vector(-1836.2645263672,3312.2204589844,-15511.676757812),ang = Angle(-3.5940488866265e-15,-179.57702636719,1.52587890625e-05)},
	{pos = Vector(-1832.8370361328,3240.7751464844,-15511.676757812),ang = Angle(6.4910116805194e-15,178.64094543457,1.52587890625e-05)},
	{pos = Vector(-1831.4947509766,3169.21484375,-15511.676757812),ang = Angle(-2.8168466060933e-15,179.2349395752,1.52587890625e-05)},
	{pos = Vector(-1832.6412353516,3103.650390625,-15511.676757812),ang = Angle(2.9666657703971e-15,177.45294189453,1.52587890625e-05)},
	{pos = Vector(-1833.4051513672,3036.6108398438,-15511.676757812),ang = Angle(-7.1858395834156e-15,178.04693603516,1.52587890625e-05)},
	{pos = Vector(-1833.8135986328,2972.5981445312,-15511.676757812),ang = Angle(-1.395073936743e-14,177.84893798828,1.52587890625e-05)},
	{pos = Vector(-1831.6325683594,2913.1535644531,-15511.676757812),ang = Angle(-2.8168466060933e-15,179.2349395752,1.52587890625e-05)},
	{pos = Vector(-1830.4271240234,2848.3864746094,-15511.676757812),ang = Angle(6.4910116805194e-15,178.64094543457,1.52587890625e-05)},
	{pos = Vector(-1829.8958740234,2791.552734375,-15511.676757812),ang = Angle(6.3565295300332e-15,176.66093444824,1.52587890625e-05)},
	{pos = Vector(-1834.1379394531,2731.8166503906,-15511.676757812),ang = Angle(-7.2557872253867e-14,165.96894836426,1.52587890625e-05)},
	{pos = Vector(-1866.13671875,2680.8178710938,-15511.676757812),ang = Angle(-6.2560755729503e-14,124.98293304443,1.52587890625e-05)},
	{pos = Vector(-1923.6853027344,2676.900390625,-15511.676757812),ang = Angle(-2.4157748284431e-13,91.718948364258,1.52587890625e-05)},
	{pos = Vector(-1988.8278808594,2672.373046875,-15511.676757812),ang = Angle(3.7112416547032e-13,88.748970031738,1.52587890625e-05)},
	{pos = Vector(-2049.4233398438,2671.23046875,-15511.676757812),ang = Angle(3.7112416547032e-13,88.748970031738,1.52587890625e-05)},
	{pos = Vector(-2106.9892578125,2670.1450195312,-15511.676757812),ang = Angle(3.7112416547032e-13,88.748970031738,1.52587890625e-05)},
	{pos = Vector(-2173.64453125,2668.8881835938,-15511.676757812),ang = Angle(3.7112416547032e-13,88.748970031738,1.52587890625e-05)},
	{pos = Vector(-2235.7551269531,2667.7170410156,-15511.676757812),ang = Angle(3.7112416547032e-13,88.748970031738,1.52587890625e-05)},
	{pos = Vector(-2298.8120117188,2665.5229492188,-15511.676757812),ang = Angle(-2.6513814472932e-13,90.035995483398,1.52587890625e-05)},
	{pos = Vector(-2356.318359375,2666.380859375,-15511.676757812),ang = Angle(2.0355447199766e-13,90.134979248047,1.52587890625e-05)},
	{pos = Vector(-2414.1457519531,2663.9880371094,-15511.676757812),ang = Angle(-3.3943532121335e-13,89.936988830566,1.52587890625e-05)}
}

CakeFreeze.WallsCrt = CakeFreeze.WallsCrt or {} 
CakeFreeze.Winners = {}


CakeFreeze.PlayerModels = {
    "models/player/group01/female_01.mdl",
    "models/player/group01/female_02.mdl",
    "models/player/group01/female_03.mdl",
    "models/player/group01/female_04.mdl",
    "models/player/group01/female_05.mdl",
    "models/player/group01/female_06.mdl",
    "models/player/group01/male_01.mdl",
    "models/player/group01/male_02.mdl",
    "models/player/group01/male_03.mdl",
    "models/player/group01/male_04.mdl",
    "models/player/group01/male_05.mdl",
    "models/player/group01/male_06.mdl",
    "models/player/group01/male_07.mdl",
    "models/player/group01/male_08.mdl",
    "models/player/group01/male_09.mdl"}
	
	local plymeta = FindMetaTable( "Player" )
    if not plymeta then Error("FAILED TO FIND PLAYER TABLE") return end
    
if SERVER then
	
	// INIT
    
    util.AddNetworkString( "PreloadComplete" )
    util.AddNetworkString( "PreloadSound" )
    util.AddNetworkString( "ldFinished" )
    
    util.AddNetworkString( "PlayWebMusic" )
    util.AddNetworkString( "StartClientside" )
    util.AddNetworkString( "SoundCommand" )
    
    util.AddNetworkString( "Voting" )
    
    util.AddNetworkString( "StartMinigame_cf" )
    
    util.AddNetworkString( "AnnouncePlayer" )
    util.AddNetworkString( "WinningPlys" )
    
    // PLAYER
    
    // "" = Stop ALL
    // "idblabla" = Stop This
    function plymeta:StopMusic(id)
    	net.Start("SoundCommand")
    		net.WriteString(id)
    	net.Send(self)
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
	
	function plymeta:preloadMusic(id,url,loop,vol)
		net.Start("PreloadSound")
			net.WriteString(id)
			net.WriteString(url)
			net.WriteBool(loop)
			net.WriteDouble(vol)
		net.Send(self)
	end
	
	function plymeta:AnnounceSingle(msg,msc)
		net.Start("AnnouncePlayer")
            net.WriteString(msg)
            net.WriteString(msc)
        net.Send(self)
	end
    
    function plymeta:TeleportPlayer()
    	
    	if !IsValid(self) then return end
    	
    	local Ball = self:GetBall()
    	if !IsValid(Ball) then return end
    		
    	if #CakeFreeze.SpawnLocsCopy <= 0 then 
    		local ps = CakeFreeze.SpawnLocs[math.random(1,#CakeFreeze.SpawnLocs)]
    		self:SetPos(ps) 
    		Ball:SetPos(ps + Vector(0,0,50))
    			
    		local psoff = Vector(-2195.818115,3001.283691,-15457.088867) - self:GetPos()
    		self:SetEyeAngles(psoff:Angle())
    		
    		return
    	end
    	
    	local rnd = math.random(1,#CakeFreeze.SpawnLocsCopy)
    	local pos = CakeFreeze.SpawnLocsCopy[rnd]
    	
    	self:SetPos(pos)
		Ball:SetPos(pos + Vector(0,0,50))
			
		local psoff = Vector(-2195.818115,3001.283691,-15457.088867) - self:GetPos()
    	self:SetEyeAngles(psoff:Angle())
		
		
    	table.remove(CakeFreeze.SpawnLocsCopy,rnd)
    		
    end
    
    
    function plymeta:RestrainPlayer()
    	
    	if self:GetNWBool("RestrictedMg") then return end
    	
    	self:Spawn()
    	    	
    	self:SetNWBool("RestrictedMg",true)
    	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
    	
        self:ShouldDropWeapon( false )
        self:StripWeapons()
        self:Give("hands")
            
        self:ExitVehicle()
        self:GodDisable()
        
        self:SetSolid(2)

 
        self:SetNWBool("HideNames",true)
        self:SetNWBool("HideTyping",true)
        self:SetColor(Color(255,255,255,255))
        
        self:SprintDisable()
        
        self.BoostCD = 0
        
        self:ExitVehicle()
        
        // Disable Thirdperson
        self:SendLua([[ctp:Disable()]])
        
        self:Freeze(true)
        
        self:ConCommand("r_cleardecals")
        self:SetMoveType(MOVETYPE_WALK)
  
        self:SetAllowNoclip(false, Tag)
        self:SetAllowBuild(false, Tag)
        self:SetSuperJumpMultiplier(0,false) // Anti-bhop
        
        self:SetAllowNoclip(false,"CakeFreeze")
        self:SetAllowBuild(false, "CakeFreeze")
        
        self.canWATT = false
        self.nossjump = true
        self.noleap = true
        self.last_rip = 99999999
        self.double_jump_allowed = false
        self.DisableSit = true
        
        self:SetHealth(100)
        
        self:StripAmmo()
        
        Watt.Enabled = false
        
        self:SetWalkSpeed(400)
        self:SetRunSpeed(400)
        self:SetJumpPower(0)
        self:CrosshairDisable()
        
    end
    
    function plymeta:ReleasePlayer()
    	
    	if !self:GetNWBool("RestrictedMg") then return end
    	
    	self:SetNWBool("RestrictedMg",false)
    	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
    	
    	self:SetAllowNoclip(true, Tag)
        self:SetAllowBuild(true, Tag)
        
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
        
        self.last_rip = CurTime()
        
        self:ShouldDropWeapon( false )
        self:StripWeapons()
        
        hook.Call("PlayerLoadout",self)
        
        self:SetAllowNoclip(true,"CakeFreeze")
        self:SetAllowBuild(true, "CakeFreeze")
        
        Watt.Enabled = true
        
        local OldModel = self.OldModel or ""
        
        if OldModel != "" then
            pac.SetPlayerModel(self,self.OldModel) 
        end
    end
    
    function plymeta:CreateBall()
    	
    	if !IsValid(self) then return end
    	if IsValid(self.Ball) then self.Ball:Remove() end
    	
    	self.Ball = ents.Create("hball")
    	self.Ball:SetPos(Vector(0,0,0)) // For now
    	self.Ball:Spawn()
    	
    	self.Ball:SetMotion(false)
    	
		self:SetNWEntity("ballEnt",self.Ball)
    	
    end
    
    function plymeta:GetBall()
    	return self.Ball or NULL
    end
    
    function plymeta:PlayerLost()
    	
    	local Ball = self:GetBall()
    	
    	if IsValid(Ball) then
    		
	    	local vPoint = Ball:GetPos()
	    	
			local effectdata = EffectData()
			effectdata:SetOrigin( vPoint )
			effectdata:SetStart(Vector(255,255,255))
			util.Effect( "balloon_pop", effectdata )	
			
			Ball:EmitSound("weapons/ar2/npc_ar2_altfire.wav")
			
		end
		
		self:RemoveBall()
		self:ReleasePlayer()
        self:KillSilent()
        				
        net.Start("SoundCommand")
			net.WriteString("ENDHOOKS") // Use same network
		net.Send(self)
			    		
		table.RemoveByValue(CakeFreeze.Players,self)
		AnnounceGame(self:RealNick().." lost!","")
    end
    
    function plymeta:RemoveBall()
    	if !IsValid(self) then return end
    	if IsValid(self.Ball) then 
    		
    		self:SetNWEntity("ballEnt",NULL)
    		self.Ball:Remove() 
    		
    	end
    end

    // GAME
    function StartFreezeVote()
        
       table.Empty(CakeFreeze.Players)
       
       net.Start("Voting")
       	net.WriteBool(false)
       net.Broadcast()
       
       local Title = "Play CakeFreeze minigame? (Max Players -> "..CakeFreeze.MaxPlayers.." | Min Time : 13h)"
       
       GVote.Vote(Title,
				"Yes",
				"No",
		function(results)
		    
			local Ys = results.Yes
			local No = results.No
				
		    for i,v in pairs(Ys) do
		        if !table.HasValue(CakeFreeze.WhiteList,v) then
		        	table.insert(CakeFreeze.WhiteList,v)
		        end
	        end
	    
	        if #Ys <= 0 then
	            print("[CakeFreeze] Not enough players :<! ABORTED")
	            return
	        end
			
			timer.Simple(5,function()
				
				net.Start("Voting")
		       		net.WriteBool(true)
		       	net.Broadcast()
				
			    INITMinigame()
			    
			end)  
			
		end)
		
		timer.Simple(0.1,function()
			GVote.CurrentVote:AddTime(-15)
		end)
		
    end
    
    function HideScreen(show)
        
        local fnd = ents.FindInSphere(Vector (-4304.5439453125, 3425.40625, -15807.130859375),50)
        for i,v in pairs(fnd) do
            if v:GetClass() == "lua_screen" then
                v:SetNoDraw(show)
            end
        end
         
    end
    
    function SetVPhysRoom(enabled)
        local trigger_vphys = ents.FindByClass("trigger_vphysics_motion")
        
        if enabled then
            trigger_vphys[1]:Fire('Enable')
            trigger_vphys[2]:Fire('Enable')
        else
            trigger_vphys[1]:Fire('Disable')
            trigger_vphys[2]:Fire('Disable')
        end
        
        for i,v in pairs(ents.FindInBox( Vector(-151.822952,775.692139,-15842.093750), Vector(-4230.739258,5300.753906,-13602.173828) )) do
            if !IsValid(v) then continue end
            if v:GetClass() == "prop_physics" then
                local phys = v:GetPhysicsObject()
                if IsValid( phys ) then
                    phys:AddVelocity( Vector( 0, 0, 0.1 ) ) // Give it a small push to set the vphys
                end
            end
        end
        
    end
    
    function CleanupMap()
        for i,p in pairs(ents.FindInBox(Vector(-144.563507,769.941833,-15850.163086), Vector(-4309.127441,5375.066406,-13562.069336))) do
            
            if IsValid(p) then
               if IsValid(p:CPPIGetOwner()) and p:CPPIGetOwner():SteamID() != "STEAM_0:1:20785590" then
                   print("[CakeFreeze] Invalid Prop found from ".. p:CPPIGetOwner():Name())
                   p:Remove()
               end 
            end
            
        end
    end
    
    function RemoveRocks()
    	for _,v in pairs(CakeFreeze.WallsCrt) do
    		if IsValid(v) then
    			v:Remove()
    		end
		end	
    end
    
    function CreateRocks()
    	
    	for _,v in pairs(CakeFreeze.WallsCrt) do
    		if IsValid(v) then
    			v:Remove()
    		end
		end
	
    	for _,v in pairs(CakeFreeze.Walls) do
	
    			local pos = v.pos
    			local ang = v.ang
    			
    			local wall = ents.Create("hrock")
    			
    			wall:SetPos(pos)
    			wall:SetAngles(ang)
    			wall:Spawn()
    			
    			table.insert(CakeFreeze.WallsCrt,wall)
    		
    	end
    	
    end
    
    function PrepareMap()
    	
    	for _,v in pairs(ents.FindByModel(CakeFreeze.WaterModel)) do
    		if IsValid(v) then
               if IsValid(v:CPPIGetOwner()) and v:CPPIGetOwner():SteamID() == "STEAM_0:1:20785590" then
               	v:SetSolid(0)
               	v:SetMaterial("models/shadertest/shader3")
               end
            end
    	end
    	
    	for _,v in pairs(ents.FindByModel(CakeFreeze.BaseModel)) do
    		if IsValid(v) then
               	if IsValid(v:CPPIGetOwner()) and v:CPPIGetOwner():SteamID() == "STEAM_0:1:20785590" then
               		v:SetSolid(SOLID_VPHYSICS)
               		v:SetCollisionGroup(COLLISION_GROUP_NONE)
               		v:SetMaterial("models/xqm/rails/gumball_1.mdl")
               		CakeFreeze.Base = v
           		end
           	end
    	end
    	
    	if IsValid(CakeFreeze.DoorProt) then CakeFreeze.DoorProt:Remove() end
        CakeFreeze.DoorProt = ents.Create("prop_physics")
        CakeFreeze.DoorProt:SetModel("models/hunter/plates/plate6x7.mdl")
        CakeFreeze.DoorProt:SetMaterial("models/props_lab/cornerunit_cloud")
        CakeFreeze.DoorProt:SetPos(Vector (-4251.192383,3036.774414,-15812.869141))
        CakeFreeze.DoorProt:SetAngles(Angle(90,0,0))
        CakeFreeze.DoorProt:Spawn()
        CakeFreeze.DoorProt.PhysgunDisabled = true
        
        local phys = CakeFreeze.DoorProt:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
        end

        // The Door
        local fnd = ents.FindInSphere(Vector(-4259.864258,3031.825928,-15790.468750),100)
        for i,v in pairs(fnd) do
            if v:GetClass() == "func_door" then
                v:Fire("Lock")
                v:Fire("Close")
            end
        end
    	
    	CleanupMap()
    	SetVPhysRoom(false)
    	HideScreen(true)
    	CreateRocks()
    	
    end
    
    function ExtractWalls()
    	print("==== Extraction Start ====")
    	
    	local Rocks = ents.FindByModel("models/props_coalmines/boulder3.mdl")
    	
    	for l,v in pairs(Rocks) do
    		if IsValid(v) then
               	if IsValid(v:CPPIGetOwner()) and v:CPPIGetOwner():SteamID() == "STEAM_0:1:20785590" then
               		local Pos = v:GetPos()
               		local Ang = v:GetAngles()
               		local Comm = ""
               		
               		if l < #Rocks then
               			Comm = ","
               		end
               		v:Remove()
               		print("{pos = Vector("..Pos.x..","..Pos.y..","..Pos.z.."),ang = Angle("..Ang.x..","..Ang.y..","..Ang.z..")}"..Comm)
               	end
            end
        end
        print("==== Extraction End ====")
    end
    
    function INITMinigame()
    	
        if #CakeFreeze.WhiteList <= 1 then
           print("[CakeFreeze] Not Enough whitelisted players! ABORTED!")
           return 
        end
        
        // Whitelist Players
        for i,v in pairs(player.GetAll()) do
            if !IsValid(v) then continue end
            if tonumber(v:GetUTime()) < 41715 then continue end // 13h min
            
            if #CakeFreeze.Players > CakeFreeze.MaxPlayers then
		    	print("[CakeFreeze] Max Players Limit Reached")
		    	break
		    end
            
            if table.HasValue(CakeFreeze.WhiteList,v:SteamID()) then
               if !table.HasValue(CakeFreeze.BANList,v:SteamID()) then
                  table.insert(CakeFreeze.Players,v) 
               else
                  print("[CakeFreeze] Player " .. v:RealNick() .. " is BANNED!")
                  v:ChatPrint( "[CakeFreeze] You are banned from the minigame! :C" )
               end
            end
        end
        
		table.Empty(CakeFreeze.Winners)
    	table.Empty(CakeFreeze.OriginalPlayers)
    	table.Empty(CakeFreeze.SpawnLocsCopy)
    	CakeFreeze.SpawnLocsCopy = table.Copy(CakeFreeze.SpawnLocs)
    	CakeFreeze.OriginalPlayers = table.Copy(CakeFreeze.Players)
    	
    	for _,v in pairs(CakeFreeze.Players) do
    		
    		if !IsValid(v) then continue end
    		
	    	net.Start("StartMinigame_cf")
	    		net.WriteTable(CakeFreeze.Players)
	    	net.Send(v)
	    	
	    	
	    	v:RestrainPlayer()
	    	v:CreateBall()
	   		v:TeleportPlayer()
    	end
    	
    	
		PrepareMap()
    	SetupHooks()
    	
    	LoadStuff()
    	
    end
    
    local Countdown = 3
    
    function StartMinigame()
    	
    	CakeFreeze.IsPlaying = true
		CakeFreeze.IsLoading = false
		
		RequestGlobal("ambient_".. math.random(1,6),true)
		
		for _,v in pairs(CakeFreeze.Players) do
			if !IsValid(v) then continue end
			v:GetBall():SetNoDraw(false)
		end
		
		timer.Simple(1,function()
			// Start Minigame
		
			Countdown = 3
			
			timer.Create("countdown",1,4,function()
				
				if Countdown > 0 then
					RequestGlobal("announce_"..Countdown,false)
					AnnounceGame("Game starting in ".. Countdown,"")
				else
					RequestGlobal("announce_go",false)
					AnnounceGame("GO GO GO!","")
					
					for _,v in pairs(CakeFreeze.Players) do
						if IsValid(v) then 
							v:Freeze(false)
							local Ball = v:GetBall()
							if IsValid(Ball) then
								Ball:SetMotion(true)
							end
						end
					end
					
					
				end
				
				Countdown = Countdown - 1
			end)
		end)
		
    end
    
    function LoadStuff()
    	
    	CakeFreeze.IsLoading = true
    	
    	for _,v in pairs(CakeFreeze.Players) do
    		if !IsValid(v) then continue end
    		
			v:preloadMusic("ambient_1","http://failcake.me/minigames/gmp_music_1.ogg",true,0.5)
			v:preloadMusic("ambient_2","http://failcake.me/minigames/gmp_music_2.ogg",true,0.5)
			v:preloadMusic("ambient_3","http://failcake.me/minigames/gmp_music_3.ogg",true,0.5)
			v:preloadMusic("ambient_4","http://failcake.me/minigames/gmp_music_4.ogg",true,0.5)
			v:preloadMusic("ambient_5","http://failcake.me/minigames/gmp_music_5.ogg",true,0.5)
			v:preloadMusic("ambient_6","http://failcake.me/minigames/gmp_music_6.ogg",true,0.5)

			v:preloadMusic("announce_3","http://failcake.me/minigames/bashannouncer_3.ogg",false,1)
			v:preloadMusic("announce_2","http://failcake.me/minigames/bashannouncer_2.ogg",false,1)
			v:preloadMusic("announce_1","http://failcake.me/minigames/bashannouncer_1.ogg",false,1)
			v:preloadMusic("announce_go","http://failcake.me/minigames/bashannouncer_go.ogg",false,1)
			
			v:preloadMusic("death","http://failcake.me/minigames/death.ogg",false,1)
			
			v:preloadMusic("winner_announce","http://failcake.me/minigames/winner.ogg",true,1)
			
    		table.insert(CakeFreeze.LoadingPlys,v)
    	end
    	
    	AnnounceGame("Loading Content.. please wait..","")

    end
    
    function RequestGlobal(id,over)
    	
    	for _,v in pairs(CakeFreeze.Players) do
    		if !IsValid(v) then continue end
    		
			net.Start("PlayWebMusic")
				net.WriteString(id)
				net.WriteBool(over)
			net.Send(v)
		end
    end
    
    function SetupHooks()
    	hook.Add("Think",Tag,function()
    		if !CakeFreeze.IsPlaying then return end
    		
    		// Dont let other players in
    		for v,i in pairs(ms.GetTrigger("vphys"):GetPlayers()) do
                if !IsValid(v) then continue end
        	    if !table.HasValue(CakeFreeze.Players,v) then
        	        v:SetPos(Vector(-4402.258789 + math.random(-100,100),3047.212891 + math.random(-100,100),-15827.968750)) 
        	        v:ChatPrint( "You are not allowed in the minigame." )
        	    end
            end
			
			if CakeFreeze.Base != NULL then
				CakeFreeze.Base:SetSolid(SOLID_VPHYSICS)
				CakeFreeze.Base:SetCollisionGroup(COLLISION_GROUP_NONE)
			end
			
			/*
			// ANTI-CHEAT
            
            for i,v in pairs(CakeFreeze.Players) do
               if !IsValid(v) then continue end
               
               if !ms.GetTrigger("vphys"):IsPlayerInside(v) then
                   v:AnnounceSingle("What were you doing outside!? GET BACK.","buttons/button11.wav")
                   v:TeleportPlayer()
    	           continue
            	end
        	end
        	*/
        	
        	CleanupMap()
        
        	for k,v in pairs(CakeFreeze.Players) do
        		
        		if !IsValid(v) then continue end
        		
        		local Ball = v:GetBall()
               	if !IsValid(Ball) then continue end // TODO KILL PLAYER
               		
        		local Pos = Ball:GetPos()
        		
        		if Pos.z <= -15791.968750 then
        			
        			if #CakeFreeze.Players <= 3 and #CakeFreeze.Winners <= 2 then
        				table.insert(CakeFreeze.Winners,v)
        				print("Added " .. v:Nick() .. " to a winning spot") 
        			end
        			
			    	v:PlayerLost()
        			continue
        		end
    		end
    		
    		
        	if #CakeFreeze.Players <= 1 then
        		-- END MINIGAME
        		table.insert(CakeFreeze.Winners,CakeFreeze.Players[1])
        		EndMinigame()
        	end
        	
        	
    	end)
    	
    	
    	hook.Add("PrePACConfigApply", Tag, function(ply, outfit_data)
            if table.HasValue(CakeFreeze.Players,ply) then
                return false, "No PAC Allowed in ScaryMode"
            end
        end)
        
        hook.Add("CanPlayerSuicide",Tag,function(ply)
            if table.HasValue(CakeFreeze.Players,ply) then
                return false
            end
        end)
    
        hook.Add("PlayerShouldTakeDamage",Tag,function(ply,attacker)
            if table.HasValue(CakeFreeze.Players,ply) then
                return false
            end
        end)
    
        hook.Add( "PlayerShouldTaunt", Tag, function( ply )
            if table.HasValue(CakeFreeze.Players,ply) then
                return false
            end
        end )
        
        hook.Add("PlayerCanPickupItem",Tag,function(ply,item)
            if table.HasValue(CakeFreeze.Players,ply) then
                return false
            end
        end) 
        
        hook.Add("PlayerCanPickupWeapon",Tag,function(ply,wep)
            if table.HasValue(CakeFreeze.Players,ply) then
                return false
            end
        end)
        
        hook.Add("CanDropWeapon",Tag,function(ply)
            if IsValid(ply) and ply:IsPlayer() then
                if table.HasValue(CakeFreeze.Players,ply) then
                    return false
                end
            end
        end)
        
        hook.Add("CanPlyTeleport",Tag,function(ply)
            if IsValid(ply) and ply:IsPlayer() then
                if table.HasValue(CakeFreeze.Players,ply) then
                    return false,"Teleport Disabled on CakeFreeze"
                end
            end
        end)
        
        hook.Add("CanPlyGotoLocations",Tag,function(ply)
            if IsValid(ply) and ply:IsPlayer() then
                if table.HasValue(CakeFreeze.Players,ply) then
                    return false,"Goto Disabled on CakeFreeze"
                end
            end
        end)

        hook.Add("CanPlyGotoPly",Tag,function(ply,ent)
            if IsValid(ply) and ply:IsPlayer() then
                if table.HasValue(CakeFreeze.Players,ply) then
                    return false,"Goto Disabled on CakeFreeze"
                end
            end
        end)
        
        hook.Add("PlayerDisconnected",Tag,function(ply)
    		if IsValid(ply) and table.HasValue(CakeFreeze.Players,ply) then
    			if CakeFreeze.IsLoading then
    				if table.HasValue(CakeFreeze.LoadingPlys,ply) then
    					
    					table.RemoveByValue(CakeFreeze.LoadingPlys,ply)
    					print("[CakeFreeze] Aborted ".. ply:Name() .. " load.")
    					
    				end
    			end
    		end
    	end)
    
	end

	function AnnounceGame(strs,scary)
        
        for i,v in pairs(CakeFreeze.OriginalPlayers) do
            if !IsValid(v) then continue end
            net.Start("AnnouncePlayer")
                net.WriteString(strs)
                net.WriteString(scary)
            net.Send(v)
        end
    end

	function ClearHooks()
		
		hook.Remove("Think",Tag)
		
		hook.Remove("PrePACConfigApply", Tag)
		hook.Remove("CanPlyGotoPly", Tag)
		hook.Remove("CanPlyGotoLocations", Tag)
		hook.Remove("CanDropWeapon", Tag)
		hook.Remove("PlayerCanPickupWeapon", Tag)
		
		hook.Remove("PlayerCanPickupItem", Tag)
		hook.Remove("PlayerShouldTaunt", Tag)
		hook.Remove("PlayerShouldTakeDamage", Tag)
		hook.Remove("CanPlyTeleport",Tag)
		
		hook.Remove("CanPlayerSuicide", Tag)
		hook.Remove("PlayerDisconnected", Tag)
		
	end
    
    function EndMinigame()
    	
    	if IsValid(CakeFreeze.DoorProt) then CakeFreeze.DoorProt:Remove() end
    	
    	CakeFreeze.IsPlaying = false

    	for _,v in pairs(CakeFreeze.OriginalPlayers) do
    		if !IsValid(v) then continue end
    	
    		v:RemoveBall()
    		v:ReleasePlayer()
    		
	    	net.Start("SoundCommand")
	    		net.WriteString("ENDHOOKS") // Use same network
	    	net.Send(v)
    	end
    	   

    	ClearHooks()
    	SetVPhysRoom(true)
    	HideScreen(false)
    	RemoveRocks()
    	
    	 // The Door
        local fnd = ents.FindInSphere(Vector(-4259.864258,3031.825928,-15790.468750),100)
        for i,v in pairs(fnd) do
            if v:GetClass() == "func_door" then
                v:Fire("Unlock")
                v:Fire("Open")
            end
        end
    	
    	if #CakeFreeze.Winners > 0 then
    		for _,v in pairs(CakeFreeze.OriginalPlayers) do
    			if !IsValid(v) then continue end
    			
	    		net.Start("WinningPlys")
	    			net.WriteTable(CakeFreeze.Winners)
	    		net.Send(v)
    		end
    	end
    	
    end
    
    
    net.Receive("PreloadComplete",function(len,ply)
    	
    	if !IsValid(ply) or !ply:IsPlayer() then return end
    	
		print(ply:Name() .. " finished loading.")
		table.RemoveByValue(CakeFreeze.LoadingPlys,ply)
		
		for _,v in pairs(CakeFreeze.Players) do
			if !IsValid(v) then continue end
			net.Start("ldFinished")
			net.Send(v)
		end
		
		if #CakeFreeze.LoadingPlys <= 0 then
			
			print("Finished Loading.")
			
			timer.Simple(3,function()
				
				net.Start("StartClientside")
				net.Broadcast()
				
				StartMinigame()
				
			end)
		
		end
		
	end)
    
end

if CLIENT then
	
	CakeFreeze.URLMusics = CakeFreeze.URLMusics or {}
	CakeFreeze.Players = CakeFreeze.Players or {}
	CakeFreeze.LoadingMusic = {}
	CakeFreeze.AlreadyLOADING = false
	
	// Load Stuff
	CakeFreeze.LastMusic = ""
	CakeFreeze.LoadInit = false
	
	CakeFreeze.WaitingPlys = false
	CakeFreeze.IsLoading = false
	
	CakeFreeze.Countdown = 0
	CakeFreeze.Winners = {}
	
	CakeFreeze.HINT = ""
	CakeFreeze.HINTS = {
	"Push Players off the platform to win!",
	"Shift gives you a boost, but its hard to control",
	"Minigame based on Crashbash!"
	}
	
	surface.CreateFont( "LoadFont",
	{
			font		= "Roboto",
			size		= ScreenScale(56),
			weight		= 1000
	}) 

	surface.CreateFont( "WinLb",
	{
			font		= "DebugFixed",
			size		= ScreenScale(12),
			weight		= 1000
	}) 

	surface.CreateFont( "LoadFont_small",
	{
			font		= "Roboto",
			size		= ScreenScale(12),
			weight		= 1000,
			blurred 	= true
	}) 

	surface.CreateFont( "NameTag",
		{
		 font = "Roboto",
		 size		= ScreenScale(54),
		 weight		= 400,
		 antialias = true,
		 additive = true
		} )
		
	surface.CreateFont( "NameTag_Blur",
		{
		 font = "Roboto",
		 size		= ScreenScale(54),
		 weight		= 400,
		 blursize = 4,
		 antialias = true
		} )
	
	
	function ShowWinner()
		
			if #CakeFreeze.Winners < 0 then return end
			
			local Winner_1 = CakeFreeze.Winners[#CakeFreeze.Winners] or NULL
			local Winner_2 = CakeFreeze.Winners[#CakeFreeze.Winners - 1] or NULL
			local Winner_3 = CakeFreeze.Winners[#CakeFreeze.Winners - 2] or NULL
			
			if IsValid(CakeFreeze.PANEL) then CakeFreeze.PANEL:Remove() end
			
			CakeFreeze.PANEL = vgui.Create("DFrame")
			CakeFreeze.PANEL:SetSize( 300, 400 ) 
			CakeFreeze.PANEL:SetTitle( ".: CakeFreeze - Winners :." ) 
			CakeFreeze.PANEL:SetVisible( true ) 
			CakeFreeze.PANEL:SetDraggable( false ) 
			CakeFreeze.PANEL:ShowCloseButton( false ) 
			CakeFreeze.PANEL:MakePopup() 
			CakeFreeze.PANEL:Center()

			CakeFreeze.PANEL.Sheet = CakeFreeze.PANEL:Add("DPanel")
			CakeFreeze.PANEL.Sheet:Dock(LEFT)
			CakeFreeze.PANEL.Sheet:SetSize(290, 0)
			CakeFreeze.PANEL.Sheet:SetPos(5, 0)
			
			CakeFreeze.PANEL.LaW_1 = CakeFreeze.PANEL:Add("DLabel")
			CakeFreeze.PANEL.LaW_1:SetText( "First Place" )
			CakeFreeze.PANEL.LaW_1:SetFont("WinLb")
			CakeFreeze.PANEL.LaW_1:SizeToContents() 
			CakeFreeze.PANEL.LaW_1:SetColor(Color(255,180,0))
			CakeFreeze.PANEL.LaW_1:SetPos(142 / 2,30)

			local VaP = (300 / 2 ) - 32
			
			CakeFreeze.PANEL.Avatar_1 = CakeFreeze.PANEL:Add("AvatarImage")
			CakeFreeze.PANEL.Avatar_1:SetSize( 64, 64 )
			CakeFreeze.PANEL.Avatar_1:SetPos( VaP, 70 )
			CakeFreeze.PANEL.Avatar_1:SetPlayer( Winner_1, 64 )
			
			CakeFreeze.PANEL.Avatar_1_name = CakeFreeze.PANEL:Add("DLabel")
			CakeFreeze.PANEL.Avatar_1_name:SetText( Winner_1:RealNick() )
			CakeFreeze.PANEL.Avatar_1_name:SetFont("TargetIDSmall")
			CakeFreeze.PANEL.Avatar_1_name:SizeToContents() 
			CakeFreeze.PANEL.Avatar_1_name:SetColor(Color(255,255,255))
				
			local x,y,w,h = CakeFreeze.PANEL.Avatar_1_name:GetBounds()
			CakeFreeze.PANEL.Avatar_1_name:SetPos(VaP + 32 - w / 2,115)
			
			if IsValid(Winner_2) then
				
				
				CakeFreeze.PANEL.LaW_2 = CakeFreeze.PANEL:Add("DLabel")
				CakeFreeze.PANEL.LaW_2:SetText( "Second Place" )
				CakeFreeze.PANEL.LaW_2:SetFont("WinLb")
				CakeFreeze.PANEL.LaW_2:SizeToContents() 
				CakeFreeze.PANEL.LaW_2:SetColor(Color(90,90,90))
				CakeFreeze.PANEL.LaW_2:SetPos(50,130)
				
				CakeFreeze.PANEL.Avatar_2 = CakeFreeze.PANEL:Add("AvatarImage")
				CakeFreeze.PANEL.Avatar_2:SetSize( 64, 64 )
				CakeFreeze.PANEL.Avatar_2:SetPos( VaP, 170 )
				CakeFreeze.PANEL.Avatar_2:SetPlayer( Winner_2, 64 )
				
				CakeFreeze.PANEL.Avatar_2_name = CakeFreeze.PANEL:Add("DLabel")
				CakeFreeze.PANEL.Avatar_2_name:SetText( Winner_2:RealNick() )
				CakeFreeze.PANEL.Avatar_2_name:SetFont("TargetIDSmall")
				CakeFreeze.PANEL.Avatar_2_name:SizeToContents() 
				CakeFreeze.PANEL.Avatar_2_name:SetColor(Color(255,255,255))
					
				local x2,y2,w2,h2 = CakeFreeze.PANEL.Avatar_2_name:GetBounds()
				CakeFreeze.PANEL.Avatar_2_name:SetPos(VaP + 32 - w2 / 2,210)
				
			end
			
			if IsValid(Winner_3) then
				
				CakeFreeze.PANEL.LaW_3 = CakeFreeze.PANEL:Add("DLabel")
				CakeFreeze.PANEL.LaW_3:SetText( "Third Place" )
				CakeFreeze.PANEL.LaW_3:SetFont("WinLb")
				CakeFreeze.PANEL.LaW_3:SizeToContents() 
				CakeFreeze.PANEL.LaW_3:SetColor(Color(205, 127, 50))
				CakeFreeze.PANEL.LaW_3:SetPos(65,230)
				
				CakeFreeze.PANEL.Avatar_3 = CakeFreeze.PANEL:Add("AvatarImage")
				CakeFreeze.PANEL.Avatar_3:SetSize( 64, 64 )
				CakeFreeze.PANEL.Avatar_3:SetPos( VaP, 270 )
				CakeFreeze.PANEL.Avatar_3:SetPlayer( Winner_3, 64 )
				
				CakeFreeze.PANEL.Avatar_3_name = CakeFreeze.PANEL:Add("DLabel")
				CakeFreeze.PANEL.Avatar_3_name:SetText( Winner_3:RealNick() )
				CakeFreeze.PANEL.Avatar_3_name:SetFont("TargetIDSmall")
				CakeFreeze.PANEL.Avatar_3_name:SizeToContents() 
				CakeFreeze.PANEL.Avatar_3_name:SetColor(Color(255,255,255))
					
				local x3,y3,w3,h3 = CakeFreeze.PANEL.Avatar_3_name:GetBounds()
				CakeFreeze.PANEL.Avatar_3_name:SetPos(VaP + 32 - w3 / 2,310)
				
			end
			
				CakeFreeze.PANEL.Close = CakeFreeze.PANEL:Add("DButton")
				CakeFreeze.PANEL.Close:SetSize(290, 45)
				CakeFreeze.PANEL.Sheet:Dock(LEFT)
				CakeFreeze.PANEL.Close:SetPos(5, 350)
				CakeFreeze.PANEL.Close:SetText("Close")
				CakeFreeze.PANEL.Close:SetTextColor(Color(1, 1, 1))
				CakeFreeze.PANEL.Close.DoClick = function()
					CakeFreeze.PANEL:Remove()
					StopAllSounds()
				end
	end
	
	net.Receive( "StartMinigame_cf", function()
		
		CakeFreeze.Players = net.ReadTable() or {}
		CakeFreeze.Countdown = 4
		
		table.Empty(CakeFreeze.Winners)
		
		hook.Add('PlayerBindPress',Tag,function(_,bind,pressed)
        	if string.find(bind,"gm_showspare1",1,true) and pressed then
        		return true
        	end
        end)
        
        hook.Add("HUDDrawTargetID",Tag,function()
            return false
        end)
        
        hook.Add("HUDShouldDraw",Tag,HideHUD)
        
       	//////////////
		// THIRDPERSON
		//////////////
	
		hook.Add("ShouldDrawLocalPlayer",Tag,function()
			return true
		end)
	
		// setpos -2714.120117 3009.284912 -15085.893555;setang 40.291756 -0.378350 0.000000
		hook.Add("CalcView", Tag, function(ply,pos,angles,fov)
			
			if !IsValid(ply) then return end 
			if ply:GetNWEntity("ballEnt") == NULL then return end
			
			local Ball = ply:GetNWEntity("ballEnt")
			local view = {}
			
			view.origin = Ball:GetPos() - (angles:Forward()*300)
			view.angles = angles
			--view.origin = Vector(-2714,3009,-15085)
	    	--view.angles = Angle(40,0,0)
	    	--view.origin = Vector(-2224.272461,3022.104492,-14735.826172)
	    	--view.angles = Angle(90,0,0)
			view.fov = fov
			
	    	return view
	    	
		end)

		// BALL
		hook.Add("PrePlayerDraw",Tag,function(ply)
			
			if !IsValid(ply) then return end
			if ply:GetNWEntity("ballEnt") == NULL then return end
			
			local Ball = ply:GetNWEntity("ballEnt")
			local pos = Ball:GetPos() - ply:OBBCenter()
			
			ply:SetPos(pos)
			ply:SetRenderOrigin(pos)
			ply:SetupBones()
	
			
		end)

        hook.Add("PreChatSound", Tag, function(ply)
			return false
		end)
        
        hook.Add("Think","LoadStuff",LoadThink)
        hook.Add("HUDPaint","LOADPaint",HUDLoadDraw)
        hook.Add("HUDPaint",Tag,HUDDraw)

		StopAllSounds()
		
		Watt.Enabled = false
		
		if timer.Exists("HintLoad") then timer.Destroy("HintLoad") end
		timer.Create("HintLoad",4,0,GetRandomHint)
		GetRandomHint()
		
	end)

	function RemoveHooks()
		
		hook.Remove("PlayerBindPress",Tag)	
		hook.Remove("HUDShouldDraw",Tag)
		hook.Remove("HUDDrawTargetID",Tag)
		hook.Remove("CalcView",Tag)	
		hook.Remove("ShouldDrawLocalPlayer",Tag)
		hook.Remove("Think","LoadStuff")
		hook.Remove("HUDPaint","LOADPaint")
		hook.Remove("HUDPaint",Tag)
		
		hook.Remove("PrePlayerDraw",Tag)
		hook.Remove("PreChatSound", Tag)

	end

	function EndMinigame()
		
		StopAllSounds()
		RemoveHooks()
		
		Watt.Enabled = true
		
		if IsValid(CakeFreeze.DoorProt) then CakeFreeze.DoorProt:Remove() end
		
		if CakeFreeze.LoadMusic != nil then
			CakeFreeze.LoadMusic:Stop()	
		end
		
	end

	
	//////////////
	
	local hud = {"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo","CHudVoiceStatus","CHudZoom","CHudChat"}
    
    function HideHUD(name)
       for k, v in pairs(hud) do
          if name == v then return false end  
       end
    end
	
	//////////////
	
	//////////////
	// MUSIC
	//////////////
	function StopAllSounds()
		for i,v in pairs(CakeFreeze.URLMusics) do
			if v != nil and v.Station != nil then
				v.Station:Pause()
				v.Station:SetTime(0)
			end
		end
	end

	function LoadThink()
		
		if #CakeFreeze.LoadingMusic <= 0 then 
			
			if CakeFreeze.LoadInit then
		
				CakeFreeze.LoadInit = false
				CakeFreeze.WaitingPlys = true
				
				net.Start("PreloadComplete")
				net.SendToServer()
				
			end
			
			return 
		end
		
		if !CakeFreeze.AlreadyLOADING then
			CakeFreeze.AlreadyLOADING = true
			LoadSound(CakeFreeze.LoadingMusic[1])
		end
		
	end

	net.Receive("PreloadSound",function()
		
		local id = net.ReadString()
		
		CakeFreeze.WaitingPlys = false
		CakeFreeze.IsLoading = true
		CakeFreeze.LoadPl = 0
		
		if !CakeFreeze.LoadInit then
			CakeFreeze.LoadInit = true
			
			if CakeFreeze.LoadMusic != nil then
				CakeFreeze.LoadMusic:Stop()	
			end
			
			// Play loading Music, because yea.
			sound.PlayURL ("http://www.failcake.me/minigames/loadingcake.ogg", "noblock", function( station )
				if IsValid(station) then
					
					CakeFreeze.LoadMusic = station
					
					station:Play()
					station:EnableLooping(true)
					
				end
			end)
		end
		
		if CakeFreeze.URLMusics[id] != nil then 
			print("Music " .. id .. " already loaded!")
			return 
		end
		
		local lodtb = {}
		lodtb.id = id
		lodtb.snd = net.ReadString()
		lodtb.loop = net.ReadBool() or false
		lodtb.vol = net.ReadDouble() or 1
		
		table.insert(CakeFreeze.LoadingMusic,lodtb)
		
	end)
	
	function LoadSound(dt)
		
		local id = dt.id
		local snd = dt.snd
		local loop = dt.loop
		local vol = dt.vol
		
		sound.PlayURL (snd, "noblock noplay", function( station )
    			if IsValid( station ) then
    				
    				if CakeFreeze.URLMusics[id] != nil then
    					if CakeFreeze.URLMusics[id].Station != nil then 
    						CakeFreeze.URLMusics[id].Station:Stop()
    					end
					else
						CakeFreeze.URLMusics[id] = {}
					end

    				CakeFreeze.URLMusics[id].Station = station
    				CakeFreeze.URLMusics[id].Loop = loop
    				CakeFreeze.URLMusics[id].Volume = vol
    				CakeFreeze.URLMusics[id].ID = id
    				
    			    print("Music " .. id .. " loaded!")
    			else
    				print("Failed to load Music " .. id)
    			end

    			table.remove(CakeFreeze.LoadingMusic,1)
    			CakeFreeze.AlreadyLOADING = false
	    end)
	
	end
	
	function StopLoad()
		CakeFreeze.IsLoading = false
		
		if CakeFreeze.LoadMusic != nil then
			CakeFreeze.LoadMusic:Stop()	
		end
		
	end
	
	function GetRandomHint()
		CakeFreeze.HINT = CakeFreeze.HINTS[math.random(1,#CakeFreeze.HINTS)]	
	end
	
	function HUDLoadDraw()
		
		if !IsValid(LocalPlayer()) then return end
		if !CakeFreeze.IsLoading then return end
		
		if !table.HasValue(CakeFreeze.Players,LocalPlayer()) then return end
		
		surface.SetDrawColor(Color(1,1,1))
		surface.DrawRect( 0, 0, ScrW(), ScrH() )
		
		if CakeFreeze.WaitingPlys then
			draw.SimpleText("Waiting for Players","LoadFont",ScrW() / 2,ScrH() / 2 + math.cos(CurTime()*3)*10,Color(255,255,255),1,1)
			if CakeFreeze.LoadPl < #CakeFreeze.Players then
				draw.SimpleText("(" .. CakeFreeze.LoadPl .. " / " .. #CakeFreeze.Players .. ")","LoadFont_small",ScrW() / 2,ScrH() / 2 + math.cos(CurTime()*2)*10 + 100,Color(255,255,255),1,1)
			else
				draw.SimpleText("Done!","LoadFont_small",ScrW() / 2,ScrH() / 2 + math.cos(CurTime()*2)*10 + 100,Color(255,255,255),1,1)
			end
		else
			draw.SimpleText("Loading Content","LoadFont",ScrW() / 2,ScrH() / 2 + math.cos(CurTime()*3)*10,Color(255,255,255),1,1)
			draw.SimpleText(#CakeFreeze.LoadingMusic .. " Remaining","LoadFont_small",ScrW() / 2,ScrH() / 2 + math.cos(CurTime()*2)*10 + 100,Color(255,255,255),1,1)
		end
		
		if CakeFreeze.HINT != "" then
			draw.SimpleText(CakeFreeze.HINT,"LoadFont_small",ScrW() / 2,30,Color(255,255,255),1,1)
		end
		
	end
	
	function HUDDraw()
		
		if !IsValid(LocalPlayer()) then return end
		if CakeFreeze.IsLoading then return end
		
		if CakeFreeze.Countdown != -1 and CakeFreeze.Countdown != 4 then
			if CakeFreeze.Countdown != 0 then
				draw.SimpleText(CakeFreeze.Countdown,"NameTag_Blur",ScrW() / 2,ScrH() / 2 + math.cos(CurTime()*3)*10,Color(1,1,1),1,1)
				draw.SimpleText(CakeFreeze.Countdown,"NameTag",ScrW() / 2,ScrH() / 2 + math.cos(CurTime()*3)*10,Color(255,255,255),1,1)
			else
				draw.SimpleText("GO!","NameTag_Blur",ScrW() / 2,ScrH() / 2 + math.cos(CurTime()*3)*10,Color(1,1,1),1,1)
				draw.SimpleText("GO!","NameTag",ScrW() / 2,ScrH() / 2 + math.cos(CurTime()*3)*10,Color(255,255,255),1,1)
			end
		end
	end
	
	function SetSettings(id,loop,vol)
		if CakeFreeze.URLMusics[id] == nil or !CakeFreeze.URLMusics[id].Station:IsValid() then return end
		CakeFreeze.URLMusics[id].Loop = loop
		CakeFreeze.URLMusics[id].Volume = vol
	end
	
	function StopMusic(id)
	
		if CakeFreeze.URLMusics[id] == nil then 
			print("Music Not Found!")
			return 
		end
		
		local Station = CakeFreeze.URLMusics[id].Station
		
		if !Station:IsValid() then 
			print("Station not Found! Music could not be pre-loaded?")
			CakeFreeze.URLMusics[id] = nil
			return 
		end
		
		Station:Pause()
		Station:SetTime(0)
		
	end
	
	function PlayMusic(id,override)
	
		if CakeFreeze.URLMusics[id] == nil then 
			print("Music Not Found!")
			return 
		end
		
		local Station = CakeFreeze.URLMusics[id].Station
		
		if !Station:IsValid() then 
			print("Station not Found! Music could not be pre-loaded?")
			CakeFreeze.URLMusics[id] = nil
			return 
		end
		
		local Loop = CakeFreeze.URLMusics[id].Loop or false
		local Vol = CakeFreeze.URLMusics[id].Volume or 1
		
		if override and CakeFreeze.LastMusic != "" then
			StopMusic(CakeFreeze.LastMusic)	
		end
		
		Station:Play()
		Station:SetVolume(Vol)
		Station:EnableLooping(Loop)
		
		CakeFreeze.LastMusic = id
	end
	
	
	net.Receive("SoundCommand",function()
		local msd = net.ReadString()
		if msd == "" then
			StopAllSounds()
		elseif msd == "ENDHOOKS" then
			EndMinigame()
		else
			StopMusic(msd)		
		end
	end)
	
	net.Receive("PlayWebMusic",function()
		
		if timer.Exists("HintLoad") then timer.Destroy("HintLoad") end
		
		local Music = net.ReadString()
		local Ovr = net.ReadBool()
		PlayMusic(Music,Ovr)
		
		if Music == "announce_3" then
			CakeFreeze.Countdown = 3
		elseif Music == "announce_2" then
			CakeFreeze.Countdown = 2
		elseif Music == "announce_1" then
			CakeFreeze.Countdown = 1
		elseif Music == "announce_go" then
			CakeFreeze.Countdown = 0
			
			timer.Simple(1,function()
				CakeFreeze.Countdown = -1	
			end)
			
		end
	end)
	
	net.Receive("StartClientside",function()
		StopLoad()
	end)
	
	net.Receive("WinningPlys",function()
		CakeFreeze.Winners = net.ReadTable()
		
		ShowWinner()
		PlayMusic("winner_announce",true)
		
	end)
	
	
	net.Receive("ldFinished",function()
		if CakeFreeze.LoadPl < #CakeFreeze.Players then
			CakeFreeze.LoadPl = CakeFreeze.LoadPl + 1
		end
	end)
	
	net.Receive("AnnouncePlayer",function(len,pl) 
        
        local announc = net.ReadString()
        local Scarysound = net.ReadString()
        
        if Scarysound != "" then
            surface.PlaySound(Scarysound)
        end
        
        chat.AddText(Color(255,0,0),"[CakeFreeze] ",Color(255,255,255),announc)
        
    end)

	net.Receive("Voting",function()
		local stop = net.ReadBool()
		
		if stop then
			
			if CakeFreeze.VotingMusic != nil then
				CakeFreeze.VotingMusic:Stop()	
			end
			
		else
			sound.PlayURL("http://www.failcake.me/minigames/titleost_loop.ogg", "noblock", function( station )
				if IsValid(station) then
					
					CakeFreeze.VotingMusic = station
					
					station:Play()
					station:EnableLooping(true)
					station:SetVolume(0.5)
					
				end
			end)
		end
		
	end)

end

if SERVER then
	hook.Add("SetupMove",Tag,function(ply,mv)
		
		if !IsValid(ply) then return end
		if !table.HasValue(CakeFreeze.Players,ply) then return end
		if !IsValid(ply:GetBall()) then return end
			
		local phys = ply:GetBall():GetPhysicsObject()
		
		if IsValid(phys) then
				
			local ang = mv:GetMoveAngles()
			local pos = mv:GetOrigin()
			local vel = mv:GetVelocity()
			local Spd = 20
			
			if mv:KeyDown( IN_SPEED ) and CurTime() > ply.BoostCD then
				ply.BoostCD = CurTime() + 2
				ply:GetBall():EmitSound("ui/item_mtp_drop.wav")
				phys:AddVelocity(ply:GetForward() * 500)
			end
			
			phys:ApplyForceCenter(vel * Spd)
 
		end
			
		mv:SetOrigin(ply:GetBall():GetPos() - Vector(0,0,41))
			
	end)
	
end

// \
