 --Zefra Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,nil,s.matfilter,s.fextra,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	c:RegisterEffect(e1)
	--reutrn to deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ZEFRA}
function s.matfilter(c)
	return ((c:IsLocation(LOCATION_HAND) or c:IsOnField()) and c:IsAbleToGrave()) 
		or (c:IsLocation(LOCATION_EXTRA) and c:IsSetCard(SET_ZEFRA) and c:IsAbleToGrave())
end
function s.exfilter(c)
	return c:IsSetCard(SET_ZEFRA) and c:IsAbleToGrave()
end
function s.fextra(e,tp,mg)
	local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	local mg1=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_EXTRA,0,nil)
	if (tc1 and tc2 and tc1:IsSetCard(SET_ZEFRA) and tc2:IsSetCard(SET_ZEFRA)) then 
		local mg2=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
		mg1:Merge(mg2)
		return mg1
	end
	return mg1
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end
function s.rmfilter(c,e)
	return c:IsAbleToRemoveAsCost() and c:IsSetCard(SET_ZEFRA) and c:IsPublic() and e:GetHandler():IsAbleToDeck()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_EXTRA,0,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_EXTRA,0,1,1,nil,e)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end