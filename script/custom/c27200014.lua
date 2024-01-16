 --CCG: Zefratorah Metaltron
-- [ Pendulum Effect ]
-- If a "Zefra" card(s) is added to your Extra Deck face-up: Add 1 of 
-- those cards to your hand, and if you do, change this card's Pendulum Scale 
-- to 1 or 7 until the End Phase. 
-- You can only use each effect of "Zefratorah Metaltron" once per turn.
-- ----------------------------------------
-- [ Lore]
-- The ten Pyroxenes shone once again and radiated with a great power that it tore the night sky asunder. 
-- The Chosen 10, with their renewed strength, rallied together once more. The pieces of the fallen titan
-- Zefraath was soon engulfed with a stream of light and began reforming once again. In its place rose a 
-- titan who wields the hidden Pyroxene of Enlightenment, the inherited power of the Stars, the nine dragons,
-- the mirrors of resurrection, and the embodiment of the wishes of the world, the eleventh Zefra, Zefratorah Metaltron!
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--tohand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--change scale
	-- local e3=Effect.CreateEffect(c)
	-- e3:SetDescription(aux.Stringid(id,0))
	-- e3:SetType(EFFECT_TYPE_IGNITION)
	-- e3:SetRange(LOCATION_PZONE)
	-- e3:SetCountLimit(1,{id,1})
	-- e3:SetTarget(s.sctg)
	-- e3:SetOperation(s.scop)
	-- c:RegisterEffect(e3)
end
function s.thfilter(c,tp)
	return c:IsFaceup() 
		and c:IsControler(tp) 
		and c:IsLocation(LOCATION_EXTRA) 
		and c:IsSetCard(0xc4)
		-- and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thfilter,1,nil,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(s.thfilter,nil,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local scale=5
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local rg=g:Select(tp,1,1,nil)
	if rg:GetCount()>0 and Duel.SendtoHand(rg,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,rg)
		if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			local off=1
			local ops={}
			local opval={}
			if c:GetLeftScale()~=1 then
				ops[off]=aux.Stringid(id,3)
				opval[off-1]=1
				off=off+1
			end
			if c:GetLeftScale()~=7 then
				ops[off]=aux.Stringid(id,4)
				opval[off-1]=2
				off=off+1
			end
			if off==1 then return end
			local op=Duel.SelectOption(tp,table.unpack(ops))
			if opval[op]==1 then
				scale=1
			elseif opval[op]==2 then
				scale=7
			else 
				scale=5
			end
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LSCALE)
			e1:SetValue(scale)
			e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CHANGE_RSCALE)
			e2:SetValue(scale)
			c:RegisterEffect(e2)
		end
	end
end
function s.scfilter(c,pc)
	return c:IsType(TYPE_PENDULUM) 
		and c:IsSetCard(0xc4) 
		and not c:IsForbidden()
		-- and c:GetLeftScale()~=pc:GetLeftScale()
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler()) 
	end
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local scale=1
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local g=Duel.SelectMatchingCard(tp,s.scfilter,tp,LOCATION_DECK,0,1,1,nil,c)
	local tc=g:GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 then
		if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			scale=7
		else
			scale=1
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(scale)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		e2:SetValue(scale)
		c:RegisterEffect(e2)
	end
end
