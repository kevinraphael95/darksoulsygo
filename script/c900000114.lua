--Mère de la Pyromancie
function c900000114.initial_effect(c)
	-- Synchro Summon
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()

	-- Destruction totale + dégâts à l'invocation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(900000114,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c900000114.descon)
	e1:SetTarget(c900000114.destg)
	e1:SetOperation(c900000114.desop)
	c:RegisterEffect(e1)

	-- Effet quand elle quitte le terrain
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(900000114,1))
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(c900000114.leavetg)
	e2:SetOperation(c900000114.leaveop)
	c:RegisterEffect(e2)
end

-- Condition : Invocation Synchro
function c900000114.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

-- Target destruction
function c900000114.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
	end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*500)
end

-- Destruction + burn
function c900000114.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end

-- Filtre Démon
function c900000114.spfilter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Target leave field
function c900000114.leavetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1500)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

-- Leave field operation
function c900000114.leaveop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(tp,1500,REASON_EFFECT)
	Duel.Damage(1-tp,1500,REASON_EFFECT)

	Duel.Draw(tp,1,REASON_EFFECT)
	Duel.Draw(1-tp,1,REASON_EFFECT)

	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.IsExistingMatchingCard(c900000114.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,c900000114.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
