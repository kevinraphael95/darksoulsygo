--Âme de Seigneur de la Lumière
function c900000119.initial_effect(c)
	-- Activation
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,900000117) -- limite partagée "Âme de Seigneur"
	c:RegisterEffect(e0)

	-- Piocher quand l'adversaire ajoute à la main (hors Draw Phase)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(900000119,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c900000119.drcon)
	e1:SetTarget(c900000119.drtg)
	e1:SetOperation(c900000119.drop)
	c:RegisterEffect(e1)

	-- Condition de victoire depuis le Cimetière
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(900000119,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c900000119.wincon)
	e2:SetCost(c900000119.wincost)
	e2:SetOperation(c900000119.winop)
	c:RegisterEffect(e2)
end

-- ===== PIoche miroir =====

function c900000119.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- adversaire uniquement
	if ep==tp then return false end
	-- pas pendant la Draw Phase
	if Duel.GetCurrentPhase()==PHASE_DRAW then return false end
	-- cartes venant du Deck ou Cimetière
	return eg:IsExists(function(c)
		return c:IsPreviousLocation(LOCATION_DECK+LOCATION_GRAVE)
	end,1,nil)
end

function c900000119.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(function(c)
		return c:IsPreviousLocation(LOCATION_DECK+LOCATION_GRAVE)
	end,nil)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end

function c900000119.drop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(function(c)
		return c:IsPreviousLocation(LOCATION_DECK+LOCATION_GRAVE)
	end,nil)
	if ct>0 then
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end

-- ===== CONDITION DE VICTOIRE =====

function c900000119.wincon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,
		900000117,900000118,900000119,900000120)>=4
end

function c900000119.wincost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return c900000119.wincon(e,tp,eg,ep,ev,re,r,rp) end
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_GRAVE,0,nil,
		900000117,900000118,900000119,900000120)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function c900000119.winop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Win(tp,WIN_REASON_CUSTOM)
end
