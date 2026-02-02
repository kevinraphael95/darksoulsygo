--Forgeron
function c900000116.initial_effect(c)
	-- Ajout Carte Équipement à l'invocation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(900000116,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c900000116.thtg)
	e1:SetOperation(c900000116.thop)
	c:RegisterEffect(e1)

	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)

	-- Envoyer Équipement pour piocher
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(900000116,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c900000116.drcost)
	e2:SetTarget(c900000116.drtg)
	e2:SetOperation(c900000116.drop)
	c:RegisterEffect(e2)
end

-- Filtre Carte Équipement
function c900000116.eqfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end

-- Target ajout
function c900000116.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(c900000116.eqfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- Opération ajout
function c900000116.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c900000116.eqfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- Coût : envoyer 1 Équipement depuis main ou terrain
function c900000116.costfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end

function c900000116.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(c900000116.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c900000116.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

-- Target pioche
function c900000116.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

-- Opération pioche
function c900000116.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end
