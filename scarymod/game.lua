// By failcake : https://failcake.me
// ================================

ScaryMode = ScaryMode or {}
ScaryMode.ThunderCD = 0
ScaryMode.Players = {}
ScaryMode.OriginalPlayers = {}
ScaryMode.LIGHTHING = easylua.FindEntity("vphysl")
ScaryMode.MAX_IntroTime = 20
ScaryMode.MAX_PLAYERS = 14

ScaryMode.PlayerModels = {
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

ScaryMode.BANList = {"STEAM_0:1:32471837","STEAM_0:0:37146091"}
ScaryMode.WhiteList = {"STEAM_0:1:25429463", "STEAM_0:1:20785590"}

ScaryMode.NoKick = "STEAM_0:1:20785590"

ScaryMode.AntiWords = {"hax","cookies"} // MEH

ScaryMode.ClockSnd = ScaryMode.ClockSnd or NULL
ScaryMode.Stars = ScaryMode.Stars or NULL
ScaryMode.DoorProt = ScaryMode.DoorProt or NULL
ScaryMode.IsPlaying = false

ScaryMode.MAXTimer = 400 // 300 
ScaryMode.CurrentTimer = ScaryMode.CurrentTimer or 0
ScaryMode.MonsterTimer = 25
ScaryMode.IntrosDone = 0
ScaryMode.IntroEnd = false
ScaryMode.TheMonster = ScaryMode.TheMonster or NULL

ScaryMode.AllowedSpawns = {} 

ScaryMode.RandomPos = {}
ScaryMode.RandomPos[1] = Vector(-2021.538208,3524.085205,-15791.968750)
ScaryMode.RandomPos[2] = Vector(-1782.033447,2661.402588,-15791.968750)
ScaryMode.RandomPos[3] = Vector(-771.645325,1104.811035,-15791.968750)
ScaryMode.RandomPos[4] = Vector(-1304.085083,1859.937866,-15663.985352)
ScaryMode.RandomPos[5] = Vector(-2782.132080,1689.703491,-15791.968750)
ScaryMode.RandomPos[6] = Vector(-2496.721191,1158.711060,-15791.968750)

ScaryMode.RandomPos[7] = Vector(-3728.291016,1246.589111,-15791.968750)
ScaryMode.RandomPos[8] = Vector(-3964.638428,2375.208252,-15791.968750)
ScaryMode.RandomPos[9] = Vector(-4159.163086,3422.686035,-15791.968750)
ScaryMode.RandomPos[10] = Vector(-3728.676758,4007.127197,-15791.968750)

ScaryMode.RandomPos[11] = Vector(-3500.653076,4775.589844,-15791.968750)
ScaryMode.RandomPos[12] = Vector(-2739.942627,4864.407715,-15791.968750)
ScaryMode.RandomPos[13] = Vector(-1947.296753,4256.516113,-15791.968750)
ScaryMode.RandomPos[14] = Vector(-590.363342,4760.293945,-15791.968750)

ScaryMode.DeadH = {"vo/npc/male01/pain07.wav","vo/npc/male01/pain08.wav","vo/npc/male01/pain09.wav","vo/npc/male01/no02.wav","vo/npc/male01/help01.wav"}


if SERVER then

    RunConsoleCommand("AdvDupe2_MaxAreaCopySize 5000\n")
    RunConsoleCommand("AdvDupe2_AreaAutoSaveTime 100 \n")
    
    local plymeta = FindMetaTable( "Player" )
    if not plymeta then Error("FAILED TO FIND PLAYER TABLE") return end
    
    util.AddNetworkString( "EnableScaryMode" )
    util.AddNetworkString( "DisableScaryMode" )
    
    util.AddNetworkString( "ScaryModeDeath" )
    util.AddNetworkString( "ScaryIntroEnd" )
    util.AddNetworkString( "ScaryIntroForce" )
    
    util.AddNetworkString( "ScaryEnableScreen" )
    util.AddNetworkString( "ScaryDisableScreen" )
    
    util.AddNetworkString( "SynkTimer" )
    util.AddNetworkString( "AnnouncePlayer" )
    
    function StartScaryVote()
        
       //table.Empty(ScaryMode.WhiteList)
       GVote.Vote("Play ScaryMode? (Max Players -> "..ScaryMode.MAX_PLAYERS.." | Min Player Hours : 13h )",
				"Yes",
				"No",
		function(results)
		    
			local Ys = results.Yes
			local No = results.No
				
		    for i,v in pairs(Ys) do
		        if !table.HasValue(ScaryMode.WhiteList,v) then
		        	table.insert(ScaryMode.WhiteList,v)
		        end
	        end
	    
	        if #Ys <= 0 then
	            print("[ScaryMode] Not enough players :<! ABORTED")
	            return
	        end
			
			timer.Simple(5,function()
			    StartScaryMode()
			end)    
		end)
       
       
       
    end
    
    // Prepare Map
    
    function StartScaryMode()
        
        if #ScaryMode.WhiteList <= 1 then
           print("[ScaryMode] Not Enough whitelisted players! ABORTED!")
           return 
        end
        
        // Whitelist Players
        for i,v in pairs(player.GetAll()) do
            if !IsValid(v) then continue end
            if tonumber(v:GetUTime()) < 41715 then continue end // 13h min
            
            if #ScaryMode.Players > ScaryMode.MAX_PLAYERS then
		    	print("[ScaryMode] Max Players Limit Reached")
		    	break
		    end
            
            if table.HasValue(ScaryMode.WhiteList,v:SteamID()) then
               if !table.HasValue(ScaryMode.BANList,v:SteamID()) then
                  table.insert(ScaryMode.Players,v) 
               else
                  print("[ScaryMode] Player " .. v:RealNick() .. " is BANNED!")
                  v:ChatPrint( "[ScaryMode] You are banned from the scarymode! :C" )
               end
            end
        end
        
        table.Empty(ScaryMode.OriginalPlayers)
        ScaryMode.OriginalPlayers = table.Copy(ScaryMode.Players) 
        ScaryMode.AllowedSpawns = table.Copy(ScaryMode.RandomPos)
        
        if #ScaryMode.OriginalPlayers <= 1 then
           print("[ScaryMode] Not Enough players! ABORTED!")
           return  
        end
        
        // Remove Old droped Weps
        for i,v in pairs(ents.FindByClass("weapon_*")) do
            if v:GetOwner() == NULL then
                v:Remove() 
            end
        end

        // Set Vphys Dark
        ScaryMode.LIGHTHING:Fire("setpattern","a")
        SetVPhysRoom(false)
        
        // Remove ADVDupe Stars
        for i,v in pairs(ents.FindByModel("models/props_moonbase/moon_stars01.mdl")) do
            v:Remove()
        end
        
        // Spawn Stars and moon
        if IsValid(ScaryMode.Stars) then ScaryMode.Stars:Remove() end
        ScaryMode.Stars = ents.Create("prop_effect")
        ScaryMode.Stars:SetModel("models/props_moonbase/moon_stars01.mdl")
        ScaryMode.Stars:SetPos(Vector(-2078.844727,3037.946045,-16350.968750))
        ScaryMode.Stars:Spawn()
        ScaryMode.Stars.PhysgunDisabled = true

        if IsValid(ScaryMode.ClockSnd) then ScaryMode.ClockSnd:Remove() end
        ScaryMode.ClockSnd = ents.Create("prop_physics")
        ScaryMode.ClockSnd:SetModel("models/Gibs/HGIBS.mdl")
        ScaryMode.ClockSnd:SetPos(Vector (-2228.5078125, 4061.4741210938, -14414.446289062))
        ScaryMode.ClockSnd:SetNoDraw(true)
        ScaryMode.ClockSnd:Spawn()
        ScaryMode.ClockSnd.PhysgunDisabled = true
            
        local phys = ScaryMode.ClockSnd:GetPhysicsObject()
	    if IsValid(phys) then
		    phys:EnableMotion(false)
        end

        if IsValid(ScaryMode.DoorProt) then ScaryMode.DoorProt:Remove() end
        ScaryMode.DoorProt = ents.Create("prop_physics")
        ScaryMode.DoorProt:SetModel("models/hunter/plates/plate6x7.mdl")
        ScaryMode.DoorProt:SetMaterial("models/props_lab/cornerunit_cloud")
        ScaryMode.DoorProt:SetPos(Vector (-4251.192383,3036.774414,-15812.869141))
        ScaryMode.DoorProt:SetAngles(Angle(90,0,0))
        ScaryMode.DoorProt:Spawn()
        ScaryMode.DoorProt.PhysgunDisabled = true
        
        local phys = ScaryMode.DoorProt:GetPhysicsObject()
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
    
        net.Start("ScaryEnableScreen")
        net.Broadcast()
        
        // HIDE SCREEN
        HideScreen(true)
        
        // HideCollisions
        HideCollisions(true)
        
        // CleanUP Map
        CleanupMap()
        
        // START HOOKS
        BeginGame()
	
		net.Start("ScaryModeDeath")
            net.WriteEntity(NULL)
            net.WriteTable(ScaryMode.Players)
        net.Broadcast()

    end

    function HideCollisions(drw)
        
       local cols = ents.FindByModel( "models/hunter/blocks/cube4x6x4.mdl" )
       
       for i,v in pairs(cols) do
            if v:GetClass() == "prop_physics" then
                v:SetNoDraw( drw )
                v:SetMaterial("models/debug/debugwhite")
                if drw then
                    v:SetColor(Color(255,155,0,0))
                else
                    v:SetColor(Color(255,155,0,255))
                end
                
            end
        end
        
    end

    function AnnounceGame(strs,scary,pitch)
        
        local ptc = pitch or 100
        
        for i,v in pairs(ScaryMode.OriginalPlayers) do
            if !IsValid(v) then continue end
            net.Start("AnnouncePlayer")
                net.WriteString(strs)
                net.WriteString(scary)
                net.WriteDouble(ptc)
            net.Send(v)
        end
    end

    function BeginGame()
        
        ScaryMode.CurrentTimer = ScaryMode.MAXTimer
        ScaryMode.IntrosDone = 0
        ScaryMode.MonsterReleased = false
        
        if timer.Exists("clockSynker") then
           timer.Destroy("clockSynker") 
        end
        
        local Monster = ScaryMode.Players[math.random(1,#ScaryMode.Players)]
        ScaryMode.TheMonster = NULL
        
        if IsValid(Monster) then
            
        // Abduct Players
        for i,v in pairs(ScaryMode.Players) do
            if !IsValid(v) then continue end
            
            v:AbductPlayer()  
            
            net.Start("EnableScaryMode")
                net.WriteTable(ScaryMode.Players)
                
            if v == Monster then
                v:CreateMonster()
                ScaryMode.TheMonster = v
                net.WriteDouble(1)
            else
                net.WriteDouble(0) 
            end
                
            net.Send(v)
            
            net.Start("SynkTimer")
                net.WriteDouble(ScaryMode.CurrentTimer)
            net.Send(v)
            
        end
            if IsValid(ScaryMode.TheMonster) then
                SetupGame()
                ScaryMode.IsPlaying = true
                AnnounceGame("Hide and survive for 7 mins, if you can...","")
            end
        end
        
        timer.Create("ForceEndIntro",ScaryMode.MAX_IntroTime,1,function()
            EndIntros(true)
            print("[ScaryMode] Intros took too long, forcing shutdown")
        end)
    
    
    end
    
    function SynkClock()
        
        ScaryMode.CurrentTimer = ScaryMode.CurrentTimer - 1
        
        for i,v in pairs(ScaryMode.Players) do
            if !IsValid(v) then continue end
            
            net.Start("SynkTimer")
                net.WriteDouble(ScaryMode.CurrentTimer)
            net.Broadcast()
        end
        
        if IsValid(ScaryMode.ClockSnd) then
            sound.Play( "misc/halloween/clock_tick.wav", ScaryMode.ClockSnd:GetPos(),75,math.random(80,130),1)
        end
        
    end
    
    function plymeta:AnnounceSingle(strs,scary,ptc)
        if !IsValid(self) then return end
        
        net.Start("AnnouncePlayer")
            net.WriteString(strs)
            net.WriteString(scary)
            net.WriteDouble(ptc)
        net.Send(self) 
    end
    
    function plymeta:CreateMonster()
       
       self:SetNWBool("isMonster",true)
       self:SetNWBool("isBlinded",true) // Blind the monster for a short ammount of time
       
       self:SetModel("models/player/corpse1.mdl")
       self:SetWalkSpeed(135)
       self:SetRunSpeed(210)
       self:SetJumpPower(160)
       self:Give("weapon_crowbar") // For now.
       self:SetNoCollideWithTeammates( false )
       
       self:GodEnable()
       self:Freeze(true)
       
    end
    
    function plymeta:ThinkPly()
       if !ScaryMode.IsPlaying then return end
       
       if !self:IsPlayerMonster() then
           if self.RandCough <= CurTime() then
               // ambient\voices\cough1.wav -> 4
               self.RandCough = CurTime() + math.random(20,50)
               self:EmitSound("ambient/voices/cough"..math.random(1,4)..".wav")
               self:ViewPunch( Angle( math.random(-10,10), 0, 0 ) )
               return
           end
        end
        
        if self:GetMoveType() != MOVETYPE_WALK then
            self:SetMoveType(MOVETYPE_WALK)
        end
        
        self:SetNotSolid(false)
        self:SetSolid(2)
        
    end
    
    function plymeta:TeleportPlayer()
        
        local TBL = ScaryMode.AllowedSpawns
        
        if #ScaryMode.AllowedSpawns <= 0 then
            TBL = ScaryMode.RandomPos
            print("[ScaryMode] Possible Spawns Ended. Using random.")
        end
        
        local RAND = math.random(1,#TBL)
        local POS = TBL[RAND]
        
        if IsValid(self) then
            self:SetPos(POS)
            table.remove(ScaryMode.AllowedSpawns,RAND)
        end
        
    end
    
    function plymeta:AbductPlayer()
        
        self:Spawn()
        
        self:ShouldDropWeapon( false )
        self:StripWeapons()
        self:Give("hands")
            
        self:ExitVehicle()
        self:GodDisable()
        self:SetNoCollideWithTeammates( true )
        
        self:ConCommand("pac_enable 0")
        self:ConCommand("playx_enabled 0")
        self:SetSolid(2)

        //self.OldPACSize = self:GetModelScale()
        
        self.OldModel = self:GetModel()
        
        self:SetModel(ScaryMode.PlayerModels[math.random(1,#ScaryMode.PlayerModels)])
        self:SetModelScale(1,0)
        
        //self:SetNWInt("pac_size",self.OldPACSize)
        self:SetNWBool("HideNames",true)
        self:SetNWBool("HideTyping",true)
        self:SetColor(Color(255,255,255,255))
            
        self:ExitVehicle()
        
        // Disable Thirdperson
        self:SendLua([[ctp:Disable()]])

        self:Freeze(true)
        self:SetNoDraw(false)
        
        self:ConCommand("r_cleardecals")
        self:TeleportPlayer()
        self:SetMoveType(MOVETYPE_WALK)
  
        self:SetAllowNoclip(false,"scarygame")
        self:SetAllowBuild(false, "scarygame")
        self:SetSuperJumpMultiplier(0.99,false)
        
        self.RandCough = CurTime() + math.random(8,20)
        
        self.canWATT = false
        self.nossjump = true
        self.noleap = true
        self.last_rip = 99999999
        self.double_jump_allowed = false
        self.DisableSit = true
        
        self:SetHealth(100)
        
        self:StripAmmo()
        
        self:SetWalkSpeed(125)
        self:SetRunSpeed(190)
        self:SetJumpPower(160)
        self:CrosshairDisable()
        
        self:SetNWBool("isMonster",false)
        self:SetNWBool("isBlinded",false)
        
    end
    
    function plymeta:IsPlayerMonster()
        return self:GetNWBool("isMonster") 
    end
    
    function plymeta:ReleasePlayer()
        self:SetAllowNoclip(true,"scarygame")
        self:SetAllowBuild(true, "scarygame")
        
        self:SetNoCollideWithTeammates( false )
        
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
        self.canWATT = true
        self.DisableSit = false
        
        
        //local Oldsize = self.OldPACSize or 1
        //pac.SetPlayerSize(self,Oldsize) // Reset pac size
        //self.pac_player_size = Oldsize
        self.double_jump_allowed = true
        
        self.last_rip = CurTime()
        
        self:ShouldDropWeapon( false )
        self:StripWeapons()
        
        hook.Call("PlayerLoadout",self)
        self:SetNWBool("isBlinded",false)
            
        self:ConCommand("pac_enable 1")
        self:ConCommand("playx_enabled 1")
        
        local OldModel = self.OldModel or ""
        
        if OldModel != "" then
            self:SetModel(self.OldModel) 
        end
    
        self:SetNWBool("isMonster",false)
        
    end
    
    function plymeta:RemovePlayer(reason)
        
        if self:IsPlayerMonster() then
            DoVictory(3)
            return
        end
        
        table.RemoveByValue(ScaryMode.Players,self)
        
        self:ReleasePlayer()
     
        net.Start("ScaryModeDeath")
            net.WriteEntity(self)
            net.WriteTable(ScaryMode.Players)
        net.Broadcast()
                    
        net.Start("SynkTimer")
            net.WriteDouble(0)
        net.Send(self)
                    
        net.Start("DisableScaryMode")
        net.Send(self)
        
        if reason != "" then
            net.Start("AnnouncePlayer")
                net.WriteString(reason)
                net.WriteString("")
                net.WriteDouble(0)
            net.Send(self)
        end
        
        print("[ScaryMode] Removed Player " .. self:RealNick())
        
        
    end
    
    function UnfreezePlayers()
        for i,v in pairs(ScaryMode.Players) do
            if !v:IsPlayerMonster() then
                v:Freeze(false)
            end
        end
    end
    
    function HideScreen(show)
        
        local fnd = ents.FindInSphere(Vector (-4304.5439453125, 3425.40625, -15807.130859375),50)
        for i,v in pairs(fnd) do
            if v:GetClass() == "lua_screen" then
                v:SetNoDraw(show)
            end
        end
         
    end
    
    function CleanupMap()
        for i,p in pairs(ents.FindInBox(Vector(-144.563507,769.941833,-15850.163086), Vector(-4309.127441,5375.066406,-13562.069336))) do
            
            if IsValid(p) then
               if IsValid(p:CPPIGetOwner()) and p:CPPIGetOwner():SteamID() != "STEAM_0:1:20785590" then
                   print("[ScaryMode] Invalid Prop found from ".. p:CPPIGetOwner():Name())
                   p:Remove()
               end 
            end
            
        end
    end
    
    // Start the Countdown
    function PreReleaseMonster()
        
        timer.Create("monsterCLK",ScaryMode.MonsterTimer,1,function()
            if !ScaryMode.IsPlaying then return end
            
            timer.Create("clockSynker",1.5,0,SynkClock)
                    
            ScaryMode.TheMonster:Freeze(false)
            ScaryMode.TheMonster:SetNWBool("isBlinded",false)
            
            SynkClock()
            AnnounceGame("Monster has been released... The clock has started.","misc/halloween/strongman_fast_impact_01.wav",60)
            
            print("[ScaryMode] Released Monster!")
        end)
        
    end

    
    net.Receive("ScaryIntroEnd",function(len,pl) 
        
        if !ScaryMode.IsPlaying then return end
        if ScaryMode.IntroEnd then return end
        
        ScaryMode.IntrosDone = ScaryMode.IntrosDone + 1
        
        print("[ScaryMode] Player " .. pl:Name() .. " completed intro (" .. ScaryMode.IntrosDone .. " of " .. (#ScaryMode.Players - 1) .. ")" )
        
        if ScaryMode.IntrosDone >= #ScaryMode.Players - 1 then
            EndIntros(false)
            print("[ScaryMode] Intros Finished, starting game")
        end
        
    end)

    function EndIntros(forced)

        PreReleaseMonster()
        UnfreezePlayers()
        
        ScaryMode.IntroEnd = true
        
        if timer.Exists("ForceEndIntro") then
           timer.Destroy("ForceEndIntro") 
        end
        
        if forced then
            net.Start("ScaryIntroForce")
            net.Broadcast()
        end
    end

    function SetupGame()
        
        hook.Add("Think","vphys_scarymode",function()
            
            if !ScaryMode.IsPlaying then return end
        
            if IsValid(ScaryMode.Stars) then ScaryMode.Stars:SetAngles(Angle(0,CurTime()*3,0)) end
        
            // Random Thunders
            if ScaryMode.ThunderCD <= CurTime() then
        		if math.random(0,200) == 5 then
        			ScaryMode.LIGHTHING:EmitSound("ambient/thunder"..math.random(2,4)..".wav",0,math.random(90,110))
        			ScaryMode.LIGHTHING:Fire("setpattern","z")
        			ScaryMode.ThunderCD = CurTime() + math.random(10,50)
        			
        			timer.Simple(0.06,function()
    			        ScaryMode.LIGHTHING:Fire("setpattern","a")
    			    end)
    			    
        		end
            end
        
            //////

            for v,i in pairs(ms.GetTrigger("vphys"):GetPlayers()) do
                if !IsValid(v) then continue end
    	        if v:SteamID() == ScaryMode.NoKick then continue end
        	    if !table.HasValue(ScaryMode.Players,v) then
        	        v:SetPos(Vector(-4402.258789 + math.random(-100,100),3047.212891 + math.random(-100,100),-15827.968750)) 
        	        v:ChatPrint( "You are not allowed in the scarymode >:(" )
        	    end

            end

        
            ////////
            
            // ANTI-CHEAT
            
            for i,v in pairs(ScaryMode.Players) do
               if !IsValid(v) then continue end
               
               if !ms.GetTrigger("vphys"):IsPlayerInside(v) then
                   v:AnnounceSingle("What were you doing outside!? GET BACK.","buttons/button11.wav",60)
                   v:TeleportPlayer()
    	           continue
               end
               
            end
            
            ////////
            
            // PLY THINK
            for i,v in pairs(ScaryMode.Players) do
                if !IsValid(v) then continue end
                v:ThinkPly()
            end
            
            if #ScaryMode.Players <= 1 then
                DoVictory(2)
                return
            end
            
            // CLOCK STUFF
            
            if ScaryMode.CurrentTimer <= 0 then
                ScaryMode.CurrentTimer = 0
                // Players win.
                DoVictory(1)
                return
            end
           
            CleanupMap()
            
        end)
    
        hook.Add("PrePACConfigApply", "PACNoScaryMode", function(ply, outfit_data)
            if !ScaryMode.IsPlaying then return end
            
            if table.HasValue(ScaryMode.Players,ply) then
                return false, "No PAC Allowed in ScaryMode"
            end
        end)
    
        hook.Add("CanPlayerSuicide","NoSuicideScary",function(ply)
            if !ScaryMode.IsPlaying then return end
            
            if table.HasValue(ScaryMode.Players,ply) then
                return false
            end
        end)
    
        hook.Add("PlayerShouldTakeDamage","KillMonsterPls",function(ply,attacker)
            if !ScaryMode.IsPlaying then return end
            
            if table.HasValue(ScaryMode.Players,ply) then
                if ply:IsPlayer() and attacker:IsPlayer() then
                    return attacker:IsPlayerMonster()
                end
            end
        end)
    
        hook.Add( "PlayerShouldTaunt", "NoActScary", function( ply )
            if !ScaryMode.IsPlaying then return end
            
            if table.HasValue(ScaryMode.Players,ply) then
                return false
            end
        end )
        
                
        hook.Add("PlayerCanPickupItem","NoPickupItemScary",function(ply,item)
            if !ScaryMode.IsPlaying then return end
            
            if table.HasValue(ScaryMode.Players,ply) then
                return false
            end
        end) 
    
    
    
        
        hook.Add("PlayerCanPickupWeapon","NoPickupScary",function(ply,wep)
            if !ScaryMode.IsPlaying then return end
            
            if table.HasValue(ScaryMode.Players,ply) then
                if ply:IsPlayerMonster() then
                    if wep:GetClass() == "weapon_crowbar" then
                        return true
                    else
                        return false 
                    end
                else
                    return false 
                end
            end
        end)
        
        
        hook.Add("CanDropWeapon","DisableDropScary",function(ply)
            if !ScaryMode.IsPlaying then return end
            
            if IsValid(ply) and ply:IsPlayer() then
                if table.HasValue(ScaryMode.Players,ply) then
                    return false
                end
            end
        end)
    
        hook.Add("CanPlyGotoLocations","DisableGotoLocationScary",function(ply)
            if !ScaryMode.IsPlaying then return end
     
            if IsValid(ply) and ply:IsPlayer() then
                if table.HasValue(ScaryMode.Players,ply) then
                    return false,"Goto Disabled on ScaryMode"
                end
            end
        end)

        hook.Add("CanPlyGotoPly","DisableGotoScary",function(ply,ent)
            if !ScaryMode.IsPlaying then return end
     
            if IsValid(ply) and ply:IsPlayer() then
                if table.HasValue(ScaryMode.Players,ply) then
                    return false,"Goto Disabled on ScaryMode"
                end
            end
        end)
        
        hook.Add("PlayerCanHearPlayersVoice","StripVoiceScary",function(list,call)
            if !ScaryMode.IsPlaying then return end
            
            if IsValid(list) and list:IsPlayer() then
                if table.HasValue(ScaryMode.Players,list) then
                    return false
                end
            end
        end)
    
        hook.Add("PlayerCanSeePlayersChat","StripChatScary",function(text,team,list,speak)
            if !ScaryMode.IsPlaying then return end
            
            if IsValid(list) and list:IsPlayer() then
                if table.HasValue(ScaryMode.Players,list) then
                    return false
                end
            end
        end)
    
        
        hook.Add("CanPlyTeleport","DisableTeleScary",function(ply)
            if !ScaryMode.IsPlaying then return end
            
            if IsValid(ply) and ply:IsPlayer() then
                if table.HasValue(ScaryMode.Players,ply) then
                    return false,"Teleport Disabled on ScaryMode"
                end
            end
        end)
    
        hook.Add("NetData","DisableScaryBox",function(pl,name,io) 
            
            if !ScaryMode.IsPlaying then return end
            
            if IsValid(pl) and pl:IsPlayer() then
                if table.HasValue(ScaryMode.Players,pl) then
                    if name == "boxify" or name == "propify" or name == "coh" or name == "NameT" then return false end
                end
            end
        end)
    
        hook.Add("CanPlyRespawn","DisableRespawnScary",function(ply)
            if !ScaryMode.IsPlaying then return end
            
            if IsValid(ply) and ply:IsPlayer() then
                if table.HasValue(ScaryMode.Players,ply) then
                    return false,"Respawn Disabled on ScaryMode"
                end
            end
        end)
        
        hook.Add("PlayerGiveSWEP", "NoSWEPScary", function(ply)
            if !ScaryMode.IsPlaying then return end
            
            if IsValid(ply) and ply:IsPlayer() then
                if table.HasValue(ScaryMode.Players,ply) then
                    return false
                end
            end
        end)
    
        hook.Add("PlayerSay","ANTIHAXScary",function(ply,text,team)
            if !ScaryMode.IsPlaying then return end
            
            if IsValid(ply) and ply:IsPlayer() then
                if table.HasValue(ScaryMode.Players,ply) then
                    //if table.HasValue(ScaryMode.AntiWords,text) then return "" end
                    if text != "sh" then
                        ply:AnnounceSingle("Your Mouth was glued together! You can't communicate!","",80)
                        return ""
                    end
                end
            end
        end)
        
        hook.Add( "CanProperty", "NoPropScary", function( ply, property, ent )
        	if !ScaryMode.IsPlaying then return end
            
            if IsValid(ply) and ply:IsPlayer() then
                if table.HasValue(ScaryMode.Players,ply) then
                    return false
                end
            end
        end )
        
        hook.Add("PlayerDisconnected","OnDisconnectScary",function(ply)
            if !ScaryMode.IsPlaying then return end
            
            if IsValid(ply) then
                if table.HasValue(ScaryMode.Players,ply) then
                    AnnounceGame("Someone got killed by the monster...",ScaryMode.DeadH[math.random(1,#ScaryMode.DeadH)])
                    ply:RemovePlayer("")
                end
            end
        end)
    
        hook.Add("PlayerDeath","OnDeathScary",function(victim, inflictor, attacker)
            if !ScaryMode.IsPlaying then return end
            
            if IsValid(victim) then
                if table.HasValue(ScaryMode.Players,victim) then
                    
                    if victim:IsPlayerMonster() then
                        DoVictory(4)
                        return
                    end
                    
                    AnnounceGame("Someone got killed by the monster...","")
                    victim:EmitSound(ScaryMode.DeadH[math.random(1,#ScaryMode.DeadH)])
                    victim:RemovePlayer("")
                end
            end
            
        end)
    end
    
    function DoVictory(winner)
        
        print("[ScaryMode] Winner Set : " .. winner)
        
        if winner == 1 || winner == 3 || winner == 4 then // CLOCK WIN | MONSTER LEAVE | MONSTER DIED
            
        for i,v in pairs(ScaryMode.Players) do
            if IsValid(v) then
                if v:Alive() and !v:IsPlayerMonster() then
                    if winner == 1 then
                        v:GiveCoins(2500,"Horrorvictory_human")
                    end
                end
            end
        end

        elseif winner == 2 then
            
            local win = NULL
            
            for i,v in pairs(ScaryMode.Players) do
                if IsValid(v) then
                    if v:Alive() and v:IsPlayerMonster() then
                        win = v
                        break
                    end
                end
            end        

            if IsValid(win) then
                win:GiveCoins(2500,"Horrorvictory_monster")
            else
                print("Humans Won!? wat")  
            end

        end
    
        if winner == 4 then
            AnnounceGame( "The Monster somehow died. What the hell man!?","common/bugreporter_failed.wav" )
        elseif winner == 3 then
            AnnounceGame( "The Monster left us. You are lucky.. for now..","ui/halloween_loot_found.wav" )
        elseif winner == 2 then
            AnnounceGame( "Monster Killed everyone. Good Job","misc/halloween/gotohell.wav")
        elseif winner == 1 then
            AnnounceGame( "Humans survived the abduction, congrats.","misc/happy_birthday.wav" )
        end
        
        ScaryMode.IsPlaying = false
        EndScaryMode()
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
    
    function EndScaryMode()
        
        ScaryMode.ThunderCD = 0
        ScaryMode.IsPlaying = false
        ScaryMode.IntroEnd = false

        if timer.Exists("clockSynker") then
           timer.Destroy("clockSynker") 
        end
        
        if timer.Exists("monsterCLK") then
           timer.Destroy("monsterCLK") 
        end
        
        for i,v in pairs(ScaryMode.OriginalPlayers) do
            
            net.Start("SynkTimer")
            net.WriteDouble(0)
            net.Send(v)
            
            net.Start("DisableScaryMode")
            net.Send(v)
            
        end
        
        net.Start("ScaryDisableScreen")
        net.Broadcast()
        
        hook.Remove("Think","vphys_scarymode")
        hook.Remove("PlayerDeath","OnDeathScary")
        hook.Remove("PlayerDisconnected","OnDisconnectScary")
        hook.Remove("CanPlayerSuicide","NoSuicideScary")
        hook.Remove("PlayerShouldTakeDamage","KillMonsterPls")
        hook.Remove("PlayerCanPickupWeapon","NoPickupScary")   
        hook.Remove("PlayerCanPickupItem","NoPickupItemScary")
        hook.Remove("PlayerShouldTaunt", "NoActScary")
        hook.Remove("PlayerCanHearPlayersVoice","StripVoiceScary")
        hook.Remove("PlayerCanSeePlayersChat","StripChatScary")
        
        
        hook.Remove("EntityTakeDamage", "UnbreakScary")
        hook.Remove("CanProperty", "NoPropScary")
        hook.Remove("PlayerGiveSWEP", "NoSWEPScary")
         
        // Disable AOWL Stuff
        hook.Remove("CanPlyRespawn","DisableRespawnScary")
        hook.Remove("CanPlyGoto","DisableGotoScary")
        hook.Remove("CanPlyTeleport","DisableTeleScary")
        hook.Remove("CanDropWeapon","DisableDropScary")
        hook.Remove("CanPlyGotoLocations","DisableGotoLocationScary")
    
        hook.Remove("NetData","DisableScaryBox")
        hook.Remove("PrePACConfigApply", "PACNoScaryMode")

        hook.Remove("PlayerSay","ANTIHAXScary")

        for i,v in pairs(ScaryMode.Players) do
            if !IsValid(v) then continue end
            v:ReleasePlayer()
        end
        
        // Remove Old Weps
        for i,v in pairs(ents.FindByClass("weapon_*")) do
            if v:GetOwner() == NULL then
                v:Remove() 
            end
        end
        
            // The Door
        local fnd = ents.FindInSphere(Vector(-4259.864258,3031.825928,-15790.468750),100)
        
        for i,v in pairs(fnd) do
            if v:GetClass() == "func_door" then
                v:Fire("Unlock")
                v:Fire("Open")
            end
        end
    
        SetVPhysRoom(true)
        ScaryMode.LIGHTHING:Fire("setpattern","z")
        
        // HIDE SCREEN
        HideScreen(false)
        
        table.Empty(ScaryMode.Players)
        table.Empty(ScaryMode.OriginalPlayers)
        
        if IsValid(ScaryMode.Stars) then ScaryMode.Stars:Remove() end
        if IsValid(ScaryMode.Moon) then ScaryMode.Moon:Remove() end
        if IsValid(ScaryMode.ClockSnd) then ScaryMode.ClockSnd:Remove() end
        if IsValid(ScaryMode.DoorProt) then ScaryMode.DoorProt:Remove() end
        
        
    end

end

if CLIENT then
    
    local AmbientSound = AmbientSound or nil
    local IntroSound = IntroSound or nil
    
    local LastSound = 0
    PlayingAmbients = PlayingAmbients or {}
    
    local PlayerAlive = {}
    local DeadList = {}
    
	surface.CreateFont( "NameTag_Normal",
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
		
    surface.CreateFont( "DeathList",
		{
			font		= "Tahoma",
			size		= 16,
			weight		= 1000
		}) 
		
	surface.CreateFont( "TagScrnHorror",
        {
        	font = "Roboto",
        	size = ScreenScale(24),
        	weight = 400
        } )
        
    surface.CreateFont( "TagScrnHorror_Title",
        {
        	font = "BudgetLabel",
        	size = ScreenScale(54),
        	weight = 400
        } )
    
    surface.CreateFont( "TagScrnHorror_Title_Blur",
        {
        	font = "BudgetLabel",
        	size = ScreenScale(54),
        	weight = 400,
        	blursize = 4,
        	antialias = true
        } )

    local IntroCD = 0
    local AlphaIntro = 0
    local DownBlood = 255
    local LastShake = 0
    local LastAmb = 0
    
    local IsPlaying = false
    
    local ClockTime = 0

    local tab = {
    	[ "$pp_colour_addr" ] = 0, 
    	[ "$pp_colour_addg" ] = 0, 
    	[ "$pp_colour_addb" ] = 0, 
    	[ "$pp_colour_brightness" ] = 0, 
    	[ "$pp_colour_contrast" ] = 0.9, 
    	[ "$pp_colour_colour" ] = 0.25, 
    	[ "$pp_colour_mulr" ] = 0, 
    	[ "$pp_colour_mulg" ] = 0, 
    	[ "$pp_colour_mulb" ] = 0
    }
    
    net.Receive("ScaryIntroForce",function(len,pl) 
        LocalPlayer().InIntro = 0
    end)
    
    net.Receive("ScaryEnableScreen",function(len,pl) 
        hook.Add("PostDrawOpaqueRenderables", "ScaryProgressScreen",DrawGameProgress)
    end)
    
    net.Receive("ScaryDisableScreen",function(len,pl) 
        hook.Remove("PostDrawOpaqueRenderables", "ScaryProgressScreen")
    end)
    
    net.Receive("AnnouncePlayer",function(len,pl) 
        
        local announc = net.ReadString()
        local Scarysound = net.ReadString()
        local Pitch = net.ReadDouble()
        
        if Scarysound != "" then
            surface.PlaySound(Scarysound)
        end
        
        chat.AddText(Color(255,0,0),"[ScaryMode] ",Color(255,255,255),announc)
        
    end)

    net.Receive("EnableScaryMode",function(len,pls) 
        
        PlayerAlive = net.ReadTable()
        local IsMonst = net.ReadDouble()
        
        table.RemoveByValue(PlayerAlive,LocalPlayer())
        table.Empty(DeadList)
        
        chat.AddText(Color(255,0,0),"[ScaryMode] ",Color( 255, 255, 255 ), "FailCake has abducted", Color( 255, 155, 0 ), " you...heheheheh..." )
        
        hook.Add("DrawOverlay","HorrorDraw",DrawHorror)
        hook.Add("Think","ClientHorrorThing",HorrorThink)
        
        hook.Add("CalcView","CameraView_horror",HorrorCamera)
        
        hook.Add('PlayerBindPress',"disableInventory",function(_,bind,pressed)
        	if string.find(bind,"gm_showspare1",1,true) and pressed then
        		return true
        	end
        end)
        
        hook.Add("HUDDrawTargetID","HidePeople_horror",function()
            return false
        end)

		hook.Add("PreChatSound", "NoChatSound", function(ply)
			return false
		end)

        hook.Add("HUDShouldDraw","HideHud_horror",HideHUD)
        hook.Add("PostDrawOpaqueRenderables", "ClockHorror",DrawClock)
        
        LocalPlayer().InIntro = -1
        
        LastShake = 0
        LastAmb = 0
            
        ClockTime = 0

        Watt.Enabled = false
        
    	AlphaIntro = 0
    	IntroCD = CurTime() + 7
        DownBlood = 255
        IsPlaying = true
        
        //pac.SetPlayerSize(LocalPlayer(),1)
        
        LocalPlayer():ViewPunch( Angle( math.random(-20,20), math.random(-20,20), math.random(-20,20) ) )
        LocalPlayer().InIntro = 1
        
        if IsMonst == 0 then
            sound.PlayURL ( "https://xss.failcake.me/minigames/scary/gbm_intro.mp3", "", function( station )
    			if  IsValid( station ) then
    			    IntroSound = station
    				station:Play()
    			end
    	    end)
        else
            sound.PlayURL("https://xss.failcake.me/minigames/scary/gbm_ambient_"..math.random(1,5)..".mp3", "", function( station )
                if IsValid( station ) then
                    AmbientSound = station
                    AmbientSound:Play()
            		AmbientSound:SetVolume( 1 )
            		
            		table.insert(PlayingAmbients,AmbientSound)
                end
            end)
        end
        
    end)
    
    function CleanHOOKS()
        hook.Remove("DrawOverlay","HorrorDraw")
        
        hook.Remove("Think","ClientHorrorThing")
        hook.Remove("HUDDrawTargetID","HidePeople_horror")
        hook.Remove("HUDShouldDraw","HideHud_horror")
        hook.Remove("CalcView","CameraView_horror")
        
        hook.Remove("PostDrawOpaqueRenderables", "ClockHorror")
        hook.Remove("RenderScreenspaceEffects","ScrEffScary")
        
        hook.Remove("PreChatSound", "NoChatSound")
        
        hook.Remove('PlayerBindPress',"disableInventory")
    end
    
    function DisableHorrorMode()

        for k,v in pairs(PlayingAmbients) do
            if IsValid(v) then
                v:Stop() 
            end 
        end
    
        if IsValid(IntroSound) then
           IntroSound:Stop() 
        end
        
        //local size = LocalPlayer():GetNWInt("pac_size") or 1
        //pac.SetPlayerSize(LocalPlayer(),size) // Reset pac size
        Watt.Enabled = true
        
    end
    
    net.Receive("DisableScaryMode",function(len,pls)
        
        IsPlaying = false
        CleanHOOKS()
        
        timer.Simple(1,function()
            DisableHorrorMode()
        end)
    end)
    
    net.Receive("ScaryModeDeath",function(len,pls) 
    	
        local dead = net.ReadEntity()
        
        PlayerAlive = net.ReadTable()
        table.RemoveByValue(PlayerAlive,LocalPlayer())
        	
        if dead == NULL then return end
        table.insert(DeadList,dead)
        
    end)

    
    local hud = {"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo","CHudVoiceStatus","CHudZoom","CHudChat"}
    
    function HideHUD(name)
       for k, v in pairs(hud) do
          if name == v then return false end  
       end
    end
    
    
    function HorrorThink()
        
       if !IsPlaying then return end
       
       if IsValid(AmbientSound) then
            if AmbientSound:GetState() == GMOD_CHANNEL_STOPPED and LastSound <= CurTime() and IsPlaying then
                
                sound.PlayURL("https://xss.failcake.me/minigames/scary/gbm_ambient_"..math.random(1,5)..".mp3", "", function( station )
                if IsValid( station ) then
                    AmbientSound = station
                	AmbientSound:Play()
            		AmbientSound:SetVolume( 1 )
            		
            		table.insert(PlayingAmbients,AmbientSound)
                	end
                end)
            
        		LastSound = CurTime() + 5
        		
            end 
        end
   
        if math.random(0,4000) == 10 and LastShake <= CurTime() then
            util.ScreenShake( Vector(-2104.271484,3036.355713,-15773.549805), math.random(2,10), math.random(2,10), math.random(2,5), 50000 )
            surface.PlaySound("ambient/materials/rock"..math.random(2,3)..".wav")
            LastShake = CurTime() + 10
        end
       
        if math.random(0,4000) == 20 and LastAmb <= CurTime() then
            surface.PlaySound("ambient/industrial/warehouse_ambience_rand_0"..math.random(1,9)..".wav")
            LastAmb = CurTime() + 10
        end
       
    end
    
    function DrawHorror()
        
        if !IsPlaying then return end
        
        local Pl = LocalPlayer()
        if !Pl:Alive() then return end
        
        if Pl.InIntro == 1 and !Pl:GetNWBool("isMonster") then
            
        surface.SetDrawColor( Color(1,1,1,255) )
		surface.DrawRect( 0, 0, ScrW(), ScrH() )
	
		draw.DrawText("Welcome to", "NameTag_Normal", ScrW() / 2, ScrH() / 2 - 200, Color(255, DownBlood, DownBlood, AlphaIntro ), TEXT_ALIGN_CENTER)
		draw.DrawText("Your Death..", "NameTag_Normal", ScrW() / 2, ScrH() / 2 - 80, Color(255, DownBlood, DownBlood, AlphaIntro - 50 ), TEXT_ALIGN_CENTER)
		
		// Its actually a cool effect :o
		DrawMaterialOverlay( "models/props_c17/fisheyelens", -0.06 )

		if IntroCD - 8 <= CurTime() then
			if DownBlood > 0 then
				DownBlood = DownBlood - FrameTime()*30
			end
		end		
		
    		if IntroCD <= CurTime() then
    			if AlphaIntro > 0 then
    				AlphaIntro = AlphaIntro - 1
    			elseif AlphaIntro <= 0 then
    			    
    				Pl.InIntro = 0
    				
    				if IsValid(IntroSound) then
    				   IntroSound:Stop() 
    				end
    				
    				sound.PlayURL ( "https://xss.failcake.me/minigames/scary/gbm_ambient_"..math.random(1,5)..".mp3", "", function( station )
            			if IsValid( station ) then
            				AmbientSound = station
            				AmbientSound:Play()
            				AmbientSound:SetVolume( 1 )
            				
            				table.insert(PlayingAmbients,AmbientSound)
            			end
        		    end)
        		
        		    net.Start("ScaryIntroEnd")
    	            net.SendToServer()
    			end
    		else
    			if AlphaIntro <= 255 then
    				AlphaIntro = AlphaIntro + FrameTime()*70
    			end
		end
		
    elseif Pl.InIntro == 0 or Pl:GetNWBool("isMonster") then
        
            surface.SetDrawColor( Color(30,30,30,100) )
    	    surface.DrawRect( 50, 50, 250, 200 )
    	    
    	    if Pl:GetNWBool("isMonster") then
    	        draw.DrawText("Todo List, Kill everyone.", "DeathList", 85,55, Color(255, 255, 255, 200 ))
            else
                draw.DrawText("==== Survive the Monster ====", "DeathList", 65,55, Color(255, 255, 255, 200 ))
            end
            
            for i,v in pairs(PlayerAlive) do
                if !IsValid(v) then return end
                
                if v:GetNWBool("isMonster") then
                    draw.DrawText("THE MONSTER", "DeathList", 65,60 + i*20, Color(155, 0, 0, 200 ))
                else
                    draw.DrawText(v:RealNick(), "DeathList", 65,60 + i*20, Color(255, 255, 255, 200 ))
                end
                
            end
        
    
    end
    
        if Pl:GetNWBool("isBlinded") and Pl:GetNWBool("isMonster") then
            
            surface.SetDrawColor( Color(1,1,1,255) )
    	    surface.DrawRect( 0, 0, ScrW(), ScrH() )
    	    
            // Its actually a cool effect :o
		    DrawMaterialOverlay( "models/props_c17/fisheyelens", -0.06 )
		
    	    draw.DrawText("Leave No", "NameTag_Normal", ScrW() / 2, ScrH() / 2 - 200, Color(255, 0, 0, 255 ), TEXT_ALIGN_CENTER)
		    draw.DrawText("Survivors", "NameTag_Normal", ScrW() / 2, ScrH() / 2 - 80, Color(255, 0, 0, 255 ), TEXT_ALIGN_CENTER)
		    draw.DrawText("Getting released soon..", "DeathList", ScrW() / 2, ScrH() / 2 + 100, Color(255, 255, 255, 255 ), TEXT_ALIGN_CENTER)
		    
    	end
    	
    end
    
    net.Receive("SynkTimer",function(len,pls) 
        ClockTime = net.ReadDouble()
    end)
    
    function DrawClock()
        
        if !IsPlaying then return end
        
        local Clock = string.ToMinutesSeconds( ClockTime )
        local Col = Color(255,255,255,255)
        
        if ClockTime <= 120 and ClockTime > 60 then
            Col = Color(255,200,0,255)
        elseif ClockTime <= 60 then
            Col = Color(255,0,0,255)
        end
        //-2173.876953 4978.697754 -13725.722656 META3 // -2222.3452148438,4982.376953125,-13680.197265625
        cam.Start3D2D(Vector (-2173.876953,4978.697754,-13725.722656), Angle (0, 0, 90 + 45), 3)
        
    		draw.DrawText("00:"..Clock, "NameTag_Blur", 0, 0, Col, TEXT_ALIGN_CENTER)
    		draw.DrawText("00:"..Clock, "NameTag_Normal", 0, 0, Color(255,255,255,255), TEXT_ALIGN_CENTER)
    		
    	cam.End3D2D()

    end
    
    function DrawGameProgress()
        
        if !LocalPlayer():Alive() then return end
        
        local Clock = string.ToMinutesSeconds( ClockTime )
        local LIVE = tostring(#PlayerAlive - 1) or "??"
        
        cam.Start3D2D(Vector (-4248.0317382812, 3426.9677734375, -15782.184570312), Angle (0, -90, 90), 0.1)
	
            draw.RoundedBox( 0, -2000, -500, 4000, 1000, Color(1,1,1,255) )
            draw.DrawText("Time Left", "TagScrnHorror", -1100, -360, Color(255,0,0), TEXT_ALIGN_CENTER)
            
    		draw.DrawText("00:"..Clock, "NameTag_Blur", -1100, -300, Color(255,255,255,255), TEXT_ALIGN_CENTER)
    		draw.DrawText("00:"..Clock, "NameTag_Normal", -1100, -300, Color(255,255,255,255), TEXT_ALIGN_CENTER)
    		
    		draw.DrawText("Survival in Progress" , "TagScrnHorror_Title_Blur", 0, -150, Color(255,0,0), TEXT_ALIGN_CENTER)
    		draw.DrawText("Survival in Progress" , "TagScrnHorror_Title", 0, -150, Color(255,0,0), TEXT_ALIGN_CENTER)
    		
    		draw.DrawText("====================", "TagScrnHorror", 0, 0, Color(255,255,255), TEXT_ALIGN_CENTER)
    		draw.DrawText("Survivors : " .. LIVE, "TagScrnHorror", 0, 70, Color(255,255,255), TEXT_ALIGN_CENTER)
    	
	    cam.End3D2D()
	    
    end
    
    hook.Add("RenderScreenspaceEffects","ScrEffScary",function()
        
        if !IsPlaying then return end
        
	    DrawColorModify( tab )
        DrawToyTown( 2, ScrH()/2 )
        
    end)
    
    function HorrorCamera(ply, pos, angles, fov)
        if !IsPlaying then return end
        
    	local view = {}
    
        view.origin = pos
        view.angles = angles
        view.fov = fov
    	
    	if ply:GetMoveType() != MOVETYPE_NOCLIP then
    		local Spin = (80 * 500 ) / 100
    		
    		view.angles.pitch = view.angles.pitch + (ply:GetVelocity():Length() / math.Clamp(Spin,50,500)) * math.sin(CurTime() * 5)
    		view.angles.roll = view.angles.roll + (ply:GetVelocity():Length() / math.Clamp(Spin,50,500)) * math.cos(CurTime() *  3)
    	end
    	
    	return view
    end
    
end


if SERVER then
	
        hook.Add("EntityTakeDamage", "NoFokYou", function(target, dmginfo) 
	        if IsValid(target) and !target:IsPlayer() then
	    
	        	if IsValid(target:CPPIGetOwner()) and target:CPPIGetOwner():SteamID() == "STEAM_0:1:20785590" then
	        		dmginfo:SetDamage(0)
	           		return true
	            end
            end
        end)
        
end
