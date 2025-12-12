--Feu de camps
--kevinraphael95
local s,id=GetID()
function s.initial_effect(c)
	-- Activer la carte
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- Une fois par tour : choisissez un effet
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,5))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE) -- IMPORTANT : carte continue, donc Zone Magie & Piège
	e1:SetCountLimit(1,id) -- une fois par tour
	e1:SetTarget(s.mttg)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
end

function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local ops,ids={},{}

	-- Option 1 : Gagner 1000 LP
	table.insert(ops, aux.Stringid(id,6))
	table.insert(ids,1)

	-- Option 2 : Placer 1 compteur sur un Zombie face-up si possible
	if Duel.IsExistingMatchingCard(Card.IsFaceup, tp, LOCATION_MZONE, 0, 1, nil) then
		local g=Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
		if g:IsExists(Card.IsRace,1,nil,RACE_ZOMBIE) then
			table.insert(ops, aux.Stringid(id,7))
			table.insert(ids,2)
		end
	end

	-- Option 3 : Ajouter un Zombie depuis le Cimetière si possible
	if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsRace), tp, LOCATION_GRAVE, 0, 1, nil, RACE_ZOMBIE) then
		table.insert(ops, aux.Stringid(id,8))
		table.insert(ids,3)
	end

	if #ops==0 then return end

	local sel=Duel.SelectOption(tp, table.unpack(ops))
	local choice=ids[sel+1]

	if choice==1 then
		Duel.Recover(tp,1000,REASON_EFFECT)
	elseif choice==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp, aux.FaceupFilter(Card.IsRace,RACE_ZOMBIE), tp, LOCATION_MZONE, 0, 1, 1, nil)
		if #g>0 then g:GetFirst():AddCounter(0x101,1) end
	elseif choice==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(Card.IsRace), tp, LOCATION_GRAVE, 0, 1, 1, nil, RACE_ZOMBIE)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
