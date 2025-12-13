--Gardienne du Feu
local s,id=GetID()

-- IDs officiels
s.counter_id=0x700	  -- Compteur Âme
s.archetype=0x710	   -- Mort-Vivant

function s.initial_effect(c)
	---------------------------------------
	-- Invocation Lien (Link-1, 1 LUMIÈRE)
	---------------------------------------
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),1,1)

	---------------------------------------
	-- Effet 1 : 1 Compteur Âme à l'invocation Lien
	---------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.ctcon)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)

	---------------------------------------
	-- Effet 2 : Indestructible au combat
	---------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(s.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	---------------------------------------
	-- Effet 3 : Boost ATK/DEF Mort-Vivant
	---------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.mvfilter)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(s.boost)
	c:RegisterEffect(e3)

	local e3b=e3:Clone()
	e3b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3b)

	---------------------------------------
	-- Effet 4 : Invo Spé depuis le Cimetière
	---------------------------------------
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)

	---------------------------------------
	-- Effet 5 : Compteurs quand quitte le terrain
	---------------------------------------
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetTarget(s.lvtg)
	e5:SetOperation(s.lvop)
	c:RegisterEffect(e5)
end

---------------------------------------
-- Effet 1 : condition invoc lien
---------------------------------------
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(s.counter_id,1)
end

---------------------------------------
-- Effet 2 : indestructible battle
---------------------------------------
function s.indcon(e)
	return e:GetHandler():GetCounter(s.counter_id)>0
end

---------------------------------------
-- Effet 3 : boost ATK/DEF
---------------------------------------
function s.mvfilter(e,c)
	return c:IsSetCard(s.archetype)
end

function s.boost(e,c)
	return e:GetHandler():GetCounter(s.counter_id)*300
end

---------------------------------------
-- Effet 4 : coût – retirer 2 Compteurs Âme
---------------------------------------
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsCanRemoveCounter(tp,LOCATION_ONFIELD,0,s.counter_id,2,REASON_COST)
	end
	Duel.RemoveCounter(tp,LOCATION_ONFIELD,0,s.counter_id,2,REASON_COST)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(s.archetype)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	if zone==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end

---------------------------------------
-- Effet 5 : placer 2 Compteurs Âme
---------------------------------------
function s.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(s.archetype)
end

function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_MZONE,0,1,nil)
	end
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.ctfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		g:GetFirst():AddCounter(s.counter_id,2)
	end
end
