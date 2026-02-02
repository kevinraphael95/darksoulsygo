--Âme de Seigneur de la Vie
function c900000118.initial_effect(c)
	-- Annuler Invocation + Invocation Spéciale
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(900000118,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCountLimit(1,900000117) -- partage la limite "Âme de Seigneur"
	e1:SetCondition(c900000118.condition)
	e1:SetTarget(c900000118.target)
	e1:SetOperation(c900000118.operation)
	c:RegisterEffect(e1)

	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e2)

	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e3)

	-- Condition de victoire depuis le Cimetière
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(900000118,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(c900000118.wincon)
	e4:SetCost(c900000118.wincost)
	e4:SetOperation(c900000118.winop)
	c:RegisterEffect(e4)
end

-- Condition : invocation annulable
function c900000118.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0
end

-- Filtre Invocation Spéciale
function c900000118.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function c900000118.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(c900000118.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

-- Annulation Invocation + SS
function c900000118.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateSummon(eg) then
		Duel.Destroy(eg,REASON_EFFECT)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,c900000118.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

-- ===== CONDITION DE VICTOIRE =====

function c900000118.winfilter(c)
	return c:IsSetCard(0x999) or c:IsCode(900000117) or c:IsCode(900000118)
end
-- ⚠️ plus sûr : vérifier par Code exact si tu as 4 cartes précises

function c900000118.wincon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,
		900000117,900000118,900000119,900000120) >= 4
end

function c900000118.wincost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return c900000118.wincon(e,tp,eg,ep,ev,re,r,rp) end
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_GRAVE,0,nil,
		900000117,900000118,900000119,900000120)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function c900000118.winop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Win(tp,WIN_REASON_CUSTOM)
end
