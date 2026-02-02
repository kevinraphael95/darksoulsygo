--Pygmé Furtif
function c900000111.initial_effect(c)
	-- Indestructible au combat
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	-- Invocation spéciale si envoyée au Cimetière
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(900000111,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,900000111)
	e2:SetTarget(c900000111.sptg)
	e2:SetOperation(c900000111.spop)
	c:RegisterEffect(e2)

	-- Boost ATK/DEF depuis le Cimetière
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c900000111.atktg)
	e3:SetValue(300)
	c:RegisterEffect(e3)

	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end

-- Filtres
function c900000111.spfilter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function c900000111.atktg(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end

-- Ciblage Invocation Spéciale
function c900000111.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(c900000111.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

-- Opération Invocation Spéciale
function c900000111.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c900000111.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
