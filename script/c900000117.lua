--Âme de Seigneur de la Mort
function c900000117.initial_effect(c)
	-- Activation à la déclaration d'attaque
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(900000117,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,900000117) -- 1 "Âme de Seigneur" par tour
	e1:SetCost(c900000117.cost)
	e1:SetTarget(c900000117.target)
	e1:SetOperation(c900000117.operation)
	c:RegisterEffect(e1)

	-- Condition de victoire depuis le Cimetière
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(900000117,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c900000117.wincon)
	e2:SetCost(c900000117.wincost)
	e2:SetOperation(c900000117.winop)
	c:RegisterEffect(e2)
end

-- Coût : défausser 1 carte
function c900000117.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

-- Ciblage
function c900000117.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()
	if chk==0 then return a and a:IsOnField() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,a,1,0,0)
end

-- Annulation attaque + destruction + fin de Battle Phase
function c900000117.operation(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	if not a or not a:IsRelateToBattle() then return end
	Duel.NegateAttack()
	if Duel.Destroy(a,REASON_EFFECT)>0 then
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
	end
end

-- ===== CONDITION DE VICTOIRE =====

function c900000117.winfilter(c)
	return c:IsCode(900000117)
end

function c900000117.wincon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(c900000117.winfilter,tp,LOCATION_GRAVE,0,nil)>=4
end

function c900000117.wincost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMatchingGroupCount(c900000117.winfilter,tp,LOCATION_GRAVE,0,nil)>=4
	end
	local g=Duel.GetMatchingGroup(c900000117.winfilter,tp,LOCATION_GRAVE,0,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function c900000117.winop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Win(tp,WIN_REASON_CUSTOM)
end
