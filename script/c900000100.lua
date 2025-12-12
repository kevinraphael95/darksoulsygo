-- Le Mort-Vivant élu
-- kevinraphael95
local s,id=GetID()
local SET_MORTVIVANT = 0x710
local COUNTER_SOUL = 0x700

function s.initial_effect(c)
	-- Autoriser le compteur Âme
	c:EnableCounterPermit(COUNTER_SOUL)

	-------------------------------------
	-- ATK/DEF par compteur (max 5)
	-------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)

	-------------------------------------
	-- Effet depuis le Cimetière
	-------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,0})
	e3:SetCost(s.gravecost)
	e3:SetTarget(s.gravetg)
	e3:SetOperation(s.graveop)
	c:RegisterEffect(e3)

	-------------------------------------
	-- Ajouter un compteur après avoir détruit un monstre
	-------------------------------------
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCondition(aux.bdgcon)
	e4:SetOperation(s.addcounter)
	c:RegisterEffect(e4)

	-------------------------------------
	-- Effet rapide pour annuler une carte en retirant 1 compteur
	-------------------------------------
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DISABLE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetCost(s.discost)
	e5:SetTarget(s.distg)
	e5:SetOperation(s.disop)
	c:RegisterEffect(e5)
end

-----------------------------
-- ATK/DEF par compteur (max 5)
-----------------------------
function s.atkval(e,c)
	return math.min(c:GetCounter(COUNTER_SOUL),5)*200
end

-----------------------------
-- Coût pour effet du Cimetière
-----------------------------
function s.gravecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	Duel.PayLPCost(tp,500)
end

-----------------------------
-- Cible pour effet du Cimetière
-----------------------------
function s.gravetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return e:GetHandler():IsAbleToHand() 
			or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
				and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false))
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

-----------------------------
-- Opération pour effet du Cimetière
-----------------------------
function s.graveop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	local ops,ids = {},{}

	if c:IsAbleToHand() then
		table.insert(ops, aux.Stringid(id,2))
		table.insert(ids,1)
	end

	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		table.insert(ops, aux.Stringid(id,3))
		table.insert(ids,2)
	end

	if #ops==0 then return end

	local sel=Duel.SelectOption(tp, table.unpack(ops))
	if ids[sel+1]==1 then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	else
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

-----------------------------
-- Ajouter compteur (max 5)
-----------------------------
function s.addcounter(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetCounter(COUNTER_SOUL)<5 then
		c:AddCounter(COUNTER_SOUL,1)
	end
end

-----------------------------
-- Coût pour annuler un effet
-----------------------------
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(COUNTER_SOUL)>0 end
	e:GetHandler():RemoveCounter(tp,COUNTER_SOUL,1,REASON_COST)
end

-----------------------------
-- Cible pour annulation
-----------------------------
function s.negfilter(c)
	return c:IsFaceup() and (c:IsType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP))
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	end
	local g=Duel.SelectMatchingCard(tp,s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end

-----------------------------
-- Opération annulation
-----------------------------
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and not tc:IsDisabled() then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)

		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)

		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
