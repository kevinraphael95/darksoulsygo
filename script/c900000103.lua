--Basilic Mort-vivant
local s,id=GetID()
function s.initial_effect(c)
	-- Autorise l'utilisation de compteurs Âme (0x101)
	c:EnableCounterPermit(0x101)

	-- 1️⃣ Augmentation de DEF selon le nombre de compteurs Âme
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.defval)
	c:RegisterEffect(e1)

	-- 2️⃣ Effet FLIP : ajoute un compteur Âme
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e2:SetOperation(s.flipop)
	c:RegisterEffect(e2)

	-- 3️⃣ Réduction d'ATK des monstres attaquant cette carte
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(-700)
	c:RegisterEffect(e3)

	-- 4️⃣ Restriction de matériel pour les monstres ayant attaqué cette carte
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetTarget(s.matlimit)
	e4:SetValue(1)
	c:RegisterEffect(e4)

	-- 5️⃣ Marquer les monstres qui ont attaqué cette carte
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_BATTLED)
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(s.markop)
	c:RegisterEffect(e5)
end

-- 🔹 Calcul DEF par compteur Âme
function s.defval(e,c)
	return c:GetCounter(0x101)*500
end

-- 🔹 Effet FLIP : ajoute un compteur Âme
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x101,1)
end

-- 🔹 Condition pour réduire ATK : le monstre attaque cette carte
function s.atkcon(e)
	local tc=Duel.GetAttacker()
	if not tc then return false end
	return tc:GetBattleTarget()==e:GetHandler()
end

-- 🔹 Marquer les monstres ayant attaqué cette carte
function s.markop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if a and d==c then
		a:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end

-- 🔹 Restriction de matériel : empêche les monstres marqués d'être utilisés
function s.matlimit(e,c)
	return c:GetFlagEffect(id)>0
end
