// By Failcake: https://failcake.me
// =======================================

local Tag = "Beatwar"

// EFFECT
if CLIENT then
	
	local EFFECT = {}
	function EFFECT:Init( data )
	
		self.Pos = data:GetOrigin( )

		local emitter = ParticleEmitter( self.Pos )
		
		for i=1,40 do
			local particle = emitter:Add( "effects/yellowflare", self.Pos + VectorRand() * 5)
			particle:SetColor(230,230,230)
			particle:SetStartSize( math.Rand(5,10) )
			particle:SetEndSize( 0 )
			particle:SetStartAlpha( 250 )
			particle:SetEndAlpha( 0 )
			particle:SetDieTime( math.Rand(1,3) )
			particle:SetVelocity( VectorRand() * 100 + Vector(0,0,50) )
			
			particle:SetBounce(0.8)
			particle:SetGravity( Vector( 0, 0, -150 ) )
			particle:SetCollide(true)
		end
		
		local particle = emitter:Add( "effects/yellowflare", self.Pos)
		particle:SetColor(230,230,230)
		particle:SetStartSize( 20 )
		particle:SetEndSize( 0 )
		particle:SetStartAlpha( 250 )
		particle:SetEndAlpha( 0 )
		particle:SetDieTime( 2 )
		particle:SetVelocity( Vector(0,0,0) )
			
		particle:SetBounce(0)
		particle:SetGravity( Vector( 0, 0, 0 ) )
		
		emitter:Finish( )
		
	end
	
	function EFFECT:Think( )
		return false
	end
	
	function EFFECT:Render( )
	
	end
	
effects.Register( EFFECT, "powerup_get" )
end
	

// ENTITIES

easylua.StartEntity("beat_floor")

ENT.PrintName		= "BeatFloor"
ENT.Author			= "FailCake"
ENT.RenderGroup 	= RENDERGROUP_OPAQUE

function ENT:Initialize()
	
	if SERVER then
			
		self:SetModel("models/hunter/plates/plate2x2.mdl")
		self:SetMaterial("models/combine_scanner/scanner_eye")
		
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_OBB )
		self.PhysgunDisabled = true
		
		self:SetTrigger( true )

		self.ClaimerTeam = nil
		self.LastClaim = 0
		self.Powerup = nil
		self.GridPos = 0
		
		self.IsOcupied = nil
		
		local phys = self:GetPhysicsObject()
		
		if IsValid(phys) then
			phys:Wake()
			phys:EnableMotion( false )
		end
		
	end
	
end

function ENT:SetOc(fl)
	self.IsOcupied = fl	
end

function ENT:IsOc()
	return self.IsOcupied	
end

function ENT:SetGridPos(pos)
	self.GridPos = pos	
end

function ENT:GetGridPos()
	return self.GridPos	
end

function ENT:SetWorldGridPos(pos)
	self.WorldGridPos = pos	
end

function ENT:GetWorldGridPos()
	return self.WorldGridPos	
end

function ENT:Clean(blinktime)
	
	self:Blink(blinktime,false)
		
	self.ClaimerTeam = nil
	self.LastClaim = 0
	
end

function ENT:Blink(blinktime,leave)
	self.BlinkTime = blinktime
	self.HasBlink = false
	self.OldColor = self:GetClaimTeam().TeamColor
	self.DoBlink = true
	self.BlinDX = 0
	self.LeaveColor = leave
end

function ENT:Think()
	if self.DoBlink == nil then return end
	
	if self.DoBlink then
		

		if RealTime() > self.BlinkTime then
			self.BlinkTime = RealTime() + 0.03
			
			if self.BlinDX >= 6 then
				if !self.LeaveColor then
					self:SetColor(Color(255,255,255))
				else
					self:SetColor(self.OldColor)
				end
				self.DoBlink = false
			else
				self.BlinDX = self.BlinDX + 1
				
				if self.HasBlink then
					self:SetColor(Color(255,255,255))
					self.HasBlink = false
				else
					self:SetColor(self.OldColor)
					self.HasBlink = true
				end

			end
			
		end
	else
		
		local claim = self:GetClaimTeam()
		if claim != nil then
			self:SetColor(claim.TeamColor)	
		end
		
	end

	self:NextThink( CurTime() )
	return true
end

function ENT:GetClaimTeam()
	return self.ClaimerTeam
end

function ENT:SetPowerup( ent )
	if ent:GetClass() != "beatfloor_powerup" then return end
	self.Powerup = ent
end

function ENT:RocketPass()
	
	timer.Simple(0.3,function()
		self:SetMaterial("models/combine_scanner/scanner_eye")	
	end)
	
	self:SetMaterial("models/XQM/LightLinesRed_tool")
	
end

function ENT:SetClaimer(team)
	
	self.LastClaim = CurTime() + 0.5
	self.ClaimerTeam = team
	self:SetColor(team.TeamColor)
	
	// TODO : CHANDE THIS
	self:EmitSound("ui/trade_changed.wav")	
end

function ENT:Touch( ent )
	
	if !IsValid(self) then return end
	if !IsValid(ent) or !ent:IsPlayer() then return end
	if !ent:IsPlaying() then return end
	if self.DoBlink then return end // Do not capture while blinking
	
	if CurTime() < self.LastClaim then return end
	
	local ClaimTeam = ent:GetMiniTeamSettings() or nil
	if ClaimTeam == nil then return end
	
	// Check Powerups
	if self.Powerup != nil and self.Powerup.IsReady then
		self.ClaimerTeam = ClaimTeam
		self.Powerup:DoPowerup(self:GetClaimTeam(),ent)
		self:SetClaimer(ClaimTeam)
		self.Powerup = nil
		return
	end
	
	if self.ClaimerTeam != nil and self:GetClaimTeam().ID == ClaimTeam.ID then 
		return 
	end
	
	self:SetClaimer(ClaimTeam)

end

function ENT:CanProperty(ply,sr)
	return false	
end

easylua.EndEntity()

easylua.StartEntity("beatfloor_powerup")

ENT.PrintName		= "BeatFloor Powerup"
ENT.Author			= "FailCake"
ENT.RenderGroup 	= RENDERGROUP_BOTH

function ENT:Initialize()
	
	if SERVER then

		if math.random(1,4) == 2 then
			if math.random(1,4) == 2 then
				self.SetPowerupType = "arrowpoint"
			else
				self.SetPowerupType = "rocket"
			end
		else
			self.SetPowerupType = "countpoints"
		end
		
		
		self:SetMaterial("models/debug/debugwhite")
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
		
		if self:GetPowerup() == "countpoints" then
			
			self:SetModel("models/props_junk/wood_crate001a.mdl")
			self:SetColor(Color(127,0,95))
			self:PrecacheGibs()
			self.Spin = 0
			
		elseif self:GetPowerup() == "arrowpoint" then
			
			self:SetModel("models/props_hydro/cap_point_arrow_small.mdl")
			self:SetMaterial("")
			self:SetAngles(Angle(-90,-90,0))
			self.NextRotate = 0
			self.RndRotate = math.random(0.5,2)
			self.RotateID = 1
			
		elseif self:GetPowerup() == "rocket" then
			
			self:SetModel("models/weapons/w_models/w_rocket.mdl")
			self:SetMaterial("")
			self.Spin = 0
			
		end

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_NONE )
		self.PhysgunDisabled = true
		
		self.LiveTime = CurTime() + 5
		self.IsDestroying = false
		self.ColorSl = self:GetColor()
		
		self:SetTrigger( true )
		self.IsReady = false
		self.Pos = self:GetPos()
		
		self:SetNoDraw(false)
		
		local phys = self:GetPhysicsObject()
		
		if IsValid(phys) then
			phys:Wake()
			phys:EnableMotion( false )
		end
		
		
		self.PowerBtm = ents.Create("prop_dynamic")
		self.PowerBtm:SetModel("models/pickups/emitter.mdl")
		self.PowerBtm:SetSolid( SOLID_NONE )
		self.PowerBtm:SetPos(self:GetPos() - Vector(0,0,28))
		self.PowerBtm:Spawn()
		
		local phys = self.PowerBtm:GetPhysicsObject()
		
		if IsValid(phys) then
			phys:Wake()
			phys:EnableMotion( false )
		end
		
		self:SetPos(self.Pos+Vector(0,0,200))
		
	end
	
end

function ENT:RemoveMe()
	if IsValid(self.PowerBtm) then self.PowerBtm:Remove() end
	self:Remove()	
end
 
function ENT:GetPowerup()
	return self.SetPowerupType	
end

function ENT:DoPowerup(team,call)
	
	if self.IsReady then
		
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() ) 
		util.Effect( "powerup_get", effectdata )
		
		DoPowerUp(self,team,call)
		
		if self:GetPowerup() == "countpoints" then
			self:EmitSound("physics/wood/wood_crate_break1.wav")
			self:GibBreakServer(Vector(0,0,0))
		end	
		
		self:RemoveMe()
	end
end

function ENT:SetBeatOwn(beat)
	self.beatowner = beat
end

function ENT:GetBeatOwn()
	return self.beatowner	
end

function ENT:Think()
	
	if SERVER then
		
		if !IsValid(self) then return end
		
		if self.UpPos == nil then
			self.UpPos = 200	
		end
		
		if !self.IsReady then
			if self.UpPos > 0 then
				self.UpPos = self.UpPos - 5
				self:SetPos(self.Pos + Vector(0,0,self.UpPos))
			else
				self.UpPos = 0
				self:SetPos(self.Pos)
				self.IsReady = true
				self:EmitSound("misc/doomsday_lift_stop.wav")
			end
		else
		
			if self:GetPowerup() == "arrowpoint" then
				
				if self.NextRotate < CurTime() then
					self.NextRotate = CurTime() + self.RndRotate
					self:SetAngles(self:GetAngles() + Angle(0,90,0))
						
					if self.RotateID < 4 then
						self.RotateID = self.RotateID + 1
					else
						self.RotateID = 1
					end
	
				end
				
			elseif self:GetPowerup() == "countpoints" or self:GetPowerup() == "rocket" then
				self.Spin = self.Spin + 3
				self:SetAngles(Angle(0,self.Spin,0))
			end
		end
	
		self:NextThink( CurTime() )
		
		if self.LiveTime < CurTime() then
			if !self.IsDestroying then
				self.IsDestroying = true
				
				timer.Simple(1,function()
					if !IsValid(self) then return end
					
					local owner = self:GetBeatOwn()
					
					if owner != nil then
						owner.Powerup = nil
					end
					
					self:RemoveMe()
				end)
			end
			
			if self.ColorSl.a > 8 then
				self.ColorSl.a = self.ColorSl.a - 8
			else
				self.ColorSl.a = 0	
			end
		
			self:SetColor(self.ColorSl)
		end
		
		return true
	end
end

function ENT:CanProperty(ply,sr)
	return false	
end

easylua.EndEntity()

// SETTINGS

BeatWar = BeatWar or {}

BeatWar.DEBUGMODE = false
BeatWar.NOKICK = true

if SERVER then
	
BeatWar.MinPlayers = 2
BeatWar.MaxPlayers = 8

BeatWar.MUSIC = ""
BeatWar.MoveBEAT = 0

BeatWar.WaterModel = "models/hunter/plates/plate32x32.mdl"

// # - Wall
// O - Spawn
// = - Floor
BeatWar.Map = {
	
	NormalLvl = {
		"EEEEEEEEEEEE",
		"E##########E",
		"E#O======O#E",	
		"E#========#E",
		"E#========#E",
		"E#========#E",
		"E#========#E",
		"E#========#E",
		"E#========#E",
		"E#O======O#E",
		"E##########E",
		"EEEEEEEEEEEE"
	},

	CakeLvl = {
		"EEEEEEEEEEEEEEEEE",
		"E###############E",
		"E#####O===O#####E",	
		"E#####=====#####E",
		"E#####=====#####E",
		"E#####=====#####E",
		"E#O===========O#E",
		"E#=============#E",
		"E#=============#E",
		"E#=============#E",
		"E#O===========O#E",
		"E#####=====#####E",	
		"E#####=====#####E",
		"E#####=====#####E",
		"E#####O===O#####E",
		"E###############E",
		"EEEEEEEEEEEEEEEEE",
	},

	HenkeLvl = {
		"EEEEEEEEEEEEEEEEE",
		"E###############E",
		"E###O===#===O###E",
		"E##=====#=====##E",
		"E#=====###=====#E",
		"E#O=====#=====O#E",
		"E#=============#E",
		"E##===========##E",
		"E####===#===####E",
		"E##===========##E",
		"E#=============#E",
		"E#O=====#=====O#E",
		"E#=====###=====#E",
		"E##=====#=====##E",
		"E###O===#===O###E",
		"E###############E",
		"EEEEEEEEEEEEEEEEE"
	}
}

BeatWar.CurrentMap = BeatWar.Map.HenkeLvl

BeatWar.MusicSettings = {
	beatmusic_1 = {
		Music = "beatmusic_1",
		Path = "music_beat_1",
		Beat = 0.53
	},
	beatmusic_2 = {
		Music = "beatmusic_2",
		Path = "music_beat_2",
		Beat = 0.40
	},
	beatmusic_3 = {
		Music = "beatmusic_3",
		Path = "music_beat_3",
		Beat = 0.38
	},
	beatmusic_4 = {
		Music = "beatmusic_4",
		Path = "music_beat_4",
		Beat = 0.40
	},
	beatmusic_5 = {
		Music = "beatmusic_5",
		Path = "music_beat_5",
		Beat = 0.35
	}
}

BeatWar.MapData = BeatWar.MapData or {}
BeatWar.Spawns = {}
BeatWar.ValidFloors = BeatWar.ValidFloors or {}
BeatWar.ValidWalls = BeatWar.ValidWalls or {}

BeatWar.Size = 0

BeatWar.NoKick = me:SteamID()

BeatWar.PlayerModels = {
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
	
	BeatWar.Teams = {
		{ID = 1,Name = "Orange",TeamColor = Color(255,93,0),Players = {},Points = 0},
		{ID = 2,Name = "Blue",TeamColor = Color(0,161,255),Players = {},Points = 0},
		{ID = 3,Name = "Green",TeamColor = Color(127,255,0),Players = {},Points = 0},
		{ID = 4,Name = "Purple",TeamColor = Color(227,0,170),Players = {},Points = 0}
	}
	
	BeatWar.CurrentTeamMax = 1
	
	BeatWar.Players = {me,henke}
	BeatWar.OriginalPlayers = {}
	
	BeatWar.BANList = {"STEAM_0:1:32471837","STEAM_0:0:37146091","STEAM_0:1:46743640"}
	BeatWar.WhiteList = {}
	
	BeatWar.IsPlaying = false
	BeatWar.IsLoading = false
	BeatWar.LoadingPlys = {}
	
	BeatWar.CurrentTimer = BeatWar.CurrentTimer or 0
	BeatWar.HasMusicInfo = false

	local plymeta = FindMetaTable( "Player" )
	if not plymeta then Error("FAILED TO FIND PLAYER TABLE") return end
	    
	
	// INIT
    util.AddNetworkString( "PreloadComplete" )
    util.AddNetworkString( "PreloadSound" )
    util.AddNetworkString( "ldFinished" )
    
    util.AddNetworkString( "PlayWebMusic" )
    util.AddNetworkString( "StartClientside" )
    util.AddNetworkString( "SoundCommand" )
    
    util.AddNetworkString( "Voting" )
    util.AddNetworkString( "AnnouncePlayer" )
    util.AddNetworkString( "StartMinigame_"..Tag )
    
    util.AddNetworkString( "SendPoints" )
    util.AddNetworkString( "SendMusicInfo" )
    
    util.AddNetworkString( "SynkTimer" )
	util.AddNetworkString( "SelectMusic" )
	
	util.AddNetworkString( "AnnWin" )

    function plymeta:CanMoveBeat(move)
    	self:SetNWFloat("InBeat",move)
    	self:DoAnimationEvent(ACT_FLINCH_HEAD)
    end
    
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
	
	function plymeta:FinishedLoading()
		for _,v in pairs(BeatWar.Players) do
			if !IsValid(v) then continue end
			net.Start("ldFinished")
				net.WriteEntity(self)
			net.Send(v)
		end
    					
    	table.RemoveByValue(BeatWar.LoadingPlys,self)
	end
    
    // MINIGAME RELATED
    
    function plymeta:StunPlayer(tie)
    	if !IsValid(self) then return end
    	self.StunTime = CurTime() + tie
    	
    	self:DoAnimationEvent(ACT_HL2MP_RUN_ZOMBIE)	
		if self:GetPointMult() > 1 then
			self:requestMusic("lostmult",false)	
		end
			
		self.BeatCount = 0
		self:SetPointMult(1)
    	
    end
    
    function plymeta:RemoveRocket()
    	
    	if !IsValid(self) then return end
		if !IsValid(self.Rocket) then return end
		
		self.Rocket:Remove()
		self.Rocket = nil
    	self:SetNWBool("HasRocket",false)
   
    end
    
    function plymeta:HasRocket()
    	return self:GetNWBool("HasRocket")
    end
    
    function plymeta:GiveRocket()
    	
    	if !IsValid(self) then return end
		if IsValid(self.Rocket) then self.Rocket:Remove() end
		
        self.Rocket = ents.Create("prop_dynamic")
        self.Rocket:SetModel("models/weapons/w_models/w_rocket.mdl")
        self.Rocket:SetSolid(SOLID_NONE)
        
        self.Rocket.OFF = Vector(0,0,self:OBBMaxs().z + 10)
        self.Rocket:SetPos(self:GetPos() + self.Rocket.OFF)
        self.Rocket:Spawn()
        
        self.Rocket.PhysgunDisabled = true
        
        self.Rocket.RotateID = 1
        self.Rocket.RndRotate = math.random(0.5,2)
    	self.Rocket.NextRotate = 0
    	self.Rocket.IsLaunched = false
    	 
        local phys = self.Rocket:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:EnableMotion( false )
		end
		
		self:SetNWBool("HasRocket",true)
		
    end
    
    function plymeta:SelectSpawn()
    	
    	if !IsValid(self) then return end
    	if #BeatWar.Spawns <= 0 then 
    		print("No more spawn points!")
    		return 
    	end
    	
    	local GR = BeatWar.Spawns[1]
    	if GR == nil then return end
   
    	self:SetNWInt("CurrentIndex",GR:GetGridPos())
    	self:SetPos(GR:GetPos())
    	GR:SetOc(self)
    	table.remove(BeatWar.Spawns,1)
    end
    
    function plymeta:RestrainPlayer()
    	
    	if self:GetNWBool("RestrictedMg") then return end
    	
    	self.StunTime = 0
    	
    	self:Spawn()
    		
    	self:SetNWBool("RestrictedMg",true)
		self:SetNWBool("DisableUnstuck",true)
		
        self:ShouldDropWeapon( false )
        self:StripWeapons()
        self:Give("hands")
            
        self:ExitVehicle()
        self:GodDisable()
        
        self:ConCommand("pac_enable 0")
        self:ConCommand("playx_enabled 0")
        self:SetSolid(2)

        self.OldPACSize = self:GetModelScale()
        self.OldModel = self:GetModel()
        
        pac.SetPlayerSize(self,1) // Reset pac size
        pac.SetPlayerModel(self,BeatWar.PlayerModels[math.random(1,#BeatWar.PlayerModels)]) 
        
        self:SetNWInt("pac_size",self.OldPACSize)
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
        self:SetPointMult(1)
    end
    
    function plymeta:SetPointMult(num)
    	self:SetNWInt("CoinMult",num)	
    end
    
    function plymeta:GetPointMult()
    	return self:GetNWInt("CoinMult")	
    end
    
    
    function plymeta:ReleasePlayer()
    	
    	if !self:GetNWBool("RestrictedMg") then return end
    	
    	self:SetNWBool("RestrictedMg",false)
		self:SetNWBool("DisableUnstuck",false)
		
    	self:SetAllowNoclip(true, Tag)
        self:SetAllowBuild(true, Tag)
        
        self:SetSuperJumpMultiplier(1.5,false)
        self:SetWalkSpeed(200)
        self:SetRunSpeed(400)
        self:SetJumpPower(200)
        self:CrosshairEnable()
        
        self:Freeze(false)
        
        self.nossjump = false
        self.noleap = false
        self.DisableSit = false
        
        self:SprintEnable()
        
        local Oldsize = self.OldPACSize or 1
        pac.SetPlayerSize(self,Oldsize) // Reset pac size
        self.pac_player_size = Oldsize
        self.double_jump_allowed = true
        
        self.last_rip = CurTime()
        
        self:ShouldDropWeapon( false )
        self:StripWeapons()
        
        hook.Call("PlayerLoadout",self)

        self:ConCommand("pac_enable 1")
        self:ConCommand("playx_enabled 1")
        
        Watt.Enabled = true
        
        local OldModel = self.OldModel or ""
        
        if OldModel != "" then
            pac.SetPlayerModel(self,self.OldModel) 
        end
    end
    
    function plymeta:IsPlaying()
    	if !IsValid(self) then return end
    	return table.HasValue(BeatWar.Players,self)
    end
    
    function plymeta:GetMiniTeamSettings()
    	if !IsValid(self) or !self:IsPlaying() then return end
    	return BeatWar.Teams[self:GetNWInt("CurrentTeam")]
    end
    
    function plymeta:SetMiniTeam(force)
    	
    	if !IsValid(self) then return end
    	self:SetNWInt("CurrentTeam",0)
    	
    	local ID = force or 0
    	if ID == 0 then
    		
    		while self:GetNWInt("CurrentTeam") == 0 do
    	
    			for id,v in pairs(BeatWar.Teams) do
    				local Team = GetTeamPlys(id)
    				
    				if #Team.Players < BeatWar.CurrentTeamMax then
    					
    					self:SetNWInt("CurrentTeam",id)
    					table.insert(Team.Players,self)
    					print("Player Set to Team ".. Team.Name)
    					
    					return
    				end
				end
				
				if BeatWar.CurrentTeamMax < 4 then  
					BeatWar.CurrentTeamMax = BeatWar.CurrentTeamMax + 1
					print("All Teams Full, increasing limit")
				else
					print("Team overload. Abandoned")
					return	
				end
    		end
		else
			self:SetNWInt("CurrentTeam",ID)
		end
    end
    
    function plymeta:GetMiniTeam()
    	if !IsValid(self) or !self:IsPlaying() then return end
    	local plySettings = self:GetMiniTeamSettings()
    	
    	for _,v in pairs(BeatWar.Teams[plySettings.ID]) do
    		if table.HasValue(v,self) then
    			return v
    		end
    	end
	end
    
    // ROOM RELATED
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
    	if BeatWar.NOKICK then return end
        for i,p in pairs(ents.FindInBox(Vector(-144.563507,769.941833,-15850.163086), Vector(-4309.127441,5375.066406,-13562.069336))) do
            
            if IsValid(p) then
               if IsValid(p:CPPIGetOwner()) and p:CPPIGetOwner():SteamID() != "STEAM_0:1:20785590" then
                   print("["..Tag.."] Invalid Prop found from ".. p:CPPIGetOwner():Name())
                   p:Remove()
               end 
            end
            
        end
    end
    
    function PrepareMap()
    	
    	for _,v in pairs(ents.FindByModel(BeatWar.WaterModel)) do
    		if IsValid(v) then
               if IsValid(v:CPPIGetOwner()) and v:CPPIGetOwner():SteamID() == "STEAM_0:1:20785590" then
               	v:SetSolid(0)
               	v:SetMaterial("nature/underworld_lava001")
               end
            end
    	end
    	
    	if IsValid(BeatWar.DoorProt) then BeatWar.DoorProt:Remove() end
        BeatWar.DoorProt = ents.Create("prop_physics")
        BeatWar.DoorProt:SetModel("models/hunter/plates/plate6x7.mdl")
        BeatWar.DoorProt:SetMaterial("models/props_lab/cornerunit_cloud")
        BeatWar.DoorProt:SetPos(Vector (-4251.192383,3036.774414,-15812.869141))
        BeatWar.DoorProt:SetAngles(Angle(90,0,0))
        BeatWar.DoorProt:Spawn()
        BeatWar.DoorProt.PhysgunDisabled = true
        
        local phys = BeatWar.DoorProt:GetPhysicsObject()
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
    	
    end
   
   	// MINIGAME

   	function LoadStuff()
    	
    	BeatWar.IsLoading = true
    	
    	for _,v in pairs(BeatWar.Players) do
    		if !IsValid(v) then continue end
    		
    		local Pth = BeatWar.MusicSettings[BeatWar.MUSIC].Path
			v:preloadMusic(BeatWar.MUSIC,"http://failcake.me/minigames/Beatwar/"..Pth..".ogg",false,0.4) // Load Selected Music

			v:preloadMusic("beatintro","http://failcake.me/minigames/Beatwar/beatintro.ogg",false,0.7)
			
			v:preloadMusic("coin","http://failcake.me/minigames/Beatwar/getpoint_normal.ogg",false,0.5)
			v:preloadMusic("coin_big","http://failcake.me/minigames/Beatwar/getpoint_big.ogg",false,0.5)
			
			v:preloadMusic("beatmissed","http://failcake.me/minigames/Beatwar/sfx_missedbeat.ogg",false,0.8)
			v:preloadMusic("arrowpower","http://failcake.me/minigames/Beatwar/arrowpower.ogg",false,0.5)
			
			v:preloadMusic("rocketpower","http://failcake.me/minigames/Beatwar/rocketget.ogg",false,0.5)
			v:preloadMusic("rocketmiss","http://failcake.me/minigames/Beatwar/rocketmiss.ogg",false,0.5)
			v:preloadMusic("rockethit","http://failcake.me/minigames/Beatwar/rocketstun.ogg",false,0.5)
			

			v:preloadMusic("winmult","http://failcake.me/minigames/Beatwar/winmult.ogg",false,0.8)
			v:preloadMusic("lostmult","http://failcake.me/minigames/Beatwar/lostmult.ogg",false,0.5)

			v:preloadMusic("announce_3","http://failcake.me/minigames/bashannouncer_3.ogg",false,1)
			v:preloadMusic("announce_2","http://failcake.me/minigames/bashannouncer_2.ogg",false,1)
			v:preloadMusic("announce_1","http://failcake.me/minigames/bashannouncer_1.ogg",false,1)
			v:preloadMusic("announce_go","http://failcake.me/minigames/bashannouncer_go.ogg",false,1)
			
			v:preloadMusic("announce_welcome","http://failcake.me/minigames/Beatwar/ann_battle.ogg",false,1)
			v:preloadMusic("winnermusic","http://failcake.me/minigames/Beatwar/winner.ogg",false,1)
			
			v.LoadingTime = CurTime() + 30 // 20 seconds of load time.
			
    		table.insert(BeatWar.LoadingPlys,v)
    	end
    	
    	AnnounceGame("Loading Content.. please wait..","")
    	
    	if timer.Exists("CheckLoad") then
			timer.Destroy("CheckLoad")
		end
			
		timer.Create("CheckLoad",1,0,CheckLoad)
    end
  
    function RequestGlobal(id,over)
    	for _,v in pairs(BeatWar.Players) do
    		if !IsValid(v) then continue end
    		
			net.Start("PlayWebMusic")
				net.WriteString(id)
				net.WriteBool(over)
			net.Send(v)
		end
	end

	function AnnounceGame(strs,scary)
        
        for i,v in pairs(BeatWar.OriginalPlayers) do
            if !IsValid(v) then continue end
            net.Start("AnnouncePlayer")
                net.WriteString(strs)
                net.WriteString(scary)
            net.Send(v)
        end
    end
   
    function RemovePowers()
    	for _,v in pairs(ents.FindByClass("beatfloor_powerup")) do
    		if IsValid(v) then
    			v:RemoveMe()
    		end
		end	
    end
    
    function RemoveFloors()
    	for _,v in pairs(ents.FindByClass("beat_floor")) do
    		if IsValid(v) then
    			v:Remove()
    		end
		end
		
		for _,v in pairs(ents.FindByModel("models/hunter/blocks/cube2x2x1.mdl")) do
    		if IsValid(v) and v.IsWall then
    			v:Remove()
    		end
		end
    end

    
    function CreateFloors()
    	
    	AnnounceGame("Creating Map! Please wait.","")
    	
    	RemoveFloors()
		RemovePowers()
		
		local y = 1
		
		BeatWar.MapData = {}
		BeatWar.Spawns = {}
		BeatWar.ValidFloors = {}
		BeatWar.ValidWalls = {}
		
		local Map = BeatWar.CurrentMap
		BeatWar.Size = string.len(Map[1]) + 1
			
		local Size = 47.7
		--local InPos = Vector (-2194.2863769531, 3033.7631835938, -15507.552734375) - Vector(BeatWar.Size*Size,BeatWar.Size*Size,0)
		local InPos = Vector(-3906.228760, -45.971676, -11599.795898) - Vector(BeatWar.Size*Size,BeatWar.Size*Size,0)
		local LastSpawn = 0

		local WllFr = false

		hook.Add("Think","MAPBUILD",function()
			
			if LastSpawn > CurTime() then return end
			LastSpawn = CurTime() + 0.4
			
			local Type = Map[y]
			
			for x = 1,string.len(Type) do
		
				local Indx = y * BeatWar.Size + x
				
				local Char = string.GetChar(Type,x)
				local Pos = InPos + Vector(x*Size * 2,y*Size * 2,0)
		
				if Char == "=" or Char == "O" then
					
					local wall = ents.Create("beat_floor")
		    		wall:SetPos(Pos)
		    		wall:SetAngles(Angle(0,0,0))
		    		wall:Spawn()
		    		wall:SetGridPos(Indx)
		    		wall:SetWorldGridPos(Vector(x,y,0))
		    			
					BeatWar.MapData[Indx] = wall
					
					table.insert(BeatWar.ValidFloors,wall)
					
					if Char == "O" then
						table.insert(BeatWar.Spawns,wall)
					end
					
				elseif Char == "#" then

					local wall = ents.Create("prop_physics")
					wall:SetModel("models/hunter/blocks/cube2x2x1.mdl")
					wall.PhysgunDisabled = true
					wall:SetPos(Pos)
					wall:SetMaterial("models/props_viaduct_event/viaduct_cobblestone001")
					wall.IsWall = true
					wall.OldPos = wall:GetPos()
					wall.GRIDPOS = Vector(x,y,0)
					wall:Spawn()
					
					wall.ClrFlr = WllFr
					WllFr = !WllFr
					
					table.insert(BeatWar.ValidWalls,wall)
					
					local phys = wall:GetPhysicsObject()
					
			        if IsValid(phys) then
			            phys:EnableMotion(false)
			        end
							
					BeatWar.MapData[Indx] = wall
				elseif Char == "E" then
					BeatWar.MapData[Indx] = NULL
				end
				
			end
			
			y = y + 1
			WllFr = !WllFr
			
			if y > #Map then
				
				LoadStuff()
				hook.Remove("Think","MAPBUILD")
				
				return	
			end
		end)

	end

	function GetFloor(pos)
		local Indx = math.Round(pos.y) * BeatWar.Size + math.Round(pos.x)
		if Indx > table.Count(BeatWar.MapData) or Indx < BeatWar.Size then return nil end
		return BeatWar.MapData[Indx]
	end
    
    function GetFloorIndx(indx)
    	if indx > table.Count(BeatWar.MapData) or indx < BeatWar.Size then return nil end
    	return BeatWar.MapData[indx]	
    end
    
    function FloorToWorld(indx)
    	return Vector(math.Round(indx / BeatWar.Size),math.Round(indx % BeatWar.Size),0)	
    end
    
    function GetPoints(ply)
    	if !IsValid(ply) or !ply:IsPlaying() then return end
    	if ply:GetMiniTeam() == nil then return end
    end
    
    function CreatePowerup()
   
    	local Loc = BeatWar.ValidFloors[math.random(1,#BeatWar.ValidFloors)]
    	if !IsValid(Loc) then return end
    	
    	if Loc.Powerup != nil then return end
    	
    	local powerup = ents.Create("beatfloor_powerup")
    	powerup:SetPos(Loc:GetPos() + Vector(0,0,30))
    	powerup:SetNoDraw(true)	
    	powerup:Spawn()
    	powerup:Activate()
		powerup:EmitSound("misc/doomsday_pickup.wav")
		

    	Loc:SetPowerup(powerup)
    	powerup:SetBeatOwn(Loc)
    end
    
	function GetTeamPlys(id)
		return BeatWar.Teams[id]
	end
	
	function DoPowerUp(powerENT,team,caller)
		
		if team == nil then return end
		
		local powerID = powerENT:GetPowerup()
		
		if powerID == "countpoints" then
			// todo count points
			local blnk = RealTime() + 0.3
			local points = 0
			
			for _,v in pairs(ents.FindByClass("beat_floor")) do
				if v:GetClaimTeam() != nil and v:GetClaimTeam().ID == team.ID and v:IsOc() == nil then
					v:Clean(blnk)
					points = points + 1
				end
			end
		
			points = points * caller:GetPointMult()
			
			if points > 50 then
				 RequestGlobal("coin_big",false)
			else
				 RequestGlobal("coin",false)
			end
			
			team.Points = team.Points + points
			
			local CL = team.TeamColor
			
			for _,v in pairs(BeatWar.Players) do
				if !IsValid(v) then continue end
				net.Start("SendPoints")
					net.WriteVector(powerENT:GetPos() + Vector(0,0,powerENT:OBBMaxs().z))
					net.WriteString(tostring(points))
					net.WriteDouble(team.ID)
					net.WriteVector(Vector(CL.r,CL.g,CL.b))
					net.WriteDouble(3)
				net.Send(v)
			end
			
			print("Team ".. team.Name.." claimed ".. points.." points")
			
		elseif powerID == "arrowpoint" then
			
			local RotateID = powerENT.RotateID
			local pown = powerENT:GetBeatOwn()
			
			if IsValid(pown) then
				local Pos = pown:GetWorldGridPos()
				local VEC = IDAng(RotateID)
				local Tries = 0

				local Bl = CurTime() + 0.4 // Synk
				
				while(Tries < 100) do
	
					local PROP = GetFloor(Pos + VEC)
					if PROP == nil or PROP == NULL then break end
					
					if PROP.IsWall then
						Pos = PROP.GRIDPOS
					else
						PROP:SetClaimer(team)
						PROP:Blink(Bl,true)
						Pos = PROP:GetWorldGridPos()
					end
					
					Tries = Tries + 1	
				end
				
				RequestGlobal("arrowpower",false)
				
			end
			
		elseif powerID == "rocket" then
			
			if caller:HasRocket() then return end
			caller:GiveRocket()
			RequestGlobal("rocketpower",false)
			
		end
	end
	
	function IDAng(id)
		local VEC = Vector(0,0,0)
		if id == 3 then
			VEC = Vector(-1,0,0)
		elseif id == 1 then
			VEC = Vector(1,0,0)
		elseif id == 4 then
			VEC = Vector(0,-1,0)
		elseif id == 2 then
			VEC = Vector(0,1,0)
		end	
		return VEC
	end
	
	    // GAME
    function StartBeatWar()
        
       if BeatWar.DEBUGMODE then 
	       print("["..Tag.."] Minigame in debug mode! Disable it first.")
	       return 
       end
       
       table.Empty(BeatWar.Players)
       
       net.Start("Voting")
       	net.WriteBool(false)
       net.Broadcast()
       
       local Title = "Play " .. Tag .. " minigame? (Max Players -> "..BeatWar.MaxPlayers.." | Min Ply Hours : 13)"
       
       GVote.Vote(Title,
				"Yes",
		function(results)
		    
			local Ys = results.Yes
				
		    for i,v in pairs(Ys) do
		        if !table.HasValue(BeatWar.WhiteList,v) then
		        	table.insert(BeatWar.WhiteList,v)
		        end
	        end
	    
	        if #Ys <= 0 then
	            print("["..Tag.."] Not enough players :<! ABORTED")
	            
	            return
	        end
			
			timer.Simple(5,function()
				
				net.Start("Voting")
		       		net.WriteBool(true)
		       	net.Broadcast()
				
			    INITMinigame()
			    
			end)  
			
		end)
		
    end
	
	
	function INITMinigame()
		
		if !BeatWar.DEBUGMODE then
	        if #BeatWar.WhiteList <= 1 then
	           print("[BeatWar] Not Enough whitelisted players! ABORTED!")
	           return 
	        end
	        
	        // Whitelist Players
	        for i,v in pairs(player.GetAll()) do
	            if !IsValid(v) then continue end
	            if v:IsPirate() != nil then continue end
	            if tonumber(v:GetUTime()) < 41715 then continue end // 13h min
	            
	            if #BeatWar.Players > BeatWar.MaxPlayers - 1 then
			    	print("[BeatWar] Max Players Limit Reached")
			    	break
			    end
	            
	            if table.HasValue(BeatWar.WhiteList,v:SteamID()) then
	               if !table.HasValue(BeatWar.BANList,v:SteamID()) then
	                  table.insert(BeatWar.Players,v) 
	               else
	                  print("["..Tag.."] Player " .. v:RealNick() .. " is BANNED!")
	                  v:ChatPrint( "["..Tag.."] You are banned from the minigame! :C" )
	               end
	            end
	        end
    	end
    
    	table.Empty(BeatWar.OriginalPlayers)
    	BeatWar.OriginalPlayers = table.Copy(BeatWar.Players)
    	
    	// MUSIC DATA
    	SetGlobalBool(4453,false) // HasData
		BeatWar.CurrentTimer = 9999
		///
		
    	// Reset
    	BeatWar.Teams = {
			{ID = 1,Name = "Orange",TeamColor = Color(255,93,0),Players = {},Points = 0},
			{ID = 2,Name = "Blue",TeamColor = Color(0,161,255),Players = {},Points = 0},
			{ID = 3,Name = "Green",TeamColor = Color(127,255,0),Players = {},Points = 0},
			{ID = 4,Name = "Purple",TeamColor = Color(227,0,170),Players = {},Points = 0}
		}
    	
    	for _,v in pairs(BeatWar.Players) do
    		
    		if !IsValid(v) then continue end
    		
	    	net.Start("StartMinigame_"..Tag)
	    		net.WriteTable(BeatWar.Players)
	    	net.Send(v)
	    
			v:SetMiniTeam()
			v:SetNWBool("IsPlaying",true)
			v:RestrainPlayer()
    	end
    	
    	SelectMusic("")
    	
		PrepareMap()
		CreateFloors()
    	SetupHooks()

    	
    end
	
	function SelectMusic(force)
		local fr = force or ""
		local Tbl = ""
		
		if fr == "" then
			Tbl = table.Random(BeatWar.MusicSettings)
		else
			Tbl = BeatWar.MusicSettings[force]
		end
		
		if Tbl == nil then
			Tbl = BeatWar.MusicSettings["beatmusic_2"]
			print("Requested Music Not Found! Setting Default!")
			return	
		end
		
		BeatWar.MUSIC = Tbl.Music
		BeatWar.MoveBEAT = Tbl.Beat
		
		for _,v in pairs(BeatWar.Players) do
			if !IsValid(v) then continue end
			net.Start("SelectMusic")
				net.WriteTable(Tbl)
			net.Send(v)
		end
		
		print("Selected Music " .. BeatWar.MUSIC)
	end
	
	function StartMinigame()

		BeatWar.IsLoading = false
		BeatWar.LastDrop = 0
		
		for _,v in pairs(BeatWar.Players) do
			if !IsValid(v) then continue end
			v:SelectSpawn()
			v.BeatCount = 0
		end
		
		RequestGlobal("beatintro",true)
		
		Countdown = 3
		
		timer.Simple(4,function()
			timer.Create("countdown",0.7,4,function()
					
					if Countdown > 0 then
						RequestGlobal("announce_"..Countdown,false)
						AnnounceGame("Game starting in ".. Countdown,"")
					else
						RequestGlobal("announce_go",false)
						AnnounceGame("GO GO GO!","")
					end
					
					Countdown = Countdown - 1
			end)
		end)
	
		timer.Simple(7.4,function()
			// Start Minigame
		
			RequestGlobal("stopintro",false)
			BeatWar.CurrentBeat = 0
			
			for _,v in pairs(BeatWar.Players) do
				if IsValid(v) then 
					v:Freeze(false)
				end
			end
		
			ACTIVATEMINIGAME()
			
		end)
	
	end
	
	function ACTIVATEMINIGAME()
		
		BeatWar.IsPlaying = true
		RequestGlobal(BeatWar.MUSIC,true)
		
		if timer.Exists("BEAT") then
			timer.Destroy("BEAT")
		end
		
		if timer.Exists("clockSynker") then
           timer.Destroy("clockSynker") 
        end
		
		timer.Create("clockSynker",1,0,SynkClock)
        SynkClock()
		
	end
	
	function MakeDance()
		for _,v in pairs(BeatWar.ValidWalls) do
			
			if !IsValid(v) or !v.IsWall then continue end
				
			if v.ClrFlr then
				v:SetColor(Color(255,93,0))
			else
				v:SetColor(Color(0,161,255))
			end
			v.ClrFlr = !v.ClrFlr
		end
	end
	
	function SetupHooks()
		
		hook.Add("Think",Tag,function()
    		if !BeatWar.IsPlaying then return end
    		
    		if !BeatWar.NOKICK then
	    		for v,i in pairs(ms.GetTrigger("vphys"):GetPlayers()) do
	                if !IsValid(v) then continue end
	                if v:SteamID() == BeatWar.NoKick then continue end
	                
	        	    if !table.HasValue(BeatWar.Players,v) then
	        	        v:SetPos(Vector(-4402.258789 + math.random(-100,100),3047.212891 + math.random(-100,100),-15827.968750)) 
	        	        v:ChatPrint( "["..Tag.."] You are not allowed in the minigame." )
	        	    end
	            end
			end
			
			if BeatWar.CurrentBeat < CurTime() then
				
				BeatWar.CurrentBeat = CurTime() + BeatWar.MoveBEAT
				
				for _,v in pairs(BeatWar.Players) do
					if IsValid(v) then
						v:CanMoveBeat(CurTime()+0.6) // Beat Error	
					end
				end
				
				MakeDance()
			end
			
			for _,v in pairs(BeatWar.Players) do
				
				if !IsValid(v) then continue end
				
				if !v:HasRocket() or !IsValid(v.Rocket) then continue end
				
				if !v.Rocket.IsLaunched then
					if v.Rocket.NextRotate < CurTime() then
						v.Rocket.NextRotate = CurTime() + v.Rocket.RndRotate
						v.Rocket:SetAngles(v.Rocket:GetAngles() + Angle(0,90,0))
						
						if v.Rocket.RotateID < 4 then
							v.Rocket.RotateID = v.Rocket.RotateID + 1
						else
							v.Rocket.RotateID = 1
						end
		
					end
				
					v.Rocket:SetPos(v:GetPos() + v.Rocket.OFF)
				else

					if v.Rocket.Attempts < CurTime() then
						v.Rocket.Attempts = CurTime() + 0.1

						local VEC = IDAng(v.Rocket.RotateID)
						local Pos = v.Rocket.LaunchPos
						
						local PROP = GetFloor(Pos + VEC)
					
						
						if PROP == nil or PROP == NULL then
							RequestGlobal("rocketmiss",false)
							v:RemoveRocket()
							continue
						end
						
						if !PROP.IsWall then
						
							PROP:RocketPass()
							
							v.Rocket.LaunchPos = PROP:GetWorldGridPos()
							v.Rocket:SetPos(PROP:GetPos() + v.Rocket.OFF)
							
							local Ocup = PROP:IsOc()
							
							if Ocup != nil and IsValid(Ocup) and Ocup:IsPlayer() then // Stun Player
								
								for _,v in pairs(BeatWar.Players) do
									if !IsValid(v) then continue end
									net.Start("SendPoints")
										net.WriteVector(Ocup:GetPos() + Vector(0,0,Ocup:OBBMaxs().z))
										net.WriteString("*STUNNED*")
										net.WriteDouble(-1)
										net.WriteVector(Vector(255,0,0))
										net.WriteDouble(1)
									net.Send(v)
								end
								
								Ocup:StunPlayer(math.random(3,4))
								RequestGlobal("rockethit",false)
								v:RemoveRocket()
							end
						else // ITS A WALL
						
							v.Rocket.LaunchPos = PROP.GRIDPOS
							v.Rocket:SetPos(PROP:GetPos() + v.Rocket.OFF)
							
						end
					
					end

					
				end
			end
			
			/*
			// ANTI-CHEAT
            
            for i,v in pairs(BeatWar.Players) do
               if !IsValid(v) then continue end
               
               if !ms.GetTrigger("vphys"):IsPlayerInside(v) then
                   v:AnnounceSingle("What were you doing outside!? GET BACK.","buttons/button11.wav")
                   v:TeleportPlayer()
            	end
        	end
        	*/
        	
        	if BeatWar.LastDrop < CurTime() then
				BeatWar.LastDrop = CurTime() + math.random(1,2)
				CreatePowerup()
    		end
    
	       	CleanupMap()
    	end)
    	
    	hook.Add("NetData",Tag,function(pl,name,io) 
            
            if !BeatWar.IsPlaying then return end
            
            if IsValid(pl) and pl:IsPlayer() then
                if pl:IsPlaying()  then
                    if name == "boxify" or name == "propify" or name == "coh" or name == "NameT" then return false end
                end
            end
        end)
        
    	hook.Add("PrePACConfigApply", Tag, function(ply, outfit_data)
            if ply:IsPlaying() then
                return false, "No PAC Allowed"
            end
        end)
        
        hook.Add("CanPlayerSuicide",Tag,function(ply)
            if ply:IsPlaying() then
                return false
            end
        end)
    
        hook.Add("PlayerShouldTakeDamage",Tag,function(ply,attacker)
            if ply:IsPlaying() then
                return false
            end
        end)
    
        hook.Add( "PlayerShouldTaunt", Tag, function( ply )
            if ply:IsPlaying() then
                return false
            end
        end )
        
        hook.Add("PlayerCanPickupItem",Tag,function(ply,item)
            if ply:IsPlaying() then
                return false
            end
        end) 
        
        hook.Add("PlayerCanPickupWeapon",Tag,function(ply,wep)
            if ply:IsPlaying() then
                return false
            end
        end)
        
        hook.Add("CanDropWeapon",Tag,function(ply)
            if IsValid(ply) and ply:IsPlayer() then
                if ply:IsPlaying() then
                    return false
                end
            end
        end)
        
        hook.Add("CanPlyTeleport",Tag,function(ply)
            if IsValid(ply) and ply:IsPlayer() then
                if ply:IsPlaying() then
                    return false,"Teleport Disabled on "..Tag
                end
            end
        end)
        
        hook.Add("CanPlyGotoLocations",Tag,function(ply)
            if IsValid(ply) and ply:IsPlayer() then
                if ply:IsPlaying() then
                    return false,"Goto Disabled on "..Tag
                end
            end
        end)

        hook.Add("CanPlyGotoPly",Tag,function(ply,ent)
            if IsValid(ply) and ply:IsPlayer() then
                if ply:IsPlaying() then
                    return false,"Goto Disabled on ".. Tag
                end
            end
        end)
        
        hook.Add("PlayerDisconnected",Tag,function(ply)
    		if IsValid(ply) and ply:IsPlaying() then
    			if BeatWar.IsLoading then
    				if table.HasValue(BeatWar.LoadingPlys,ply) then
    					
    					ply:FinishedLoading()
    					print("["..Tag.."] Aborted ".. ply:Name() .. " load - PLAYER DISCONNECTED")
    					
    				end
    			end
    		end
		end)
	
		hook.Add("StartCommand",Tag,function(ply,cmd)
			
			if !IsValid(ply) then return end
			if !ply:IsPlaying() then return end
			
			if cmd:KeyDown(IN_DUCK)  then
				cmd:RemoveKey( IN_DUCK )
			end

		end)
	
		hook.Add( "PlayerSay", Tag, function(pl,txt)
			if txt:lower():find("stuck",1,true) then
				return ""
			end
		end )
		
  		/*
  		hook.Add("CanProperty","Tag",function()
  			if IsValid(ent) and ent.MGOwn
  				return false
  			end
  		end)
  	
  		CanProperty( Player ply, string property, Entity ent )
  		*/
  		
		hook.Add("KeyPress",Tag,KeyPressed)
	end

	function ClearHooks()
		hook.Remove("Think",Tag)
		
		hook.Remove("KeyPress",Tag)	
		
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
		
		hook.Remove("StartCommand", Tag)
		hook.Remove("PlayerSay", Tag)
	end

	function ENDMinigame()
		
		if timer.Exists("BEAT") then
			timer.Destroy("BEAT")
		end
		
		if timer.Exists("clockSynker") then
           timer.Destroy("clockSynker") 
        end
		
		ClearHooks()
		
		if IsValid(BeatWar.DoorProt) then BeatWar.DoorProt:Remove() end
    	if IsValid(BeatWar.Skybox) then BeatWar.Skybox:Remove() end
    	
    	BeatWar.IsPlaying = false

    	for _,v in pairs(BeatWar.OriginalPlayers) do
    		if !IsValid(v) then continue end
    		
    		v:ReleasePlayer()
    		v:SetNWBool("IsPlaying",false)
    		v:RemoveRocket()
    		
	    	net.Start("SoundCommand")
	    		net.WriteString("ENDHOOKS")
	    	net.Send(v)
    	end
    	   

    	ClearHooks()
    	SetVPhysRoom(true)
    	HideScreen(false)
    	
    	RemoveFloors()
		RemovePowers()
    	
    	 // The Door
        local fnd = ents.FindInSphere(Vector(-4259.864258,3031.825928,-15790.468750),100)
        for i,v in pairs(fnd) do
            if v:GetClass() == "func_door" then
                v:Fire("Unlock")
                v:Fire("Open")
            end
        end
		
	end
	
	function SynkClock()
        
        BeatWar.CurrentTimer = BeatWar.CurrentTimer - 1
        
        for i,v in pairs(BeatWar.Players) do
            if !IsValid(v) then continue end
            
            net.Start("SynkTimer")
                net.WriteDouble(BeatWar.CurrentTimer)
            net.Send(v)
        end
        
        if BeatWar.CurrentTimer < 0 and BeatWar.IsPlaying then
        	// DO WINNER HERE
        	DoWin()
        end
        
    end
    
    function DoWin()
    	
    	local WinTeam = nil
    	local MAXPOINT = 0
    	
		BeatWar.IsPlaying = false
		
		StopMusics()
		RequestGlobal("winnermusic",true)
		
    	for _,v in pairs(BeatWar.Teams) do
    		local Points = v.Points
    		if Points > MAXPOINT then
    			MAXPOINT = Points
    			WinTeam = v
    		end
    	end
    	
    	if WinTeam != nil then
    		
	    	for _,v in pairs(BeatWar.Players) do
	    		if !IsValid(v) then continue end
	    		
		    	net.Start("AnnWin")
		    		net.WriteTable(WinTeam)
		    	net.Send(v)
		    	
	    	end
    	end
    	
    	timer.Simple(12,ENDMinigame)
    	
    end
	
	function CheckLoad()
		
		for _,v in pairs(BeatWar.LoadingPlys) do
			
			if !IsValid(v) then
				v:FinishedLoading()
    			print("["..Tag.."] Aborted ".. v:Name() .. " load - INVALID PLAYER")
			end
			
			local Tim = v.LoadingTime
			if Tim < CurTime() then
				v:FinishedLoading()
    			print("["..Tag.."] Aborted ".. v:Name() .. " load - TIMEOUT")
			end
		end
		
		if #BeatWar.LoadingPlys <= 0 and BeatWar.IsLoading then
			
			if timer.Exists("CheckLoad") then
				timer.Destroy("CheckLoad")
			end
		
			BeatWar.IsLoading = false
			print("Finished Loading.")
			
			timer.Simple(3,function()
				
				net.Start("StartClientside")
				net.Broadcast()
				
				StartMinigame()
				
			end)
		
		end	
	end
	
	net.Receive("PreloadComplete",function(len,ply)
    	
    	if !IsValid(ply) or !ply:IsPlayer() then return end
    
		print(ply:Name() .. " finished loading.")
		ply:FinishedLoading()
		
	end)
	
	net.Receive("SendMusicInfo",function(len,ply)
		if !GetGlobalBool(4453) then
			local Time = net.ReadDouble()
			
			print("Recieved music data from player " .. ply:Name() .. ". Thanks :D!")
			print("=== DATA ===")
			print("= Time : " .. Time .. " =")
			
			SetGlobalBool(4453,true)
			BeatWar.CurrentTimer = Time

		end
	end)
	
	function KeyPressed(ply,key)
		
		if !BeatWar.IsPlaying then return end
		if !IsValid(ply) or !ply:IsPlaying() or ply.StunTime > CurTime() then return end
		
		local Beat = ply:GetNWFloat("InBeat")
		
		if Beat < CurTime() then
			ply:requestMusic("beatmissed",false)
			
			if ply:GetPointMult() > 1 then
				ply:requestMusic("lostmult",false)	
			end
			
			ply.BeatCount = 0
			ply:SetPointMult(1)
			return 
		end
		
		
		local indx = ply:GetNWInt("CurrentIndex")
		if indx == 0 or indx == nil then return end

		local posGR = GetFloorIndx(indx)
		if posGR == nil then return end
	
		local pos = posGR:GetWorldGridPos()
		
		if key == IN_USE then
			if ply:HasRocket() and !ply.Rocket.IsLaunched and IsValid(ply.Rocket) then
				
				ply.Rocket.IsLaunched = true
				ply:EmitSound("weapons/rpg/rocketfire1.wav")
				ply.Rocket.LaunchPos = pos
				ply.Rocket.Attempts = 0
				
			end
		end
		
		local FLOOR = nil

		// Left
		if key == IN_FORWARD then
			FLOOR = GetFloor(pos + Vector(1,0,0))
			ply:SetEyeAngles(Angle(0,0,0))
		elseif key == IN_BACK then
			FLOOR = GetFloor(pos + Vector(-1,0,0))
			ply:SetEyeAngles(Angle(0,180,0))
		elseif key == IN_MOVELEFT then
			FLOOR = GetFloor(pos + Vector(0,1,0))
			ply:SetEyeAngles(Angle(0,90,0))
		elseif key == IN_MOVERIGHT then
			FLOOR = GetFloor(pos + Vector(0,-1,0))
			ply:SetEyeAngles(Angle(0,-90,0))
		end
		
		if FLOOR != nil and FLOOR:GetClass() == "beat_floor" and FLOOR:IsOc() == nil then
			
			ply:CanMoveBeat(CurTime()) // No.
			ply:SetPos(FLOOR:GetPos() + Vector(0,0,1))
			ply:SetNWInt("CurrentIndex",FLOOR:GetGridPos())
			
			ply.BeatCount = ply.BeatCount + 1
			
			if ply.BeatCount > 10 then
				ply.BeatCount = 0
				
				local mult = ply:GetPointMult()
				
				if mult < 3 then
					ply:SetPointMult(mult + 1)
					ply:requestMusic("winmult",false)
				end
			end
			
			posGR:SetOc(nil)	
			FLOOR:SetOc(ply)
		
			
		end
	end

end

if CLIENT then
	
	BeatWar.URLMusics = BeatWar.URLMusics or {}
	BeatWar.Players = BeatWar.Players or {}
	BeatWar.LoadPlayers = {}
	BeatWar.LoadingMusic = {}
	BeatWar.AlreadyLOADING = false
	
	// Load Stuff
	BeatWar.LastMusic = ""
	BeatWar.LoadInit = false
	
	BeatWar.WaitingPlys = false
	BeatWar.IsLoading = false
	
	BeatWar.Countdown = 0

	BeatWar.HINT = ""
	BeatWar.PointView = {}
	
	BeatWar.BeatView = {}
	BeatWar.LstBeat = 0
	
	BeatWar.InIntro = false
	BeatWar.IntroStage = 0
	
	BeatWar.PreparingMap = false
	
	BeatWar.WinningTeam = nil
	BeatWar.ENDED = false
		
	BeatWar.PlyQuadSphere = {
		texture = surface.GetTextureID( 'sprites/sent_ball' ),
		color	= Color( 255, 255, 255, 255 ),
		x 	= -32,
		y 	= -32,
		w 	= 64,
		h 	= 64
	}
	
	BeatWar.HINTS = {
		"Capture Colors with the purple boxes to win!",
		"Move at the beat of the music. Else you wont move at all!",
		"Minigame based on Crashbash and Crypt of the necrodancer!",
		"Press USE to launch the rocket and stun other foes!",
		"Make sure you move at the beat to earn multiplier points!"
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
	})
		
	surface.CreateFont( "NameTag_Blur",
	{
		 font = "Roboto",
		 size		= ScreenScale(54),
		 weight		= 400,
		 blursize = 4,
		 antialias = true
	})
	
	surface.CreateFont( "Points_TL",
	{
			font		= "DebugFixed",
			size		= ScreenScale(8),
			weight		= 1000
	}) 

	surface.CreateFont( "Points",
	{
			font		= "DebugFixed",
			size		= ScreenScale(5),
			weight		= 1000
	}) 

	surface.CreateFont( "Points_MULT",
	{
			font		= "DebugFixed",
			size		= ScreenScale(24),
			weight		= 1000
	}) 

	surface.CreateFont( "TIMER",
	{
			font		= "DebugFixed",
			size		= ScreenScale(32),
			weight		= 1000
	}) 

	net.Receive( "StartMinigame_"..Tag, function()
		
		BeatWar.Players = net.ReadTable() or {}
		BeatWar.Countdown = 4
		BeatWar.PointView = {}
		BeatWar.Points = {0,0,0,0}
		BeatWar.ClockTime = 0
		BeatWar.MoveBEAT = 0
		BeatWar.MUSIC = ""
		
		BeatWar.InIntro = false
		
		BeatWar.LoadPlayers = table.Copy(BeatWar.Players)
		
		hook.Add('PlayerBindPress',Tag,function(_,bind,pressed)
        	if string.find(bind,"gm_showspare1",1,true) and pressed then
        		return true
        	end
        end)
        
        hook.Add("HUDDrawTargetID",Tag,function()
            return false
        end)
        
        hook.Add("HUDShouldDraw",Tag,HideHUD)
		
		hook.Add("CalcView", Tag, function(ply,pos,angles,fov)
			
			if !IsValid(ply) then return end 
			if !ply:GetNWBool("IsPlaying") then return end
			local view = {}
	    	view.origin = Vector(pos.x - 500,pos.y,-15100)
	    	view.angles = Angle(40,0,0)
			view.fov = fov
			
	    	return view
	    	
		end)
		
		hook.Add("ShouldDrawLocalPlayer",Tag,function(ply)
			if !IsValid(ply) then return end 
			if !ply:GetNWBool("IsPlaying") then return end
			return true
		end)
	
		hook.Add("PreChatSound", Tag, function(ply)
			return false
		end)
        
        hook.Add("Think","LoadStuff",LoadThink)
        hook.Add("HUDPaint","LOADPaint",HUDLoadDraw)
        hook.Add("HUDPaint",Tag,HUDDraw)
        hook.Add("PostDrawOpaqueRenderables",Tag,DrawPoints)
        hook.Add("Think",Tag,ClientThink)
        
        hook.Add("SetupSkyboxFog",Tag,function(skyboxscale)

			render.FogMode( 1 ) 
			render.FogStart( 0 * skyboxscale )
			render.FogEnd( 800 * skyboxscale  )
			render.FogMaxDensity( 1 )
			render.FogColor( 0.5, 0.0, 0.0 )
			
			return true
		end)
		
		hook.Add("SetupWorldFog",Tag,function()
		
			render.FogMode( 1 ) 
			render.FogStart( 0 )
			render.FogMaxDensity( 1 )
			render.FogColor( 0.5, 0.0, 0.0 )
			render.FogEnd( 800 )
		
			return true
		end)
		
		        
        StopAllSounds()
		Watt.Enabled = false
		
		if timer.Exists("HintLoad") then timer.Destroy("HintLoad") end
		timer.Create("HintLoad",4,0,GetRandomHint)
		GetRandomHint()
		
		BeatWar.BeatView = {}
		
		BeatWar.LstBeat = 0
		BeatWar.MoveBEAT = 0
		BeatWar.MUSIC = ""
		
		BeatWar.LoadInit = false
		BeatWar.PreparingMap = true
		
		if BeatWar.LoadMusic != nil then
			BeatWar.LoadMusic:Stop()	
		end
			
			// Play loading Music, because yea.
		sound.PlayURL ("http://failcake.me/minigames/Beatwar/loading.ogg", "", function( station )
			if IsValid(station) then
					
				BeatWar.LoadMusic = station
				station:Play()
					
			end
		end)
		
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
		
		hook.Remove("Think",Tag)
		
		hook.Remove("PrePlayerDraw",Tag)
		hook.Remove("PreChatSound", Tag)
		
		hook.Remove("PostDrawOpaqueRenderables",Tag)
		hook.Remove("SetupSkyboxFog",Tag)
		hook.Remove("SetupWorldFog",Tag)
	end
	
	function EndMinigame()
		
		StopAllSounds()
		RemoveHooks()
		
		Watt.Enabled = true
		
		if BeatWar.LoadMusic != nil then
			BeatWar.LoadMusic:Stop()	
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
		if BeatWar.LoadMusic != nil then
			BeatWar.LoadMusic:Stop()	
		end
			
		for i,v in pairs(BeatWar.URLMusics) do
			if v != nil and v.Station != nil then
				v.Station:Pause()
				v.Station:SetTime(0)
			end
		end
	end
	
	function ClientThink()
		
		if BeatWar.IsLoading or BeatWar.InIntro then return end
		if BeatWar.MoveBEAT <= 0 then return end
		
		if BeatWar.LstBeat < CurTime() then
			
			BeatWar.LstBeat = CurTime() + BeatWar.MoveBEAT
			
			local TBL = {
				Alpha = 255,
				y = 1,
				x = math.random(-20,20),
				Yspeed = math.random(2,6)
			}
				
			table.insert(BeatWar.BeatView,TBL)
		end

		
	end
	
	function LoadThink()
		
		if #BeatWar.LoadingMusic <= 0 then 
			
			if BeatWar.LoadInit then
		
				BeatWar.LoadInit = false
				BeatWar.WaitingPlys = true
				
				net.Start("PreloadComplete")
				net.SendToServer()
				
			end
			
			return 
		end
		
		if !BeatWar.AlreadyLOADING then
			BeatWar.AlreadyLOADING = true
			LoadSound(BeatWar.LoadingMusic[1])
		end
		
	end

	net.Receive("PreloadSound",function()
		
		local id = net.ReadString()
		
		BeatWar.WaitingPlys = false
		BeatWar.IsLoading = true
		
		if !BeatWar.LoadInit then
			
			BeatWar.LoadPl = 0
			BeatWar.ClockTime = 0
			
			BeatWar.WinningTeam = nil
			BeatWar.ENDED = false
			
			BeatWar.PreparingMap = false
			BeatWar.LoadInit = true
			
		end
		
		if BeatWar.URLMusics[id] != nil then 
			print("Music " .. id .. " already loaded!")
			
			if id == BeatWar.MUSIC and !GetGlobalBool(4453) then
				local Time = BeatWar.URLMusics[id].Station:GetLength()
				
    			net.Start("SendMusicInfo")
    				net.WriteDouble(Time)
    			net.SendToServer()
    			
			end
			
			return 
		end
		
		local lodtb = {}
		lodtb.id = id
		lodtb.snd = net.ReadString()
		lodtb.loop = net.ReadBool() or false
		lodtb.vol = net.ReadDouble() or 1
		
		table.insert(BeatWar.LoadingMusic,lodtb)
		
	end)
	
	function LoadSound(dt)
		
		local id = dt.id
		local snd = dt.snd
		local loop = dt.loop
		local vol = dt.vol
		
		sound.PlayURL (snd, "noblock noplay", function( station )
    			if IsValid( station ) then
    				
    				if BeatWar.URLMusics[id] != nil then
    					if BeatWar.URLMusics[id].Station != nil then 
    						BeatWar.URLMusics[id].Station:Stop()
    					end
					else
						BeatWar.URLMusics[id] = {}
					end

    				BeatWar.URLMusics[id].Station = station
    				BeatWar.URLMusics[id].Loop = loop
    				BeatWar.URLMusics[id].Volume = vol
    				BeatWar.URLMusics[id].ID = id
    				
    				if id == BeatWar.MUSIC and !GetGlobalBool(4453) then // Find the music
    					local Time = BeatWar.URLMusics[id].Station:GetLength()
    					
    					net.Start("SendMusicInfo")
		    				net.WriteDouble(Time)
		    			net.SendToServer()
    				end
    				
    			    print("Music " .. id .. " loaded!")
    			else
    				print("Failed to load Music " .. id)
    			end

    			table.remove(BeatWar.LoadingMusic,1)
    			BeatWar.AlreadyLOADING = false
	    end)
	
	end
	
	function StopLoad()
		BeatWar.IsLoading = false
		
		if BeatWar.LoadMusic != nil then
			BeatWar.LoadMusic:Stop()	
		end
		
	end
	
	function SetSettings(id,loop,vol)
		if BeatWar.URLMusics[id] == nil or !BeatWar.URLMusics[id].Station:IsValid() then return end
		BeatWar.URLMusics[id].Loop = loop
		BeatWar.URLMusics[id].Volume = vol
	end
	
	function StopMusic(id)
	
		if BeatWar.URLMusics[id] == nil then 
			print("Music Not Found!")
			return 
		end
		
		local Station = BeatWar.URLMusics[id].Station
		
		if !Station:IsValid() then 
			print("Station not Found! Music could not be pre-loaded?")
			BeatWar.URLMusics[id] = nil
			return 
		end
		
		Station:Pause()
		Station:SetTime(0)
		
	end
	
	function PlayMusic(id,override)
	
		if BeatWar.URLMusics[id] == nil then 
			print("Music Not Found!")
			return 
		end
		
		local Station = BeatWar.URLMusics[id].Station
		
		if !Station:IsValid() then 
			print("Station not Found! Music could not be pre-loaded?")
			BeatWar.URLMusics[id] = nil
			return 
		end
		
		local Loop = BeatWar.URLMusics[id].Loop or false
		local Vol = BeatWar.URLMusics[id].Volume or 1
		
		if override and BeatWar.LastMusic != "" then
			StopMusic(BeatWar.LastMusic)	
		end
		
		Station:Play()
		Station:SetVolume(Vol)
		Station:EnableLooping(Loop)
		
		BeatWar.LastMusic = id
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
		
		if BeatWar.InIntro and Music == "stopintro" then
			BeatWar.InIntro = false
			return
		end
		
		PlayMusic(Music,Ovr)
		
		if Music == "announce_3" then
			BeatWar.Countdown = 3
		elseif Music == "announce_2" then
			BeatWar.Countdown = 2
		elseif Music == "announce_1" then
			BeatWar.Countdown = 1
		elseif Music == "announce_go" then
			BeatWar.Countdown = 0
			
			timer.Simple(1,function()
				BeatWar.Countdown = -1	
			end)
			
		end
		
		if !BeatWar.InIntro and Music == "beatintro" then
			
			BeatWar.InIntro = true
			BeatWar.IntroStage = 0
			
			timer.Simple(1,function()
				BeatWar.IntroStage = 1
				PlayMusic("announce_welcome",false)
			end)
			
			timer.Simple(2.5,function()
				BeatWar.IntroStage = 2
			end)
			
			timer.Simple(4.5,function()
				BeatWar.IntroStage = 3
			end)
			
			timer.Simple(6,function()
				BeatWar.IntroStage = 4
			end)
		end
		
		
	end)
	
	function HUDLoadDraw()
		
		if !IsValid(LocalPlayer()) then return end
		
		if BeatWar.PreparingMap then
			surface.SetDrawColor(Color(1,1,1))
			surface.DrawRect( 0, 0, ScrW(), ScrH() )
			
			draw.SimpleText("Preparing MAP","LoadFont",ScrW() / 2,ScrH() / 2 + math.cos(CurTime()*3)*10,Color(255,255,255),1,1)
		else
			if !BeatWar.InIntro then
				if !BeatWar.IsLoading then return end
				
				surface.SetDrawColor(Color(1,1,1))
				surface.DrawRect( 0, 0, ScrW(), ScrH() )
				
				if BeatWar.WaitingPlys then
					draw.SimpleText("Waiting for Players","LoadFont",ScrW() / 2,ScrH() / 2 + math.cos(CurTime()*3)*10,Color(255,255,255),1,1)
					if BeatWar.LoadPl < #BeatWar.Players then
						draw.SimpleText("(" .. BeatWar.LoadPl .. " / " .. #BeatWar.Players .. ")","LoadFont_small",ScrW() / 2,ScrH() / 2 + math.cos(CurTime()*2)*10 + 100,Color(255,255,255),1,1)
					else
						draw.SimpleText("Done :D!","LoadFont_small",ScrW() / 2,ScrH() / 2 + math.cos(CurTime()*2)*10 + 100,Color(255,255,255),1,1)
					end
				else
					draw.SimpleText("Loading Content","LoadFont",ScrW() / 2,ScrH() / 2 + math.cos(CurTime()*3)*10,Color(255,255,255),1,1)
					draw.SimpleText(#BeatWar.LoadingMusic .. " Remaining","LoadFont_small",ScrW() / 2,ScrH() / 2 + math.cos(CurTime()*2)*10 + 100,Color(255,255,255),1,1)
				end
				
				if BeatWar.HINT != "" then
					draw.SimpleText(BeatWar.HINT,"LoadFont_small",ScrW() / 2,30,Color(255,255,255),1,1)
				end
			else
			
				// TUTORIAL EHRE
				if BeatWar.IntroStage == 0 then
					draw.SimpleTextOutlined("WELCOME TO BEATWAR","LoadFont",ScrW() / 2,ScrH() / 2  ,Color(255,255,255),1,1,2,Color(1,1,1))
				elseif BeatWar.IntroStage == 1 then
					draw.SimpleTextOutlined("MOVE AT THE BEAT","LoadFont",ScrW() / 2,ScrH() / 2 - 100 ,Color(255,255,255),1,1,2,Color(1,1,1))
					draw.SimpleTextOutlined("TO WIN MULTIPLIER AND MOVE","LoadFont_small",ScrW() / 2,ScrH() / 2 + 50 ,Color(255,0,0),1,1,2,Color(1,1,1))
				elseif BeatWar.IntroStage == 2 then
					draw.SimpleTextOutlined("PRESS E TO USE ROCKET","LoadFont",ScrW() / 2,ScrH() / 2 - 100 ,Color(255,255,255),1,1,2,Color(1,1,1))
					draw.SimpleTextOutlined("ROCKETS TEMPORARILY STUN A PLAYER","LoadFont_small",ScrW() / 2,ScrH() / 2 + 50 ,Color(255,0,0),1,1,2,Color(1,1,1))		
				elseif BeatWar.IntroStage == 3 then
					draw.SimpleTextOutlined("TEAM WITH MOST POINTS WINS","LoadFont",ScrW() / 2,ScrH() / 2 ,Color(255,255,255),1,1,2,Color(1,1,1))
				elseif BeatWar.IntroStage == 4 then
					draw.SimpleTextOutlined("LET THE GAME BEGIN!","LoadFont",ScrW() / 2,ScrH() / 2 ,Color(255,255,255),1,1,2,Color(1,1,1))
				end
			end
		end
	end


		
	function DrawPoints()
		
		if BeatWar.IsLoading or BeatWar.InIntro or BeatWar.PreparingMap then return end
		if !LocalPlayer():GetNWBool("IsPlaying") then return end

		// BOTTOM PLY
		
		cam.Start3D2D( LocalPlayer():GetPos() + Vector(0,0,2), Angle(0,CurTime()*100,0), 1 )
			draw.TexturedQuad( BeatWar.PlyQuadSphere )	
		cam.End3D2D()
		
		if #BeatWar.PointView <= 0 then return end
		
		for k,v in pairs(BeatWar.PointView) do
			
			cam.Start3D2D( v.Pos + Vector(math.cos(v.Time)*30,0,0), Angle(v.Ang,-90,90), math.abs(math.cos(v.Time / 10)) )
				
				local CL = v.inColor
				CL.a = v.Alpha
				
				draw.SimpleTextOutlined(v.Msg,"LoadFont_small",0,0,CL,1,1,2,Color(1,1,1,v.Alpha))		
			cam.End3D2D()
			
			v.Pos.z = v.Pos.z + 1
			v.Alpha = v.Alpha - v.AliveTime
			
			v.Ang = math.cos(v.Time)*20
			v.Time = v.Time + 0.1
			
			if v.Alpha <= 0 then
				table.remove(BeatWar.PointView,k)
				continue
			end
		end
		
	end
	
	function HUDDraw()
		
		if !IsValid(LocalPlayer()) then return end
			
		if BeatWar.ENDED and BeatWar.WinningTeam != nil then
			
			local Nam = BeatWar.WinningTeam.Name
			local Cl = BeatWar.WinningTeam.TeamColor
			local Pt = BeatWar.WinningTeam.Points
			
			draw.SimpleTextOutlined("THE WINNING TEAM IS","LoadFont",ScrW() / 2,ScrH() / 2 - 100 ,Color(255,255,255),1,1,2,Color(1,1,1))
			draw.SimpleTextOutlined(Nam .. "! With " .. Pt .. " points!","LoadFont_small",ScrW() / 2,ScrH() / 2 + 30 ,Cl,1,1,2,Color(1,1,1))
				
			return
		end
			
		if !LocalPlayer():GetNWBool("IsPlaying") then return end
		
		if BeatWar.IsLoading or BeatWar.PreparingMap then return end
		
		if BeatWar.Countdown != -1 and BeatWar.Countdown != 4 then
			if BeatWar.Countdown != 0 then
				draw.SimpleText(BeatWar.Countdown,"NameTag_Blur",ScrW() / 2,50,Color(1,1,1),1,1)
				draw.SimpleText(BeatWar.Countdown,"NameTag",ScrW() / 2,50,Color(255,255,255),1,1)
			else
				draw.SimpleText("GO!","NameTag_Blur",ScrW() / 2,50,Color(1,1,1),1,1)
				draw.SimpleText("GO!","NameTag",ScrW() / 2,50,Color(255,255,255),1,1)
			end
		elseif !BeatWar.InIntro then
		    // SCOREBOARD
		    
			if #BeatWar.Points >= 4 then
				local OFFSET = 0
				
				// Orange
				draw.RoundedBox( 6, 10 + OFFSET, 10, 150, 50, Color(240,240,240) )
				draw.RoundedBox( 1, 15 + OFFSET, 15, 140, 40, Color(255,93,0) )
				
				draw.SimpleTextOutlined( "Orange", "Points_TL", 150/2 + 10 + OFFSET, 8, Color(255,255,255), 1,0,2,Color(255,93,0) )
				draw.SimpleTextOutlined( BeatWar.Points[1], "Points", 150/2 + 10 + OFFSET, 35, Color(255,255,255), 1,0,2,Color(255,93,0) )
				
				OFFSET = OFFSET + 200
				
				// Blue
				draw.RoundedBox( 6, 10 + OFFSET, 10, 150, 50, Color(240,240,240) )
				draw.RoundedBox( 1, 15 + OFFSET, 15, 140, 40, Color(0,161,255) )
				
				draw.SimpleTextOutlined( "Blue", "Points_TL", 150/2 + 10 + OFFSET, 8, Color(255,255,255), 1,0,2,Color(0,161,255) )
				draw.SimpleTextOutlined( BeatWar.Points[2], "Points", 150/2 + 10 + OFFSET, 35, Color(255,255,255), 1,0,2,Color(0,161,255) )
				
				OFFSET = OFFSET + 200
				
				// Green
				draw.RoundedBox( 6, 10 + OFFSET, 10, 150, 50, Color(240,240,240) )
				draw.RoundedBox( 1, 15 + OFFSET, 15, 140, 40, Color(127,225,0) )
				
				draw.SimpleTextOutlined( "Green", "Points_TL", 150/2 + 10 + OFFSET, 8, Color(255,255,255), 1,0,2,Color(127,225,0) )
				draw.SimpleTextOutlined( BeatWar.Points[3], "Points", 150/2 + 10 + OFFSET, 35, Color(255,255,255), 1,0,2,Color(127,225,0) )
				
				OFFSET = OFFSET + 200
				
				// Purple
				draw.RoundedBox( 6, 10 + OFFSET, 10, 150, 50, Color(240,240,240) )
				draw.RoundedBox( 1, 15 + OFFSET, 15, 140, 40, Color(227,0,170) )
				
				draw.SimpleTextOutlined( "Purple", "Points_TL", 150/2 + 10 + OFFSET, 8, Color(255,255,255), 1,0,2,Color(227,0,170) )
				draw.SimpleTextOutlined( BeatWar.Points[4], "Points", 150/2 + 10 + OFFSET, 35, Color(255,255,255), 1,0,2,Color(227,0,170) )
				
			end
			
			// CLOCK
				
			// MULT THING
			draw.SimpleTextOutlined("x"..LocalPlayer():GetNWBool("CoinMult"), "Points_MULT", ScrW() - 70 , ScrH() - 110, Color(255,93,0), 1,0,3,Color(30,30,30) )

			if #BeatWar.BeatView > 0 then
				for k,v in pairs(BeatWar.BeatView) do
					
					v.Alpha = v.Alpha - 10
					v.y = v.y + v.Yspeed
					
					draw.SimpleTextOutlined( "Beat", "Points_TL", ScrW() - 60 - v.x, ScrH() - 100 - v.y,
						Color(255,255,255,v.Alpha), 1,0,2,Color(30,30,30,v.Alpha) )
					
					if v.Alpha <= 0 then
						table.remove(BeatWar.BeatView,k)	
					end
				end
			end
			
		end
	end
	
	function GetRandomHint()
		BeatWar.HINT = BeatWar.HINTS[math.random(1,#BeatWar.HINTS)]	
	end
	
	net.Receive("ldFinished",function()
		local ply = net.ReadEntity()
		
		if !IsValid(ply) then return end
		
		if table.HasValue(BeatWar.LoadPlayers,ply) then
			table.RemoveByValue(BeatWar.LoadPlayers,ply)
			BeatWar.LoadPl = BeatWar.LoadPl + 1
		end
	end)

	net.Receive("StartClientside",function()
		StopLoad()
	end)
	
	net.Receive("AnnWin",function()
		BeatWar.WinningTeam = net.ReadTable()
		BeatWar.ENDED = true
	end)
	
	net.Receive("Voting",function()
		local stop = net.ReadBool()
		
		if stop then
			
			if BeatWar.VotingMusic != nil then
				BeatWar.VotingMusic:Stop()	
			end
			
		else
			sound.PlayURL("http://www.failcake.me/minigames/Beatwar/votetime.ogg", "", function( station )
				if IsValid(station) then
					
					BeatWar.VotingMusic = station
					
					station:Play()
					station:SetVolume(0.2)
					
				end
			end)
		end
		
	end)
	

	net.Receive("SendPoints",function(len,pl)
		
		local pos = net.ReadVector()
		local points = net.ReadString()
		local team = net.ReadDouble()
		local InColor = net.ReadVector()
		local aliv = net.ReadDouble()
		
		local COLOR = Color(InColor.x,InColor.y,InColor.z)
		
		local TBL = {
			Alpha = 255,
			Pos = pos,
			Msg = points,
			Speed = math.random(1,4),
			Time = 0,
			Ang = 0,
			inColor = COLOR,
			AliveTime = aliv
		}
		
		if team != -1 then
			BeatWar.Points[team] = BeatWar.Points[team] + points
		end
	
		table.insert(BeatWar.PointView,TBL)
	end)
	
	
    
	net.Receive("AnnouncePlayer",function(len,pl) 
        
        local announc = net.ReadString()
        local Scarysound = net.ReadString()
        
        if Scarysound != "" then
            surface.PlaySound(Scarysound)
        end
        
        chat.AddText(Color(255,0,0),"[BeatWar] ",Color(255,255,255),announc)
        
    end)

	net.Receive("SelectMusic",function(len,pl)
		
		local TBL = net.ReadTable()
		BeatWar.MoveBEAT = TBL.Beat
		BeatWar.MUSIC = TBL.Music
		
	end)
end
