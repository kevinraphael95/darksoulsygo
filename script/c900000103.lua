--Basilic Mort-vivant
local s,id=GetID()
function s.initial_effect(c)
	-- Autorise l'utilisation des compteurs Mort-vivant (0x700)
	c:EnableCounterPermit(0x700)

	--------------------------------------
	-- 1️⃣ DEF +500 par compteur Mort-vivant
	--------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.defval)
	c:RegisterEffect(e1)

	--------------------------------------
	-- 2️⃣ Effet FLIP : ajoute 1 compteur
	--------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e2:SetOperation(s.flipop)
	c:RegisterEffect(e2)

	---------------------------------------------------------
	-- 3️⃣ Réduction d'ATK des monstres qui attaquent ce monstre
	---------------------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(-700)
	c:RegisterEffect(e3)

	---------------------------------------------------------
	-- 4️⃣ Monstres ayant attaqué Ce monstre ne peuvent pas être utilisés en Matériel
	---------------------------------------------------------
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetTarget(s.matlimit)
	e4:SetValue(1)
	c:RegisterEffect(e4)

	---------------------------------------------------------
	-- 5️⃣ Marque les monstres ayant attaqué ce monstre
	---------------------------------------------------------
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_BATTLED)
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(s.markop)
	c:RegisterEffect(e5)
end

--------------------------------------
-- DEF +500 par compteur 0x700
--------------------------------------
function s.defval(e,c)
	return c:GetCounter(0x700)*500
end

--------------------------------------
-- FLIP : ajoute un compteur 0x700
--------------------------------------
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x700,1)
end

--------------------------------------
-- Condition : le monstre attaque ce monstre
--------------------------------------
function s.atkcon(e)
	local tc=Duel.GetAttacker()
	return tc and tc:GetBattleTarget()==e:GetHandler()
end

--------------------------------------
-- Marque les monstres ayant attaqué ce monstre
--------------------------------------
function s.markop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if a and d==c then
		a:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end

--------------------------------------
-- Restriction : monstres marqués ne peuvent pas être matériel
--------------------------------------
function s.matlimit(e,c)
	return c:GetFlagEffect(id)>0
end
