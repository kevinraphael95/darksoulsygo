--Prêtre du Pardon
function c900000115.initial_effect(c)
	-- Annuler un monstre DARK et le rendre LIGHT
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(900000115,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c900000115.target)
	e1:SetOperation(c900000115.operation)
	c:RegisterEffect(e1)

	-- Effet quand détaché comme matériel Xyz
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(900000115,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DETACH_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c900000115.detachtg)
	e2:SetOperation(c900000115.detachop)
	c:RegisterEffect(e2)
end

-- Cible monstre DARK que tu contrôles
function c900000115.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end

function c900000115.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c900000115.filter(chkc) end
	if chk==0 then
		return Duel.IsExistingTarget(c900000115.filter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c900000115.filter,tp,LOCATION_MZONE,0,1,1,nil)
end

-- Annulation + changement d'attribut
function c900000115.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- Annuler effets
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)

		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)

		-- Devient LUMIÈRE
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e3:SetValue(ATTRIBUTE_LIGHT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end

-- Cible monstre adverse face recto
function c900000115.detachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then
		return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end

-- Annulation effets adverses
function c900000115.detachop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)

		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end
