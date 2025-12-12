--Feu de camps
--kevinraphael95
local s,id=GetID()

-- Archetype Mort-Vivant
local SET_MORTVIVANT = 0x710

-- Compteur Âme
local COUNTER_SOUL = 0x700

function s.initial_effect(c)
	-- Autoriser l'utilisation du compteur
	c:EnableCounterPermit(COUNTER_SOUL)

	-- Activation libre
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- Une fois par tour : choisir un effet
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0)) -- index 0
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.mttg)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
end

-- Cible : toujours valide
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	return true
end

-- Choix et résolution de l'effet
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local ops, ids = {}, {}

	-- Option 1 : Gagnez 1000 LP
	table.insert(ops, aux.Stringid(id,1))
	table.insert(ids,1)

	-- Option 2 : Ajouter 1 compteur Âme sur un Mort-Vivant
	local g=Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
	if g:IsExists(Card.IsSetCard,1,nil,SET_MORTVIVANT) then
		table.insert(ops, aux.Stringid(id,2))
		table.insert(ids,2)
	end

	-- Option 3 : Récupérer un Mort-Vivant depuis le Cimetière
	if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsSetCard), tp, LOCATION_GRAVE, 0, 1, nil, SET_MORTVIVANT) then
		table.insert(ops, aux.Stringid(id,3))
		table.insert(ids,3)
	end

	if #ops==0 then return end

	local sel = Duel.SelectOption(tp, table.unpack(ops))
	local choice = ids[sel+1]

	if choice==1 then
		Duel.Recover(tp,1000,REASON_EFFECT)

	elseif choice==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local tg=Duel.SelectMatchingCard(tp, Card.IsFaceup, tp, LOCATION_MZONE, 0, 1,1,nil)
		local tc = tg:GetFirst()
		if tc and tc:IsSetCard(SET_MORTVIVANT) then
			tc:AddCounter(COUNTER_SOUL,1)
		end

	elseif choice==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local hg=Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(Card.IsSetCard), tp, LOCATION_GRAVE, 0, 1, 1, nil, SET_MORTVIVANT)
		if #hg>0 then
			Duel.SendtoHand(hg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,hg)
		end
	end
end
