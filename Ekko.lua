if myHero.charName ~= "Ekko" then return end

require "PremiumPrediction"
require "MapPosition"
  local Ekko = myHero
	local Latency = Game.Latency
    local ping = Game.Latency()/1000
	local Ready = Game.CanUseSpell
    local ObjectCount = Game.ObjectCount
    local Object = Game.Object
    local clock = os.clock
    local Timer = Game.Timer
    local LocalCallbackAdd = Callback.Add
    local IDList = {}
    local _EnemyHeroes
    local _OnVision = {}
    local TotalHeroes
    local TEAM_ALLY = myHero.team
    local TEAM_ENEMY = 300 - TEAM_ALLY
    local bitchList = {"Annie", "Malzahar", "Zyra", "Ivern", "Kalista", "Yorick", "Heimerdinger"}
    local myCounter = 1
    local Tard_RangeCount = 0 -- <3 yaddle
    local hpredTick = 0
    local wCounter = 0
    local _movementHistory = {}
	local ignite
	local igniteSlot
	local Cast = Control.CastSpell
	local DrawCircle = Draw.Circle
	local DrawColor = Draw.Color
	local DrawLine = Draw.Line
	local DrawText = Draw.Text
	local IsKeyDown = Control.IsKeyDown
	local KeyUp = Control.KeyUp
	local KeyDown = Control.KeyDown
	local Mouse = Control.mouse_event
	local Move = Control.Move
	local SetCursorPos = Control.SetCursorPos
	local HeroCount = Game.HeroCount
	local Hero = Game.Hero
	local MinionCount = Game.MinionCount
	local Minion = Game.Minion
	local MissileCount = Game.MissileCount
	local Missile = Game.Missile
	local Vector = Vector
	local visionTick = GetTickCount()
	--
	local SDK = _G.SDK
    local ObjectManager = SDK.ObjectManager
    local TargetSelector = SDK.TargetSelector
    local HealthPrediction = SDK.HealthPrediction
	--
	local floor = math.floor
	local max = math.max	
	local huge = math.huge
    local pi = math.pi
    local atan2 = math.atan2
    local min = math.min
	local ceil = math.ceil
	local sqrt = math.sqrt
	
	
	local Q = {Range = 950, 
				Width = 50,
				Delay = 0.25 + ping,
				Speed = 1650,
				Collision = false,
				Type = line,
				Radius = 60, 
				From = Ekko}
    local W = {Range = 1600, 
				Delay = 3.75, 
				Speed = 1650, 
				Radius = 375, 
				Type = circular, 
				From = Ekko}   
	local E = {Range = 600,
				Delay = 0.25, 
				Speed = 2500,
				Radius = 100, 
				Type = line, 
				From = Ekko}
	local R = {Range = 1600, 
				Delay = 0.25, 
				Speed = 1650, 
				Radius = 375}
	local Qdamage = {100,135,180,220,260}
	
	local
		GetEnemyHeroes,
		findEmemy,
		ClearJungle,
		HarassMode,
		ClearMode,
		validTarget,
		ValidTargetM,
		GetDistanceSqr,
		GetDistance,
		GetDistance2D,
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
		GetPred,
		Orb,
		Flux
		
	local 
		Orbwalker = SDK.Orbwalker
			SDKCombo = SDK.ORBWALKER_MODE_COMBO
			SDKHarass = SDK.ORBWALKER_MODE_HARASS
			SDKJungleClear = SDK.ORBWALKER_MODE_JUNGLECLEAR
			SDKJungleClear = SDK.ORBWALKER_MODE_JUNGLECLEAR
			SDKLaneClear = SDK.ORBWALKER_MODE_LANECLEAR
			SDKLastHit = SDK.ORBWALKER_MODE_LASTHIT
			SDKFlee = SDK.ORBWALKER_MODE_FLEE
			SDKSelector = SDK.TargetSelector
			SDKMagicDamage = _G.SDK.DAMAGE_TYPE_MAGICAL
			SDKPhysicalDamage = _G.SDK.DAMAGE_TYPE_PHYSICAL
		
--------------------------------------------------------------------------------------------------------------------------------		
--------------------------------------------------------------------------------------------------------------------------------	
----------------------------------------------------------------Functions-------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
    --WR PREDICTION USAGE ---
	
    local _STUN = 5
    local _TAUNT = 8    
    local _SLOW = 10    
    local _SNARE = 11
    local _CHARM = 22
    local _SUPRESS = 24        
    local _AIRBORNE = 30
    local _SLEEP = 18
	
    ---WR PREDICTION USAGE ----- 
---PremiumPrediction---
function OnDraw()
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		if unit.isEnemy and unit.visible then
			local CastPos, HitChance, TimeToHit = PremiumPrediction:GetPrediction(myHero, unit, 2000, 1150, 0.25, 60, 0, true)
			if CastPos then
				Draw.Circle(Vector(CastPos), 100, 1, Draw.Color(192,255,255,255))
			end
		end
	end
end


	
---------Functions-------------------------------------------------------     
		
local sqrt = math.sqrt
   local GetDistanceSqr = function(p1, p2)
	p2 = p2 or Ekko
	p1 = p1.pos or p1
	p2 = p2.pos or p2	
	local dx, dz = p1.x - p2.x, p1.z - p2.z 
	return dx * dx + dz * dz
end

local GetDistance = function(p1, p2)		
	return sqrt(GetDistanceSqr(p1, p2))
end
    
      
GetTarget = function(range)

		if Orb == 1 then
			if myHero.ap > myHero.totalDamage then
				return TargetSelector:GetTarget(range, SDKMagicDamage)
			else
				return TargetSelector:GetTarget(range, SDKPhysicalDamage)
			end
		elseif _G.GOS then
			if myHero.ap > myHero.totalDamage then
				return GOS:GetTarget(range, "AP")
			else
				return GOS:GetTarget(range, "AD")
			end
		elseif _G.gsoSDK then
			return _G.gsoSDK.TS:GetTarget()
		end
	end

local IsImmobileTarget = function(unit)
	for i = 0, unit.buffCount do
	local buff = unit:GetBuff(i)
	if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == "recall") and buff.count > 0 then
	return true
end
end
	return false	
end
	  
	local GetDistance2D = function(p1,p2)
    return sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
end

local _OnWaypoint = {}
function OnWaypoint(unit)
	if _OnWaypoint[unit.networkID] == nil then _OnWaypoint[unit.networkID] = {pos = unit.posTo , speed = unit.ms, time = Game.Timer()} end
	if _OnWaypoint[unit.networkID].pos ~= unit.posTo then 
		-- print("OnWayPoint:"..unit.charName.." | "..math.floor(Game.Timer()))
		_OnWaypoint[unit.networkID] = {startPos = unit.pos, pos = unit.posTo , speed = unit.ms, time = Game.Timer()}
			DelayAction(function()
				local time = (Game.Timer() - _OnWaypoint[unit.networkID].time)
				local speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
				if speed > 1250 and time > 0 and unit.posTo == _OnWaypoint[unit.networkID].pos and GetDistance(unit.pos,_OnWaypoint[unit.networkID].pos) > 200 then
					_OnWaypoint[unit.networkID].speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
					-- print("OnDash: "..unit.charName)
				end
			end,0.05)
	end
	return _OnWaypoint[unit.networkID]
end
	  
local GetPred = function(unit,speed,delay,sourcePosA)
	local speed = speed or huge
	local delay = delay or 0.25
	local sourcePos = sourcePosA or Ekko.pos
	local unitSpeed = unit.ms
	if OnWaypoint(unit).speed > unitSpeed then unitSpeed = OnWaypoint(unit).speed end
	if OnVision(unit).state == false then
	local unitPos = unit.pos + Vector(unit.pos,unit.posTo):Normalized() * ((GetTickCount() - OnVision(unit).tick)/1000 * unitSpeed)
	local predPos = unitPos + Vector(unit.pos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(sourcePos,unitPos)/speed)))
	if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
	return predPos
	else
	if unitSpeed > unit.ms then
	local predPos = unit.pos + Vector(OnWaypoint(unit).startPos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(sourcePos,unit.pos)/speed)))
	if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
	return predPos
	elseif IsImmobileTarget(unit) then
	return unit.pos
	else
	return unit:GetPrediction(speed,delay)
end
end
end
	  
	 
	 
local DamageReductionTable = {
    ['Braum'] = {
    buff = 'BraumShieldRaise',
    amount = function(target)
    return 1 - ({0.3, 0.325, 0.35, 0.375, 0.4})[target:GetSpellData(_E).level]
end},
    ['Urgot'] = {
    buff = 'urgotswapdef',
    amount = function(target)
    return 1 - ({0.3, 0.4, 0.5})[target:GetSpellData(_R).level]
end},
    ['Alistar'] = {
    buff = 'Ferocious Howl',
    amount = function(target)
    return ({0.5, 0.4, 0.3})[target:GetSpellData(_R).level]
end},
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
end},
    ['Garen'] = {
    buff = 'GarenW',
    amount = function(target)
    return 0.7
end},
    ['Gragas'] = {
    buff = 'GragasWSelf',
    amount = function(target)
    return ({0.1, 0.12, 0.14, 0.16, 0.18})[target:GetSpellData(_W).level]
end},
    ['Annie'] = {
    buff = 'MoltenShield',
    amount = function(target)
    return 1 - ({0.16, 0.22, 0.28, 0.34, 0.4})[target:GetSpellData(_E).level]
end},
    ['Malzahar'] = {
    buff = 'malzaharpassiveshield',
    amount = function(target)
    return 0.1
end}}

Priority = function(charName)
    local p1 = {"Alistar", "Amumu", "Blitzcrank", "Braum", "Cho'Gath", "Dr. Mundo", "Garen", "Gnar", "Maokai", "Hecarim", "Jarvan IV", "Leona", "Lulu", "Malphite", "Nasus", "Nautilus", "Nunu", "Olaf", "Rammus", "Renekton", "Sejuani", "Shen", "Shyvana", "Singed", "Sion", "Skarner", "Taric", "TahmKench", "Thresh", "Volibear", "Warwick", "MonkeyKing", "Yorick", "Zac", "Poppy", "Ornn"}
    local p2 = {"Aatrox", "Darius", "Elise", "Evelynn", "Galio", "Gragas", "Irelia", "Jax", "Lee Sin", "Morgana", "Janna", "Nocturne", "Pantheon", "Rengar", "Rumble", "Swain", "Trundle", "Tryndamere", "Udyr", "Urgot", "Vi", "XinZhao", "RekSai", "Bard", "Nami", "Sona", "Camille", "Kled", "Ivern", "Illaoi"}
    local p3 = {"Akali", "Diana", "Ekko", "FiddleSticks", "Fiora", "Gangplank", "Fizz", "Heimerdinger", "Jayce", "Kassadin", "Kayle", "Kha'Zix", "Lissandra", "Mordekaiser", "Nidalee", "Riven", "Shaco", "Vladimir", "Yasuo", "Zilean", "Zyra", "Ryze", "Kayn", "Rakan", "Pyke"}
    local p4 = {"Ahri", "Anivia", "Annie", "Ashe", "Azir", "Brand", "Caitlyn", "Cassiopeia", "Corki", "Draven", "Ezreal", "Graves", "Jinx", "Kalista", "Karma", "Karthus", "Katarina", "Kennen", "KogMaw", "Kindred", "Leblanc", "Lucian", "Lux", "Malzahar", "MasterYi", "MissFortune", "Orianna", "Quinn", "Sivir", "Syndra", "Talon", "Teemo", "Tristana", "TwistedFate", "Twitch", "Varus", "Vayne", "Veigar", "Velkoz", "Viktor", "Xerath", "Zed", "Ziggs", "Jhin", "Soraka", "Zoe", "Xayah","Kaisa", "Taliyah", "AurelionSol"}
    if table.contains(p1, charName) then return 1 end
    if table.contains(p2, charName) then return 1.25 end
    if table.contains(p3, charName) then return 1.75 end
    return table.contains(p4, charName) and 2.25 or 1
end

 GetEnemyHeroes = function()
    _EnemyHeroes = {}
    for i = 1, HeroCount() do
    local unit = Hero(i)
    if unit.team == TEAM_ENEMY or unit.isEnemy then
    _EnemyHeroes[myCounter] = unit
    myCounter = myCounter + 1
end
end
    myCounter = 1
    return #_EnemyHeroes
end

local findEnemy = function(range)
    local target
    for i=1, HeroCount() do
    local unit = Hero(i)
    if unit and unit.isEnemy and unit.valid and unit.distance <= range and unit.isTargetable and not unit.dead and not unit.isImmortal and not (GotBuff(unit, 'FioraW') == 1) and
    not (GotBuff(unit, 'XinZhaoRRangedImmunity') == 1 and unit.distance <= 450) and unit.visible then
    local target = unit
end
end
    return target
end

CalcPhysicalDamage = function(source, target, amount)
    local ArmorPenPercent = source.armorPenPercent
    local ArmorPenFlat = (0.4 + target.levelData.lvl / 30) * source.armorPen
    local BonusArmorPen = source.bonusArmorPenPercent
      
    if source.type == Obj_AI_Minion then
    ArmorPenPercent = 1
    ArmorPenFlat = 0
    BonusArmorPen = 1
    elseif source.type == Obj_AI_Turret then
    ArmorPenFlat = 0
    BonusArmorPen = 1
    if source.charName:find("3") or source.charName:find("4") then
    ArmorPenPercent = 0.25
    else
    ArmorPenPercent = 0.7
end
end
      
    if source.type == Obj_AI_Turret then
    if target.type == Obj_AI_Minion then
    amount = amount * 1.25
    if string.ends(target.charName, "MinionSiege") then
    amount = amount * 0.7
end
    return amount
end
end
      
    local armor = target.armor
    local bonusArmor = target.bonusArmor
    local value = 100 / (100 + (armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - ArmorPenFlat)
      
    if armor < 0 then
    value = 2 - 100 / (100 - armor)
    elseif (armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - ArmorPenFlat < 0 then
    value = 1
end
    return max(0, floor(DamageReductionMod(source, target, PassivePercentMod(source, target, value) * amount, 1)))
end

    CalcMagicalDamage = function(source, target, amount)
    local mr = target.magicResist
    local value = 100 / (100 + (mr * source.magicPenPercent) - source.magicPen)
    if mr < 0 then
    value = 2 - 100 / (100 - mr)
    elseif (mr * source.magicPenPercent) - source.magicPen < 0 then
    value = 1
end
    return max(0, floor(DamageReductionMod(source, target, PassivePercentMod(source, target, value) * amount, 2)))
end
    
DamageReductionMod = function(source,target,amount,DamageType)
    if source.type == Obj_AI_Hero then
    if GotBuff(source, "Exhaust") > 0 then
    amount = amount * 0.6
end
end
    if target.type == Obj_AI_Hero then
    for i = 0, target.buffCount do
    if target:GetBuff(i).count > 0 then
    local buff = target:GetBuff(i)
    if buff.name == "MasteryWardenOfTheDawn" then
    amount = amount * (1 - (0.06 * buff.count))
    end
    if DamageReductionTable[target.charName] then
    if buff.name == DamageReductionTable[target.charName].buff and (not DamageReductionTable[target.charName].damagetype or DamageReductionTable[target.charName].damagetype == DamageType) then
    amount = amount * DamageReductionTable[target.charName].amount(target)
end
end
    if target.charName == "Maokai" and source.type ~= Obj_AI_Turret then
    if buff.name == "MaokaiDrainDefense" then
    amount = amount * 0.8
end
end
    if target.charName == "MasterYi" then
    if buff.name == "Meditate" then
    amount = amount - amount * ({0.5, 0.55, 0.6, 0.65, 0.7})[target:GetSpellData(_W).level] / (source.type == Obj_AI_Turret and 2 or 1)
end
end
end
end
    if target.charName == "Kassadin" and DamageType == 2 then
    amount = amount * 0.85
end
end
    return amount
end
    
PassivePercentMod = function(source, target, amount, damageType)
    local SiegeMinionList = {"Red_Minion_MechCannon", "Blue_Minion_MechCannon"}
    local NormalMinionList = {"Red_Minion_Wizard", "Blue_Minion_Wizard", "Red_Minion_Basic", "Blue_Minion_Basic"}
    if source.type == Obj_AI_Turret then
    if table.contains(SiegeMinionList, target.charName) then
    amount = amount * 0.7
    elseif table.contains(NormalMinionList, target.charName) then
    amount = amount * 1.14285714285714
end
end
    if source.type == Obj_AI_Hero then 
    if target.type == Obj_AI_Hero then
    if (GetItemSlot(source, 3036) > 0 or GetItemSlot(source, 3034) > 0) and source.maxHealth < target.maxHealth and damageType == 1 then
    amount = amount * (1 + mathmin(target.maxHealth - source.maxHealth, 500) / 50 * (GetItemSlot(source, 3036) > 0 and 0.015 or 0.01))
end
end
end
    return amount
end
       
    GetItemSlot = function(unit, id)
    for i = ITEM_1, ITEM_7 do
    if unit:GetItemData(i).itemID == id then
    return i
end
end
    return 0
end

 castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
    CastSpell = function(spell,pos,range,delay)
    local range = range or huge
    local delay = delay or 250
    local ticker = GetTickCount()  
	local pos = pos or myHero.pos	
    if castSpell.state == 0 and GetDistance(myHero.pos, pos) < range and ticker - castSpell.casting > delay + Latency() then
    castSpell.state = 1
    castSpell.mouse = mousePos
    castSpell.tick = ticker
end
    if castSpell.state == 1 then
    if ticker - castSpell.tick < Latency() then
    SetCursorPos(pos)
    KeyDown(spell)
    KeyUp(spell)
    castSpell.casting = ticker + delay
    DelayAction(function()
    if castSpell.state == 1 then
    SetCursorPos(castSpell.mouse)
    castSpell.state = 0
end
end,Latency()/1000)
end
    if ticker - castSpell.casting > Latency() then
    SetCursorPos(castSpell.mouse)
    castSpell.state = 0
end
end
end
		

CastSpellMM = function(spell, pos, range, delay)
	local range = range or huge
	local delay = delay or 250
	local ticker = GetTickCount()
	if castSpell.state == 0 and GetDistance(Ekko.pos, pos) < range and ticker - castSpell.casting > delay + a() then
	castSpell.state = 1
	castSpell.mouse = mousePos
	castSpell.tick = ticker
	end
	if castSpell.state == 1 then
	if ticker - castSpell.tick < Latency() then
	local castPosMM = pos:ToMM()
	SetCursorPos(castPosMM.x,castPosMM.y)
	KeyDown(spell)
	KeyUp(spell)
	castSpell.casting = ticker + delay
	DelayAction(function()
	if castSpell.state == 1 then
	SetCursorPos(castSpell.mouse)
	castSpell.state = 0
end
end,Latency()/1000)
end
	if ticker - castSpell.casting > Latency() then
	SetCursorPos(castSpell.mouse)
	castSpell.state = 0
end
end
end

OnVision = function(unit)
    _OnVision[unit.networkID] = _OnVision[unit.networkID] == nil and {state = unit.visible, tick = GetTickCount(), pos = unit.pos} or _OnVision[unit.networkID]
    if _OnVision[unit.networkID].state == true and not unit.visible then
    _OnVision[unit.networkID].state = false
    _OnVision[unit.networkID].tick = GetTickCount()
end
    if _OnVision[unit.networkID].state == false and unit.visible then
    _OnVision[unit.networkID].state = true
    _OnVision[unit.networkID].tick = GetTickCount()
end
    return _OnVision[unit.networkID]
end
        
OnVisionF = function()
    if GetTickCount() - visionTick > 100 then
    for i = 1, TotalHeroes do
    OnVision(_EnemyHeroes[i])
end
    visionTick = GetTickCount()
end
end

findMinion = function()
    for i = 1, MinionCount() do
    local minion = Minion(i)
    if i > 1000 then return end
    if minion and minion.pos:DistanceTo() <= W.Range and minion.isTargetable and minion.isEnemy and not minion.dead and minion.visible then
    return minion, minion.pos
end
end
end

validTarget = function(unit)
        if unit and unit.isEnemy and unit.valid and unit.isTargetable and not unit.dead and not unit.isImmortal and not (GotBuff(unit, 'FioraW') == 1) and
        not (GotBuff(unit, 'XinZhaoRRangedImmunity') == 1 and unit.distance <= 450) and unit.visible then
            return true
        else 
            return false
        end
    end    

VectorPointProjectionOnLineSegment = function(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
	local pointLine = { x = ax + rL * (bx - ax), z = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or {x = ax + rS * (bx - ax), z = ay + rS * (by - ay)}
	return pointSegment, pointLine, isOnSegment
end 



local VectorMovementCollision = function (startPoint1, endPoint1, v1, startPoint2, v2, delay)
	local sP1x, sP1y, eP1x, eP1y, sP2x, sP2y = startPoint1.x, startPoint1.z, endPoint1.x, endPoint1.z, startPoint2.x, startPoint2.z
	local d, e = eP1x-sP1x, eP1y-sP1y
	local dist, t1, t2 = sqrt(d*d+e*e), nil, nil
	local S, K = dist~=0 and v1*d/dist or 0, dist~=0 and v1*e/dist or 0
	local function GetCollisionPoint(t) return t and {x = sP1x+S*t, y = sP1y+K*t} or nil end
	if delay and delay~=0 then sP1x, sP1y = sP1x+S*delay, sP1y+K*delay end
	local r, j = sP2x-sP1x, sP2y-sP1y
	local c = r*r+j*j
	if dist>0 then
	if v1 == huge then
	local t = dist/v1
	t1 = v2*t>=0 and t or nil
	elseif v2 == huge then
	t1 = 0
	else
	local a, b = S*S+K*K-v2*v2, -r*S-j*K
	if a==0 then
	if b==0 then --c=0->t variable
	t1 = c==0 and 0 or nil
	else --2*b*t+c=0
	local t = -c/(2*b)
	t1 = v2*t>=0 and t or nil
end
	else --a*t*t+2*b*t+c=0
	local sqr = b*b-a*c
	if sqr>=0 then
	local nom = sqrt(sqr)
	local t = (-nom-b)/a
	t1 = v2*t>=0 and t or nil
	t = (nom-b)/a
	t2 = v2*t>=0 and t or nil
end
end
end
	elseif dist==0 then
	t1 = 0
end
	return t1, GetCollisionPoint(t1), t2, GetCollisionPoint(t2), dist
end

local IsDashing = function(unit, spell)
	local delay, radius, speed, from = spell.Delay, spell.Radius, spell.Speed, spell.From.pos
	local OnDash, CanHit, Pos = false, false, nil
	local pathData = unit.pathing
	--
	if pathData.isDashing then
	local startPos = Vector(pathData.startPos)
	local endPos = Vector(pathData.endPos)
	local dashSpeed = pathData.dashSpeed
	local timer = Timer()
	local startT = timer - Latency()/2000
	local dashDist = GetDistance(startPos, endPos)
	local endT = startT + (dashDist/dashSpeed)
		--
	if endT >= timer and startPos and endPos then
	OnDash = true
			--
	local t1, p1, t2, p2, dist = VectorMovementCollision(startPos, endPos, dashSpeed, from, speed, (timer - startT) + delay)
	t1, t2 = (t1 and 0 <= t1 and t1 <= (endT - timer - delay)) and t1 or nil, (t2 and 0 <= t2 and t2 <=  (endT - timer - delay)) and t2 or nil
	local t = t1 and t2 and mathmin(t1, t2) or t1 or t2
			--
	if t then
	Pos = t == t1 and Vector(p1.x, 0, p1.y) or Vector(p2.x, 0, p2.y)
	CanHit = true
	else
	Pos = Vector(endPos.x, 0, endPos.z)
	CanHit = (unit.ms * (delay + GetDistance(from, Pos)/speed - (endT - timer))) < radius
end
end
end

	return OnDash, CanHit, Pos
end

local IsImmobile = function(unit, spell)
	if unit.ms == 0 then return true, unit.pos, unit.pos end
	local delay, radius, speed, from = spell.Delay, spell.Radius, spell.Speed, spell.From.pos
	local debuff = {}
	for i = 1, unit.buffCount do
	local buff = unit:GetBuff(i)
	if buff.duration > 0 then
	local ExtraDelay = speed == huge and 0 or (GetDistance(from, unit.pos) / speed)
	if buff.expireTime + (radius / unit.ms) > Timer() + delay + ExtraDelay then
	debuff[buff.type] = true
end
end
end
	if debuff[_STUN] or debuff[_TAUNT] or debuff[_SNARE] or debuff[_SLEEP] or
	debuff[_CHARM] or debuff[_SUPRESS] or debuff[_AIRBORNE] then
	return true, unit.pos, unit.pos
end
	return false, unit.pos, unit.pos
end

local IsSlowed = function(unit, spell)
	local delay, speed, from = spell.Delay, spell.Speed, spell.From.pos
	for i = 1, unit.buffCount do
	local buff = unit:GetBuff(i)
	if buff.type == _SLOW and buff.expireTime >= Timer() and buff.duration > 0 then
	if buff.expireTime > Timer() + delay + GetDistance(unit.pos, from) / speed then
	return true
end
end
end
	return false
end

CalculateTargetPosition = function(unit, spell, tempPos)
	local delay, radius, speed, from = spell.Delay, spell.Radius, spell.Speed, spell.From
	local calcPos = nil
	local pathData = unit.pathing
	local pathCount = pathData.pathCount
	local pathIndex = pathData.pathIndex
	local pathEndPos = Vector(pathData.endPos)
	local pathPos = tempPos and tempPos or unit.pos
	local pathPot = (unit.ms * ((GetDistance(pathPos) / speed) + delay))
	local unitBR = unit.boundingRadius
	--
	if pathCount < 2 then
	local extPos = unit.pos:Extended(pathEndPos, pathPot - unitBR)
		--
	if GetDistance(unit.pos, extPos) > 0 then
	if GetDistance(unit.pos, pathEndPos) >= GetDistance(unit.pos, extPos) then
	calcPos = extPos
	else
	calcPos = pathEndPos
	end
	else
	calcPos = pathEndPos
	end
	else
	for i = pathIndex, pathCount do
	if unit:GetPath(i) and unit:GetPath(i - 1) then
	local startPos = i == pathIndex and unit.pos or unit:GetPath(i - 1)
	local endPos = unit:GetPath(i)
	local pathDist = GetDistance(startPos, endPos)
				--
	if unit:GetPath(pathIndex  - 1) then
	if pathPot > pathDist then
	pathPot = pathPot - pathDist
	else
	local extPos = startPos:Extended(endPos, pathPot - unitBR)
	calcPos = extPos
	if tempPos then
	return calcPos, calcPos
	else
	return CalculateTargetPosition(unit, spell, calcPos)
end
end
end
end
end
		--
	if GetDistance(unit.pos, pathEndPos) > unitBR then
	calcPos = pathEndPos
	else
	calcPos = unit.pos
end
end
	calcPos = calcPos and calcPos or unit.pos
	if tempPos then
	return calcPos, calcPos
	else
	return CalculateTargetPosition(unit, spell, calcPos)
end
end

UpdateMovementHistory =	function()
    for i = 1, TotalHeroes do
        local unit = Hero(i)
        if not _movementHistory[unit.charName] then
            _movementHistory[unit.charName] = {}
            _movementHistory[unit.charName]['EndPos'] = unit.pathing.endPos
            _movementHistory[unit.charName]['StartPos'] = unit.pathing.endPos
            _movementHistory[unit.charName]['PreviousAngle'] = 0
            _movementHistory[unit.charName]['ChangedAt'] = Timer()
        end

        if
            _movementHistory[unit.charName]['EndPos'].x ~= unit.pathing.endPos.x or _movementHistory[unit.charName]['EndPos'].y ~= unit.pathing.endPos.y or
                _movementHistory[unit.charName]['EndPos'].z ~= unit.pathing.endPos.z
         then
            _movementHistory[unit.charName]['PreviousAngle'] =
                Angle(
                Vector(_movementHistory[unit.charName]['StartPos'].x, _movementHistory[unit.charName]['StartPos'].y, _movementHistory[unit.charName]['StartPos'].z),
                Vector(_movementHistory[unit.charName]['EndPos'].x, _movementHistory[unit.charName]['EndPos'].y, _movementHistory[unit.charName]['EndPos'].z)
            )
            _movementHistory[unit.charName]['EndPos'] = unit.pathing.endPos
            _movementHistory[unit.charName]['StartPos'] = unit.pos
            _movementHistory[unit.charName]['ChangedAt'] = Timer()
        end
    end
end

local GetBestCastPosition = function (unit, spell)
	local range = spell.Range and spell.Range - 15 or huge
	local radius = spell.Radius == 0 and 1 or (spell.Radius + unit.boundingRadius) - 4
	local speed = spell.Speed or huge
	local from = spell.From or Ekko
	local delay = spell.Delay + (0.07 + Latency() / 2000)
	local collision = spell.Collision or false
	
	local Position, CastPosition, HitChance = Vector(unit), Vector(unit), 0
	local TargetDashing, CanHitDashing, DashPosition = IsDashing(unit, spell)
	local TargetImmobile, ImmobilePos, ImmobileCastPosition = IsImmobile(unit, spell)
	if TargetDashing then
	if CanHitDashing then
	HitChance = 5
	else
	HitChance = 0
end
	Position, CastPosition = DashPosition, DashPosition
	elseif TargetImmobile then
	Position, CastPosition = ImmobilePos, ImmobileCastPosition
	HitChance = 4
	else
	Position, CastPosition = CalculateTargetPosition(unit, spell)
	if _movementHistory and _movementHistory[unit.charName] and Timer() - _movementHistory[unit.charName]['ChangedAt'] < .25 then
    HitChance = 2
end
	local active = unit.activeSpell
	if active and active.valid then
	HitChance = 2
end
	if GetDistanceSqr(from.pos, CastPosition) < 250 then
	HitChance = 2
	local newSpell = {Range = range, Delay = delay * 0.5, Radius = radius, Width = radius, Speed = speed *2, From = from}
	Position, CastPosition = CalculateTargetPosition(unit, newSpell)
end
	local temp_angle = from.pos:AngleBetween(unit.pos, CastPosition)
	if temp_angle > 60 then
	HitChance = 1
	elseif temp_angle < 30 then
	HitChance = 2
end
end	    
   --Dont need
	if collision and HitChance > 0 then
	local newSpell = {Range = range, Delay = delay, Radius = radius * 2, Width = radius * 2, Speed = speed *2, From = from}
	if #(mCollision(from.pos, CastPosition, newSpell)) > 0 then
	HitChance = 0                    
end
end        	
	return Position, CastPosition, HitChance
end

local ExcludeFurthest = function(average,lst,sTar)
	local removeID = 1 
	for i = 2, #lst do 
	if GetDistanceSqr(average, lst[i].pos) > GetDistanceSqr(average, lst[removeID].pos) then 
	removeID = i 
end 
end 
	local Newlst = {}
	for i = 1, #lst do 
	if (sTar and lst[i].networkID == sTar.networkID) or i ~= removeID then 
	Newlst[#Newlst + 1] = lst[i]
end
end
	return Newlst 
end


GetBestCircularCastPos = function(spell, sTar, lst)
	local average = {x = 0, z = 0, count = 0} 
	local heroList = lst and lst[1] and (lst[1].type == Ekko.type)
	local range = spell.Range or 2000
	local radius = spell.Radius or 50	
	if sTar and (not lst or #lst == 0) then 
	return GetBestCastPosition(sTar,spell), 1
end	
	--
	if lst then
	for i = 1, #lst do 
	if validTarget(lst[i]) then			
	local org = heroList and GetBestCastPosition(lst[i],spell) or lst[i].pos			
	average.x = average.x + org.x 
	average.z = average.z + org.z 
	average.count = average.count + 1
end
end 
end
	--
	if sTar and sTar.type ~= lst[1].type then		
	local org = heroList and GetBestCastPosition(sTar,spell) or lst[i].pos		
	average.x = average.x + org.x 
	average.z = average.z + org.z 
	average.count = average.count + 1
end
	--
	average.x = average.x/average.count 
	average.z = average.z/average.count 
	--
	local inRange = 0 
	if lst then
	for i = 1, #lst do 		
	local bR = lst[i].boundingRadius
	if GetDistanceSqr(average, lst[i].pos) - bR * bR < radius * radius then 			
	inRange = inRange + 1 
end
end
end	
	--
	local point = Vector(average.x,Ekko.pos.y,average.z)
	--
	if lst then
	if inRange == #lst then 
	return point, inRange
	else 
	if lst ~= nil and sTar ~= nil then 
	return GetBestCircularCastPos(spell, sTar, ExcludeFurthest(average, lst))
end
end
end
end

GetBestLinearCastPos = function(spell, sTar, list)
	startPos = spell.From.pos or Ekko.pos
	local isHero =  list[1].type == Ekko.type
	--
	local center = GetBestCircularCastPos(spell, sTar, list)
	local endPos = startPos + (center - startPos):Normalized() * spell.Range
	local MostHit = isHero
	return endPos, MostHit
end

Angle = function(A, B)
    local deltaPos = A - B
    local angle = atan2(deltaPos.x, deltaPos.z) * 180 / pi
    if angle < 0 then
    angle = angle + 360
end
    return angle
end

GetIgnite = function()
    if Ekko:GetSpellData(SUMMONER_2).name:lower() == "summonerdot" then
    igniteSlot = 5
    ignite = HK_SUMMONER_2
    elseif Ekko:GetSpellData(SUMMONER_1).name:lower() == "summonerdot" then
    igniteSlot = 4
    ignite = HK_SUMMONER_1
    else
    igniteSlot = nil
    ignite = nil
end    
end

checkItems = function()
	local items = {}
	for slot = ITEM_1,ITEM_7 do
		local id = myHero:GetItemData(slot).itemID 
		if id > 0 then
			items[id] = slot
		end
	end
	return items
end

function ValidTarget(target, range)
    range = range and range or math
    return target ~= nil and target.valid and target.visible and not target.dead and target.distance <= range
end

Items = function(target)
	local items = checkItems()
	local targetHG = GetTarget(700)  
	if target then	
	if ignite and igniteSlot and Flux.Killsteal.ign:Value() then
	if target and Ready(igniteSlot) == 0 and GetDistanceSqr(myHero, target) < 450 * 450 and 25 >= (100 * target.health / target.maxHealth) then
	Cast(ignite, target)    
    if Flux.Killsteal.gunbladebilge:Value() then
    if GetItemSlot(myHero, 3146) > 0 and ValidTarget(targetHG, 700) then
            if myHero:GetSpellData(GetItemSlot(myHero, 3146)).currentCd == 0 then
               Cast(Item_HK[GetItemSlot(myHero, 3146)], targetHG)
            end
        end
    end
end
end
end
end	

--------------------------------------------------------------------------------------------------------------------------------		
--------------------------------------------------------------------------------------------------------------------------------	
----------------------------------------------------------------LocalCallBacks-------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
LocalCallbackAdd('Load',function()     
	Item_HK = {}   
    TotalHeroes = GetEnemyHeroes()
	GetIgnite()
    FluxMenu()
	if #_EnemyHeroes > 0 then
	for i = 1, TotalHeroes do
	local hero = _EnemyHeroes[i]
	Flux.Killsteal:MenuElement({id = hero.charName, name = "Use ignite on: "..hero.charName, value = true})
end
end
	if Timer() > Flux.Rate.champion:Value() and #_EnemyHeroes == 0 then
	for i = 1, TotalHeroes do
	local hero = _EnemyHeroes[i]
	Flux.Killsteal:MenuElement({id = hero.charName, name = "Use ignite on: "..hero.charName, value = true})
end
end


		if _G.SDK and _G.SDK.Orbwalker then
			Orb = 1
		elseif _G.GOS then
			Orb = 2
		elseif _G.gsoSDK then
			Orb = 3
		end
				
		if  Orb == 1 then
			Orbwalker = SDK.Orbwalker
			SDKCombo = SDK.ORBWALKER_MODE_COMBO
			SDKHarass = SDK.ORBWALKER_MODE_HARASS
			SDKJungleClear = SDK.ORBWALKER_MODE_JUNGLECLEAR
			SDKJungleClear = SDK.ORBWALKER_MODE_JUNGLECLEAR
			SDKLaneClear = SDK.ORBWALKER_MODE_LANECLEAR
			SDKLastHit = SDK.ORBWALKER_MODE_LASTHIT
			SDKFlee = SDK.ORBWALKER_MODE_FLEE
			SDKSelector = SDK.TargetSelector
			SDKMagicDamage = _G.SDK.DAMAGE_TYPE_MAGICAL
			SDKPhysicalDamage = _G.SDK.DAMAGE_TYPE_PHYSICAL
		elseif  Orb == 2 then
		   
		end
    end)

	local orbwalkername = ""
	local orb
	if SDK then
	orbwalkername = "IC'S orbwalker"
	orb = SDK
	elseif _G.GOS then
	orbwalkername = "Noddy orbwalker"
	orb = _G.GOS
	elseif _G.gsoSDK then
	orbwalkername = "Gamesteron orbwalker"
	orb = _G.gsoSDK
	else
	orbwalkername = "Orbwalker not found"
end

LocalCallbackAdd('Tick',function()
	
	Item_HK[ITEM_1] = HK_ITEM_1
    Item_HK[ITEM_2] = HK_ITEM_2
    Item_HK[ITEM_3] = HK_ITEM_3
    Item_HK[ITEM_4] = HK_ITEM_4
    Item_HK[ITEM_5] = HK_ITEM_5
    Item_HK[ITEM_6] = HK_ITEM_6
    Item_HK[ITEM_7] = HK_ITEM_7
	
    if Timer() > Flux.Rate.champion:Value() and #_EnemyHeroes == 0 then
    TotalHeroes = GetEnemyHeroes()
    for i = 1, TotalHeroes do
    local hero = _EnemyHeroes[i]
    Flux.Killsteal:MenuElement({id = hero.charName, name = "Use ignite on: "..hero.charName, value = true})
end
UpdateMovementHistory()
            if myHero.dead or Game.IsChatOpen() == true  or isEvading then return end
end
    if #_EnemyHeroes == 0 then return end
    OnVisionF()
	
	
    if Ekko.dead or Game.IsChatOpen() == true  or isEvading then return end
	if Flux.Combo.useAutoQ:Value() then
	--AutoQ()
end
    if Flux.Combo.comboActive:Value() and Ekko.attackData.state ~= 2 then
    Combo()
end
    if Flux.Harass.harassActive:Value() then
    HarassMode()
end
    if Flux.Clear.clearActive:Value() then
    ClearMode()
    ClearJungle()
end
    if Flux.Lasthit.lasthitActive:Value() then
    LastHitMode()
end
--if  clock() - hpredTick > 10 then              
--end
--hpredTick = clock()
end)

LocalCallbackAdd('Draw', function()
    if Flux.Drawings.Q.Enabled:Value() then DrawCircle(Ekko.pos, Q.Range, 0, Flux.Drawings.Q.Color:Value()) end
    if Flux.Drawings.W.Enabled:Value() then DrawCircle(Ekko.pos, W.Range, 0, Flux.Drawings.W.Color:Value()) end
	if Flux.Drawings.E.Enabled:Value() then DrawCircle(Ekko.pos, E.Range, 0, Flux.Drawings.E.Color:Value()) end
    if Flux.Drawings.R.Enabled:Value() then DrawCircle(Ekko.pos, R.Range, 0, Flux.Drawings.R.Color:Value()) end
end)

----------
--Menu ---
----------
FluxMenu = function()
	Flux = MenuElement({type = MENU, id = "Ekko", name = "Ekko the Boy Who Shattered Time:BETA", icon = FluxIcon})
	MenuElement({ id = "blank", type = SPACE ,name = "Version BETA 0.0.1"})
-----------	
--Combo ---
-----------	
    Flux:MenuElement({id = "Combo", name = "Combo", type = MENU})
    Flux.Combo:MenuElement({id = "UseQ", name = "Q", value = true})
	Flux.Combo:MenuElement({id = "UseW", name = "W", value = true})
    Flux.Combo:MenuElement({id = "UseE", name = "E", value = true})
    Flux.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
	Flux.Combo:MenuElement({id = "Health", name = "[Health %]", value = 0.25, min = 0.1, max = 1, step = 0.05})
	Flux.Combo:MenuElement({id = "useAutoQ", name = "Enable AutoQ", key = string.byte("M"), toggle = true})
	Flux.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
-----------------------------	
--Killsteal and Activator ---	
-----------------------------
	Flux:MenuElement({id = "Killsteal", name = "Killsteal and Activator", type = MENU})
	Flux.Killsteal:MenuElement({id = "ign", name = "AutoIgnite", value = true})	
	Flux.Killsteal:MenuElement({id = "gunbladebilge", name = "Gunbblade and Bilgewater in combo", value = true})
------------
--Harass ---	
------------	
    Flux:MenuElement({id = "Harass", name = "Harass", type = MENU})
	Flux.Harass:MenuElement({id = "UseQ", name = "Q", value = true})
	Flux.Harass:MenuElement({id = "harassActive", name = "Harass Key", key = string.byte("C")})
---------------	
--LaneClear ---	
---------------	
	Flux:MenuElement({id = "Clear", name = "Clear", type = MENU})
	Flux.Clear:MenuElement({id = "UseQ", name = "Q", value = true})
	Flux.Clear:MenuElement({id = "QCount", name = "Use Q on X minions", value = 3, min = 1, max = 4, step = 1})
	Flux.Clear:MenuElement({id = "clearActive", name = "Clear key", key = string.byte("V")})
-------------   
--LastHit ---   
------------- 
	Flux:MenuElement({id = "Lasthit", name = "Lasthit", type = MENU})
	Flux.Lasthit:MenuElement({id = "UseQ", name = "Q", value = true})
    Flux.Lasthit:MenuElement({id = "lasthitActive", name = "Lasthit key", key = string.byte("X")})
------------------
--Recache Rate ---
------------------
    Flux:MenuElement({id = "Rate", name = "Recache Rate", type = MENU})
	Flux.Rate:MenuElement({id = "champion", name = "Value", value = 30, min = 1, max = 120, step = 1})
--------------
--Drawings ---
--------------
    Flux:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
    Flux.Drawings:MenuElement({id = "Q", name = "Draw Q range", type = MENU})
    Flux.Drawings.Q:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    Flux.Drawings.Q:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    Flux.Drawings.Q:MenuElement({id = "Color", name = "Color", color = DrawColor(200, 255, 255, 255)})

    Flux.Drawings:MenuElement({id = "E", name = "Draw E range", type = MENU})
    Flux.Drawings.E:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    Flux.Drawings.E:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    Flux.Drawings.E:MenuElement({id = "Color", name = "Color", color = DrawColor(200, 255, 255, 255)})

    Flux.Drawings:MenuElement({id = "W", name = "Draw W range", type = MENU})
    Flux.Drawings.W:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    Flux.Drawings.W:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    Flux.Drawings.W:MenuElement({id = "Color", name = "Color", color = DrawColor(200, 255, 255, 255)})
    
    Flux.Drawings:MenuElement({id = "R", name = "Draw R range", type = MENU})
    Flux.Drawings.R:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    Flux.Drawings.R:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    Flux.Drawings.R:MenuElement({id = "Color", name = "Color", color = DrawColor(200, 255, 255, 255)})
	end
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------	
-----------------------------------------------	COMBO function-------------------------------------------------
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------	





local CastQ = function()
	local target = GetTarget(1600)
	local targetQ = GetTarget(Q.Range)
	if targetQ then
			if Ready(_Q) == 0 and target.pos:DistanceTo() <= Q.Range  and Flux.Combo.UseQ:Value() then
            local Qpos, qcpos, hitchance = GetBestCastPosition(targetQ, Q)
            if hitchance >= 2 then
            if Qpos:DistanceTo() > Q.Range then 
                Qpos = Ekko.pos + (Qpos - Ekko.pos):Normalized()*Q.Range
                end
            Qpos = Ekko.pos + (Qpos - Ekko.pos):Normalized()*(GetDistance(Qpos, Ekko.pos) + 0.5*targetQ.boundingRadius)
            if Qpos:To2D().onScreen then
                Cast(HK_Q, Qpos, Q.Range, Q.Delay) 
end
end
end  
end
end

local CastE = function()
	local targetE = GetTarget(E.Range)
	if targetE then
	if Ready(_E) == 0 then
	Cast(HK_E, target)					
end
end
end

local CastW = function()
	local CastPos, HitChance, TimeToHit = PremiumPrediction:GetPrediction(Ekko, target, 1650, 1600, 3.75, 375, false)
	if CastPos and HitChance >= 5 and TimeToHit < 1 and ValidTarget(target, 1600) and Ready(_R) then
    Cast(HK_Q, CastPos)
end 
end 


--[[local CastW = function()
	local targetW = GetTarget(2000)
	if targetW then
	if Ready(_W) == 0 and GetBestCircularCastPos(W, targetW) then
	Cast(HK_W, targetW)
end
end
end	]]
	


local CastR = function()
	local target = GetTarget(1600)
	local targetR = GetTarget(R.Range)
	if targetR then
	if Ready(_R) == 0 and target.pos:DistanceTo(Ekko.pos) < 500 then 
    if Ekko.health/Ekko.maxHealth <= Flux.Combo.Health:Value() then
	Cast(HK_R, Ekko)			
end			
end 
end
end
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------	
-----------------------------------------------	SPELLS-------------------------------------------------
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------	

Combo = function()
	local target = GetTarget(1600)
	if target then
	Items(target)
	end
	if Flux.Combo.UseR:Value() then
	CastR()
end

	if Flux.Combo.UseW:Value() then
	CastW(target)
end	
	
	if Flux.Combo.UseE:Value() then 
	CastE()
end	

	if Flux.Combo.UseQ:Value() then 
	CastQ()
end
end
	
		


			
				-----------------------------------------------E+Q USAGE---------------------------------------------
		--[[	local CastQE = CastSpell
			local targetE = GetTarget(E.Range)
			if Ready(_E) == 0 and Ready(_Q) == 0 and target.pos:DistanceTo() <= Q.Range and Flux.Combo.UseEQ:Value() then
			local Qpos, qcpos, hitchance = GetBestCastPosition(targetQ, Q)
			if Qpos:DistanceTo() > Q.Range then 
                Qpos = Ekko.pos + (Qpos - Ekko.pos):Normalized()*Q.Range
                end
			Qpos = Ekko.pos + (Qpos - Ekko.pos):Normalized()*(GetDistance(Qpos, Ekko.pos) + 0.5*targetQ.boundingRadius)
            if Qpos:To2D().onScreen then
			CastQE(HK_E, target)
			CastQE(HK_Q, Qpos, Q.Range, Q.Delay)
			SDK.Orbwalker:__OnAutoAttackReset(target)
end
end]]--


			-----------------------------------------------E USAGE---------------------------------------------
			--[[local targetE = GetTarget(E.Range)
			if targetE then
			if Ready(_E) == 0 and Flux.Combo.UseE:Value() then
			Cast(HK_E, target)
			SDK.Orbwalker:__OnAutoAttackReset(target)
			SDK.Orbwalker:__OnAutoAttackReset(target)
				
				

end
end	]]--		
				
                -----------------------------------------------QE USAGE---------------------------------------------

		--[[	local CastQ = CastSpell
			local targetQ = GetTarget(Q.Range)
			local targetE = GetTarget(E.Range)
			if targetE then
			if Ready(_E) == 0 and Ready(_Q) == 0 and target.pos:DistanceTo() <= Q.Range  and Flux.Combo.UseEQ:Value() then
            local Qpos, qcpos, hitchance = GetBestCastPosition(targetQ, Q)
            if hitchance >= 2 then
            if Qpos:DistanceTo() > Q.Range then 
                Qpos = Ekko.pos + (Qpos - Ekko.pos):Normalized()*Q.Range
                end
            Qpos = Ekko.pos + (Qpos - Ekko.pos):Normalized()*(GetDistance(Qpos, Ekko.pos) + 0.5*targetQ.boundingRadius)
            if Qpos:To2D().onScreen then
				Cast(HK_E, target)
                CastQ(HK_Q, Qpos, Q.Range, Q.Delay) 
				SDK.Orbwalker:__OnAutoAttackReset(target)
				 else
				 Cast(HK_E, target)
                CastSpellMM(HK_Q, Qpos, Q.Range, Q.Delay)
				SDK.Orbwalker:__OnAutoAttackReset(target)
            end
            end
            end
          end]]
		  
				
	
         
		  

            -----------------------------------------------W USAGE---------------------------------------------	
		--[[local targetW = GetTarget(W.Range)
		if targetW then
		if Ready(_W) == 0 and Flux.Combo.UseW:Value() and Ekko.pos:DistanceTo(target.pos) <= 500 then
		 local Wpos, qcpos, hitchance = GetBestCastPosition(targetW, W)
            if hitchance >= 2 then
            if Wpos:DistanceTo() > W.Range then 
                Wpos = Ekko.pos + (Wpos - Ekko.pos):Normalized()*W.Range
                end
            Wpos = Ekko.pos + (Wpos - Ekko.pos):Normalized()*(GetDistance(Wpos, Ekko.pos) + 0.5*targetW.boundingRadius)
            if Wpos:To2D().onScreen then
                CastQ(HK_W, Wpos, W.Range, W.Delay) 
				 else
                CastSpellMM(HK_W, Wpos, W.Range, W.Delay)]]

			
		

			-----------------------------------------------E USAGE---------------------------------------------
			--[[local targetE = GetTarget(E.Range)
			if targetE then
			if Ready(_E) == 0 and Flux.Combo.UseE:Value() then
			Cast(HK_E, target)
			SDK.Orbwalker:__OnAutoAttackReset(target)
			SDK.Orbwalker:__OnAutoAttackReset(target)



				
				

end
end
end



			-----------------------------------------------R USAGE---------------------------------------------
			 local targetR = GetTarget(R.Range)
			 if targetR and Flux.Combo.UseR:Value() then
			 if Ready(_R) == 0 and target.pos:DistanceTo(Ekko.pos) < 500 then 
        if Ekko.health/Ekko.maxHealth <= Flux.Combo.Health:Value() then
		     Cast(HK_R, Ekko)
			
end			
end 
end
end]]





				
				HarassMode = function()
			local target = GetTarget(1600)
			if target then
			local CastQ = CastSpell
			local targetQ = GetTarget(Q.Range)
			if Ready(_Q) == 0 and target.pos:DistanceTo() <= Q.Range  and Flux.Combo.UseQ:Value() then
            local Qpos, qcpos, hitchance = GetBestCastPosition(targetQ, Q)
            if hitchance >= 2 then
            if Qpos:DistanceTo() > Q.Range then 
                Qpos = Ekko.pos + (Qpos - Ekko.pos):Normalized()*Q.Range
                end
            Qpos = Ekko.pos + (Qpos - Ekko.pos):Normalized()*(GetDistance(Qpos, Ekko.pos) + 0.5*targetQ.boundingRadius)
            if Qpos:To2D().onScreen then
                CastQ(HK_Q, Qpos, Q.Range, Q.Delay) 
				 else
                CastSpellMM(HK_Q, Qpos, Q.Range, Q.Delay)
            end
            end
            end
			
end
end

ValidTargetM = function(target, range)
    range = range and range or huge
    return target ~= nil and target.valid and target.visible and not target.dead and target.distance <= range
end

ClearMode = function()
   
end

ClearJungle = function()


end

LastHitMode = function()
   
end

	
