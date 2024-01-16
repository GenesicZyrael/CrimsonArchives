 --CCG: Zefra Fusion
function c27200012.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_FREE_CHAIN)
		--e1:SetCountLimit(1,{id,0})
		e1:SetTarget(c27200012.target)
		e1:SetOperation(c27200012.activate)
	c:RegisterEffect(e1)
	--Return to deck
	local e2=Effect.CreateEffect(c)
		e2:SetCategory(CATEGORY_TODECK)
		e2:SetDescription(aux.Stringid(27200012,1))
		e2:SetType(EFFECT_TYPE_IGNITION)
		e2:SetRange(LOCATION_GRAVE)
		e2:SetCountLimit(1,{id,1})
		e2:SetCost(c27200012.thcost)
		e2:SetTarget(c27200012.thtg)
		e2:SetOperation(c27200012.thop)
	c:RegisterEffect(e2)
end

function c27200012.filter1(c,e)
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
function c27200012.exfilter0(c)
	return c:IsSetCard(0xC4) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
function c27200012.exfilter1(c,e)
	return c:IsSetCard(0xC4) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
function c27200012.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function c27200012.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=2
end
function c27200012.cfilter(c)
	return c:GetSummonLocation()==LOCATION_EXTRA
end
function c27200012.filter0(c)
	return c:IsSetCard(0xC4) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
function c27200012.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsAbleToGrave,nil)
		local sg=Duel.GetMatchingGroup(c27200012.exfilter0,tp,LOCATION_EXTRA,0,nil)
		if sg:GetCount()>0 then
			mg1:Merge(sg)
			Auxiliary.FCheckAdditional=c27200012.fcheck
		end
		if Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,2,nil,0xc4) 
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			local mg2=Duel.GetMatchingGroup(c27200012.filter0,tp,LOCATION_DECK,0,nil)
			mg1:Merge(mg2)
		end
		local res=Duel.IsExistingMatchingCard(c27200012.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		Auxiliary.FCheckAdditional=nil
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(c27200012.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c27200012.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(c27200012.filter1,nil,e)
	local exmat=false
	local sg=Duel.GetMatchingGroup(c27200012.exfilter1,tp,LOCATION_EXTRA,0,nil,e)
	if sg:GetCount()>0 then
		mg1:Merge(sg)
		exmat=true
	end
	if Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,2,nil,0xc4) 
	and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local mg3=Duel.GetMatchingGroup(c27200012.filter0,tp,LOCATION_DECK,0,nil)
		mg1:Merge(mg3)
	end
	if exmat then Auxiliary.FCheckAdditional=c27200012.fcheck end
	local sg1=Duel.GetMatchingGroup(c27200012.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	Auxiliary.FCheckAdditional=nil
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(c27200012.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		mg1:RemoveCard(tc)
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then Auxiliary.FCheckAdditional=c27200012.fcheck end
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			Auxiliary.FCheckAdditional=nil
			tc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end

function c27200012.thfilter(c)
	return c:IsFaceup() 
		and c:IsSetCard(0xc4) 
		and c:IsType(TYPE_PENDULUM)
		and c:IsAbleToRemoveAsCost()
end
function c27200012.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(c27200012.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c27200012.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c27200012.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return e:GetHandler():IsAbleToDeck()
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function c27200012.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,2,REASON_COST)
	end
end