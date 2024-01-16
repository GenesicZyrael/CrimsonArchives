 --CCG: Zefra Cycle
function c27200013.initial_effect(c)
	--Ritual Summon
    local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_FREE_CHAIN)
		--e1:SetCountLimit(1,{id,0})
		e1:SetTarget(c27200013.target)
		e1:SetOperation(c27200013.operation)
    c:RegisterEffect(e1) 
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)
	--Return to deck
	local e2=Effect.CreateEffect(c)
		e2:SetCategory(CATEGORY_TODECK)
		e2:SetDescription(aux.Stringid(27200013,1))
		e2:SetType(EFFECT_TYPE_IGNITION)
		e2:SetRange(LOCATION_GRAVE)
		e2:SetCountLimit(1,{id,1})
		e2:SetCost(c27200013.thcost)
		e2:SetTarget(c27200013.thtg)
		e2:SetOperation(c27200013.thop)
	c:RegisterEffect(e2)
end
function c27200013.ritual_filter(c)
	return c:IsType(TYPE_RITUAL)
end
function c27200013.filter(c,e,tp,m,ft)
	if not c27200013.ritual_filter(c) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m:Filter(Card.IsCanBeRitualMaterial,c,c)
	if c:IsCode(21105106) then return c:ritual_custom_condition(mg,ft) end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,nil)
	end
	if ft>0 then
		return mg:CheckWithSumEqual(Card.GetRitualLevel,c:GetLevel(),1,99,c)
	else
		return mg:IsExists(c27200013.mfilterf,1,nil,tp,mg,c)
	end
end
function c27200013.mfilterf(c,tp,mg,rc)
	if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 then
		Duel.SetSelectedCard(c)
		return mg:CheckWithSumEqual(Card.GetRitualLevel,rc:GetLevel(),0,99,rc)
	else return false end
end
function c27200013.exfilter0(c)
	return c:IsSetCard(0xc4) 
		and c:GetLevel()>=1 
		and c:IsAbleToGrave()
end
function c27200013.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp)
		local sg=Duel.GetMatchingGroup(c27200013.exfilter0,tp,LOCATION_EXTRA,0,nil)
		mg:Merge(sg)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,2,nil,0xc4) 
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			return ft>-1 
				and Duel.IsExistingMatchingCard(c27200013.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,mg,ft)
		else
			return ft>-1 
				and Duel.IsExistingMatchingCard(c27200013.filter,tp,LOCATION_HAND,0,1,nil,e,tp,mg,ft)
		end
		return ft>-1 
			and res
	end
end
function c27200013.operation(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetRitualMaterial(tp)
	local sg=Duel.GetMatchingGroup(c27200013.exfilter0,tp,LOCATION_EXTRA,0,nil)
	mg:Merge(sg)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=nil
	if Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,2,nil,0xc4) 
	and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		tg=Duel.SelectMatchingCard(tp,c27200013.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,mg,ft)
	else
		tg=Duel.SelectMatchingCard(tp,c27200013.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp,mg,ft)
	end
	local tc=tg:GetFirst()

	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc:IsCode(21105106) then
			tc:ritual_custom_operation(mg)
			local mat=tc:GetMaterial()
			Duel.ReleaseRitualMaterial(mat)
		else
			if tc.mat_filter then
				mg=mg:Filter(tc.mat_filter,nil)
			end
			local mat=nil
			if ft>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
				mat=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,tc:GetLevel(),1,99,tc)
			else
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
				mat=mg:FilterSelect(tp,c27200013.mfilterf,1,1,nil,tp,mg,tc)
				Duel.SetSelectedCard(mat)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
				local mat2=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,tc:GetLevel(),0,99,tc)
				mat:Merge(mat2)
			end
			tc:SetMaterial(mat)
			local sg1=mat:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
			Duel.ReleaseRitualMaterial(mat)
			Duel.SendtoGrave(sg1,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		end
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end

function c27200013.thfilter(c)
	return c:IsFaceup() 
		and c:IsSetCard(0xc4) 
		and c:IsType(TYPE_PENDULUM) 
		and c:IsAbleToRemoveAsCost()
end
function c27200013.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(c27200013.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c27200013.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c27200013.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return e:GetHandler():IsAbleToDeck()
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function c27200013.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,2,REASON_COST)
	end
end