--Pyre des Possibles
function c900000121.initial_effect(c)
	-- Activation
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,900000121) -- 1 Pyre par tour
	e1:SetTarget(c900000121.target)
	e1:SetOperation(c900000121.activate)
	c:RegisterEffect(e1)
end

-- Filtre cartes de l'Extra Deck face verso
function c900000121.exfilter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end

-- Filtre cartes bannies pour récupération
function c900000121.rfilter(c)
	return c:IsAbleToHand() or c:IsAbleToGrave()
end

-- Ciblage
function c900000121.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ex=Duel.GetMatchingGroup(c900000121.exfilter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then
		return #ex>=3
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_EXTRA)
end

-- Opération
function c900000121.activate(e,tp,eg,ep,ev,re,r,rp)
	local ex=Duel.GetMatchingGroup(c900000121.exfilter,tp,LOCATION_EXTRA,0,nil)
	if #ex<3 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local count=Duel.AnnounceNumber(tp,3,6,9)
	if #ex<count then count=#ex end

	local g=ex:Select(tp,count,count,nil)
	if Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)==0 then return end

	-- Récupération
	local rg=Duel.GetOperatedGroup()
	if #rg==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local maxrec=math.min(#rg,3)
	local recg=rg:Select(tp,1,maxrec,nil)

	for tc in aux.Next(recg) do
		if tc:IsAbleToHand() then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		elseif tc:IsAbleToGrave() then
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
