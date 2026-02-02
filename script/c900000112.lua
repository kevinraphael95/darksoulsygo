--Serpent Primordial des Ténèbres
function c900000112.initial_effect(c)
	-- Xyz Summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),4,2)
	c:EnableReviveLimit()

	-- Détacher 1 : réduction ATK/DEF + annulation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(900000112,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c900000112.cost)
	e1:SetTarget(c900000112.target)
	e1:SetOperation(c900000112.operation)
	c:RegisterEffect(e1)

	-- Invocation spéciale après destruction au combat
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(900000112,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(aux.bdogcon)
	e2:SetTarget(c900000112.sptg)
	e2:SetOperation(c900000112.spop)
	c:RegisterEffect(e2)

	-- Boost ATK/DEF DARK
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c900000112.boosttg)
	e3:SetValue(200)
	c:RegisterEffect(e3)

	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end

-- Coût : détacher 1 Matériel
function c900000112.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- Ciblage monstre adverse
function c900000112.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
end

-- Réduction + annulation
function c900000112.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- ATK -500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- DEF -500
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		-- Annulation effets
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e4)
	end
end

-- Filtres Invocation Spéciale
function c900000112.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsLevelBelow(4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function c900000112.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(c900000112.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function c900000112.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c900000112.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- Cible boost DARK
function c900000112.boosttg(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
