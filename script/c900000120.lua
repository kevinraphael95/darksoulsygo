--Âme de Seigneur des Ténèbres
function c900000120.initial_effect(c)
	-- Auto-banish quand l'adversaire invoque depuis le Cimetière ou ajoute depuis le Cimetière
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c900000120.banishcon)
	e1:SetOperation(c900000120.banishop)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c900000120.banishcon2)
	e2:SetOperation(c900000120.banishop)
	c:RegisterEffect(e2)

	-- Condition de victoire depuis le Cimetière
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(900000120,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(c900000120.wincon)
	e3:SetCost(c900000120.wincost)
	e3:SetOperation(c900000120.winop)
	c:RegisterEffect(e3)
end

-- ===== Auto-banish =====

-- Déclenchement : SS depuis Cimetière
function c900000120.cfilter(c,tp)
	return c:GetPreviousLocation()==LOCATION_GRAVE and c:GetSummonPlayer()~=tp
end

function c900000120.banishcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c900000120.cfilter,1,nil,tp)
end

-- Déclenchement : ajout depuis Cimetière
function c900000120.thfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:GetControler()~=tp
end

function c900000120.banishcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c900000120.thfilter,1,nil,tp)
end

-- Bannir cette carte
function c900000120.banishop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
	end
end

-- ===== CONDITION DE VICTOIRE =====

function c900000120.wincon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,
		900000117,900000118,900000119,900000120)>=4
end

function c900000120.wincost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return c900000120.wincon(e,tp,eg,ep,ev,re,r,rp) end
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_GRAVE,0,nil,
		900000117,900000118,900000119,900000120)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function c900000120.winop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Win(tp,WIN_REASON_CUSTOM)
end
