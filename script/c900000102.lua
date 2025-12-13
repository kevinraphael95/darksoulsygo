--Le Doux Corbeau
local s,id=GetID()
function s.initial_effect(c)
	-- Compteurs Âme
	c:EnableCounterPermit(0x101)

	-- Effet principal
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.dcost)
	e1:SetTarget(s.dtg)
	e1:SetOperation(s.dop)
	c:RegisterEffect(e1)

	-- Effet destruction
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.ctcon)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
end

-- ======================
-- COST : défausse OU sacrifice
-- ======================
function s.dcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckReleaseGroup(tp,nil,1,nil)
		or Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
	end

	local opt
	if Duel.CheckReleaseGroup(tp,nil,1,nil)
	and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif Duel.CheckReleaseGroup(tp,nil,1,nil) then
		opt=1
	else
		opt=0
	end

	if opt==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
		local tc=g:GetFirst()
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
		e:SetLabelObject(tc)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
		local tc=g:GetFirst()
		Duel.Release(tc,REASON_COST)
		e:SetLabelObject(tc)
	end
end

-- Target vide (géré à l'opération)
function s.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

-- ======================
-- OPERATION
-- ======================
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc then return end

	-- MONSTRE
	if tc:IsType(TYPE_MONSTER) then
		if tc:GetLevel()>=10 then
			Duel.Draw(tp,1,REASON_EFFECT)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_GRAVE,0,1,1,nil,TYPE_MONSTER)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end

	-- MAGIE
	elseif tc:IsType(TYPE_SPELL) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_DECK,0,1,1,nil,0x710)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end

	-- PIEGE
	elseif tc:IsType(TYPE_TRAP) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_DECK,0,1,1,nil,TYPE_EQUIP)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

-- ======================
-- EFFET DESTRUCTION
-- ======================
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT)
end

function s.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x710)
end

function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_MZONE,0,1,nil)
	end
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
	local g=Duel.SelectMatchingCard(tp,s.ctfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		tc:AddCounter(0x101,1)
	end
end
