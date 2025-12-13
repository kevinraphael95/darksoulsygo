--Le calice du seigneur
local s2,id2=GetID()
function s2.initial_effect(c)
	-- Rituel exact Niveau 10 pour 900000104
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s2.target)
	e1:SetOperation(s2.activate)
	c:RegisterEffect(e1)
end

function s2.ritfilter(c,e,tp)
	return c:IsCode(900000104)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end

function s2.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s2.ritfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s2.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,s2.ritfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=tg:GetFirst()
	if not tc then return end

	local mg=Duel.GetRitualMaterial(tp)
	mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
	if #mg==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	-- IMPORTANT : wrapper pour GetRitualLevel afin d'avoir le paramètre rc (tc)
	local lvfunc = function(c) return c:GetRitualLevel(tc) end
	local mat=mg:SelectWithSumEqual(tp,lvfunc,10,tc)
	if not mat or #mat==0 then return end

	tc:SetMaterial(mat)
	Duel.ReleaseRitualMaterial(mat)
	Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
	tc:CompleteProcedure()
end
