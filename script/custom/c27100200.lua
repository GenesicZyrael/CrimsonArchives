--Steelswarm Hercules - Infestation Wave
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_LSWARM),2)	
	--immunity
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.matcheck)
	c:RegisterEffect(e1)
	--send 1 monster and change monsters to face-down
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_HANDES+CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetTarget(s.targ)
	e2:SetOperation(s.ope)
	c:RegisterEffect(e2)	
	--Destruction replacement
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.desreptg)
	c:RegisterEffect(e3)	
end

s.listed_series={SET_STEELSWARM,SET_INFESTATION}
--
function s.matfilter(c)
	return c:IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.matcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(s.matfilter,1,nil) then
		--Unaffected by activated effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(s.immval)
		c:RegisterEffect(e1)	
	end
end
function s.immval(e,te)
	return te:GetOwner()~=e:GetHandler() and te:IsActiveType(TYPE_MONSTER) and e:GetHandlerPlayer() ~= te:GetHandlerPlayer()
		and te:IsActivated() and te:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
--
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.filter(c)
	return not c:IsPublic()
end
function s.targ(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	local dg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_HANDES,dg,1,tp,LOCATION_HAND+LOCATION_MZONE)
	else
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.ope(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	if #g1>0 and Duel.SendtoGrave(g1,REASON_EFFECT+REASON_DISCARD)~=0 then
		local g2=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
		if #g2>0 then
			Duel.ChangePosition(g2,POS_FACEDOWN_DEFENSE)
			local og=Duel.GetOperatedGroup()
			local tc=og:GetFirst()
			for tc in aux.Next(og) do
				--Cannot change their battle positions
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(3313)
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end
---
function s.repfilter(c)
	return c:IsAbleToRemove() and aux.SpElimFilter(c,true)
		-- and (c:IsSetCard(SET_STEELSWARM) or c:IsSetCard(SET_INFESTATION))
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
	return not c:IsReason(REASON_REPLACE)
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_GRAVE,0,1,c) end
	local tg=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil)
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g1=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_GRAVE,0,1,1,c)
		if Duel.Remove(g1:GetFirst(),POS_FACEUP,REASON_EFFECT) and tg 
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then 
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)	
			local g2=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
			if #g2>0 then
				Duel.SendtoDeck(g2,nil,1,REASON_EFFECT)
			end	
		end
		return true
	else return false end
end
