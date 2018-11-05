if myHero.charName ~= "Ekko" then return end
require("DamageLib")
Latency = Game.Latency
	local ignite
	local ignitekey
    local Ekko = myHero
    local ping = Game.Latency()/1000
    local usespell = Game.CanUseSpell
    local minioncount = Game.MinionCount
    local minion = Game.Minion
    local Q = {range = 950, speed = 1650, width = 50, delay = 0.25}
    local visionTick = GetTickCount()
    local LocalCallbackAdd = Callback.Add
    local _EnemyHeroes
    local _OnVision = {}
    local TotalHeroes = 0
    local TEAM_ALLY = Ekko.team
    local TEAM_ENEMY = 300 - TEAM_ALLY
    local myCounter = 1
local DamageReductionTable = {
        ['Braum'] = {
            buff = 'BraumShieldRaise',
            amount = function(target)
                return 1 - ({0.3, 0.325, 0.35, 0.375, 0.4})[target:GetSpellData(_E).level]
            end
        },
        ['Urgot'] = {
            buff = 'urgotswapdef',
            amount = function(target)
                return 1 - ({0.3, 0.4, 0.5})[target:GetSpellData(_R).level]
            end
        },
        ['Alistar'] = {
            buff = 'Ferocious Howl',
            amount = function(target)
                return ({0.5, 0.4, 0.3})[target:GetSpellData(_R).level]
            end
        },
        ['Amumu'] = {
            buff = 'Tantrum',
            amount = function(target)
                return ({2, 4, 6, 8, 10})[target:GetSpellData(_E).level]
            end,
            damageType = 1
        },
        ['Galio'] = {
            buff = 'GalioIdolOfDurand',
            amount = function(target)
                return 0.5
            end
        },
        ['Garen'] = {
            buff = 'GarenW',
            amount = function(target)
                return 0.7
            end
        },
        ['Gragas'] = {
            buff = 'GragasWSelf',
            amount = function(target)
                return ({0.1, 0.12, 0.14, 0.16, 0.18})[target:GetSpellData(_W).level]
            end
        },
        ['Annie'] = {
            buff = 'MoltenShield',
            amount = function(target)
                return 1 - ({0.16, 0.22, 0.28, 0.34, 0.4})[target:GetSpellData(_E).level]
            end
        },
        ['Malzahar'] = {
            buff = 'malzaharpassiveshield',
            amount = function(target)
                return 0.1
            end
        }
    }
 local
		findEmemy,
		ClearJungle,
		HarassMode,
		ClearMode,
        validTarget,
        ValidTargetM,
		GetDistanceSqr,
        GetDistance,
        DamageReductionMod,
        OnVision,
        OnVisionF,
        CalcMagicalDamage,
        CalcPhysicalDamage,
        GetTarget,
        Priority,
		PassivePercentMod,
        GetItemSlot,
        Angle,
		flux, flux_Menu
  local sqrt = math.sqrt
	GetDistanceSqr = function(p1, p2)
		p2 = p2 or Zoe
		p1 = p1.pos or p1
		p2 = p2.pos or p2
		
	
		local dx, dz = p1.x - p2.x, p1.z - p2.z 
		return dx * dx + dz * dz
	end

	GetDistance = function(p1, p2)
		
		return sqrt(GetDistanceSqr(p1, p2))
    end
    


    


    GetEnemyHeroes = function()
        _EnemyHeroes = {}
        for i = 1, Game.HeroCount() do
            local unit = Game.Hero(i)
            if unit.team == TEAM_ENEMY or unit.isEnemy then
                _EnemyHeroes[myCounter] = unit
                myCounter = myCounter + 1
            end
        end
        myCounter = 1
        return #_EnemyHeroes
    end
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
        CastSpell = function(spell,pos,range,delay)
        
            local range = range or math.huge
            local delay = delay or 250
            local ticker = GetTickCount()
        
            if castSpell.state == 0 and GetDistance(Ekko.pos, pos) < range and ticker - castSpell.casting > delay + Latency() then
                castSpell.state = 1
                castSpell.mouse = mousePos
                castSpell.tick = ticker
            end
            if castSpell.state == 1 then
                if ticker - castSpell.tick < Latency() then
                    Control.SetCursorPos(pos)
                    Control.KeyDown(spell)
                    Control.KeyUp(spell)
                    castSpell.casting = ticker + delay
                    DelayAction(function()
                        if castSpell.state == 1 then
                            Control.SetCursorPos(castSpell.mouse)
                            castSpell.state = 0
                        end
                    end,Latency()/1000)
                end
                if ticker - castSpell.casting > Latency() then
                    Control.SetCursorPos(castSpell.mouse)
                    castSpell.state = 0
                end
            end
        end
LocalCallbackAdd(
    'Load',
	function()
        flux_Menu()
        TotalHeroes = GetEnemyHeroes()
        GetIgnite()
        

		if _G.EOWLoaded then
			SagaOrb = 1
		elseif _G.SDK and _G.SDK.Orbwalker then
			SagaOrb = 2
		elseif _G.GOS then
			SagaOrb = 3
		elseif _G.gsoSDK then
			SagaOrb = 4
		end
		
		if  SagaOrb == 1 then
		   local mode = EOW:Mode()
		
		   Sagacombo = mode == 1
		   Sagaharass = mode == 2
		   SagalastHit = mode == 3
		   SagalaneClear = mode == 4
		   SagajungleClear = mode == 4
		
		   Sagacanmove = EOW:CanMove()
		   Sagacanattack = EOW:CanAttack()
		elseif  SagaOrb == 2 then
			SagaSDK = SDK.Orbwalker
			SagaSDKCombo = SDK.ORBWALKER_MODE_COMBO
			SagaSDKHarass = SDK.ORBWALKER_MODE_HARASS
			SagaSDKJungleClear = SDK.ORBWALKER_MODE_JUNGLECLEAR
			SagaSDKJungleClear = SDK.ORBWALKER_MODE_JUNGLECLEAR
			SagaSDKLaneClear = SDK.ORBWALKER_MODE_LANECLEAR
			SagaSDKLastHit = SDK.ORBWALKER_MODE_LASTHIT
			SagaSDKFlee = SDK.ORBWALKER_MODE_FLEE
			SagaSDKSelector = SDK.TargetSelector
			SagaSDKMagicDamage = _G.SDK.DAMAGE_TYPE_MAGICAL
			SagaSDKPhysicalDamage = _G.SDK.DAMAGE_TYPE_PHYSICAL
		elseif  SagaOrb == 3 then
		   
		end
    end
)
GetIgnite = function()
    if myHero:GetSpellData(SUMMONER_2).name:lower() == "summonerdot" then
        igniteslot = 5
        ignitecast = HK_SUMMONER_2

    elseif myHero:GetSpellData(SUMMONER_1).name:lower() == "summonerdot" then
        igniteslot = 4
        ignitecast = HK_SUMMONER_1
    else
        ignitekey = nil
        ignite = nil
    end
    
end
LocalCallbackAdd(
    'Tick',
	function()
		
        if Game.Timer() > Saga.Rate.champion:Value() and #_EnemyHeroes == 0 then
            TotalHeroes = GetEnemyHeroes()
        end
		if #_EnemyHeroes == 0 then return end
		if myHero.dead or Game.IsChatOpen() == true  or isEvading then return end
		OnVisionF()
		if GetOrbMode() == 'Combo' then
			Combo()
			
		end
	
		if GetOrbMode() == 'Harass' then
			Harass()
		end
	
		if GetOrbMode() == 'Clear' then
			LaneClear()
		end

		if GetOrbMode() == 'Lasthit' then
			LastHit()
		end
	
		if GetOrbMode() == 'Flee' then
			Flee()
		end
		end)
		GetOrbMode = function()
			if SagaOrb == 1 then
				if Sagacombo == 1 then
					return 'Combo'
				elseif Sagaharass == 2 then
					return 'Harass'
				elseif SagalastHit == 3 then
					return 'Lasthit'
				elseif SagalaneClear == 4 then
					return 'Clear'
				end
			elseif SagaOrb == 2 then
				SagaSDKModes = SDK.Orbwalker.Modes
				if SagaSDKModes[SagaSDKCombo] then
					return 'Combo'
				elseif SagaSDKModes[SagaSDKHarass] then
					return 'Harass'
				elseif SagaSDKModes[SagaSDKLaneClear] or SagaSDKModes[SagaSDKJungleClear] then
					return 'Clear'
				elseif SagaSDKModes[SagaSDKLastHit] then
					return 'Lasthit'
				elseif SagaSDKModes[SagaSDKFlee] then
					return 'Flee'
				end
			elseif SagaOrb == 3 then
				return GOS:GetMode()
			elseif SagaOrb == 4 then
				 return _G.gsoSDK.Orbwalker:GetMode()
			end
		 end
		
CastQ = function(target)
	if Game.CanUseSpell(0) == 0 and castSpell.state == 0 then
        if target.pos:DistanceTo() < Q.range and (Game.Timer() - OnWaypoint(target).time < 0.15 or Game.Timer() - OnWaypoint(target).time > 1.0) then
            local qPred = GetPred(target,Q.speed,Q.delay + Game.Latency()/1000)
            CastSpell(HK_Q,qPred,Q.range + 200,250)
        end
	end
end
