 --Constellar Convergence
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon by effect
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.listed_series={0x53}
function s.counterfilter(c)
	return c:IsSetCard(0x53)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,1),nil)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x53)
end
function s.xyzfilter(c,mg)
	return c:IsSetCard(0x53) and c:IsXyzSummonable(nil,mg)
end
function s.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x53)
end
function s.mfilter(c)
	return c:IsSetCard(0x53) and c:IsCanBeXyzMaterial()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
    local g=Duel.GetMatchingGroup(Card.IsCanBeXyzMaterial,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)then 
		local g2=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_DECK,0,nil)
		g:Merge(g2)
	end
    if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.ntcon(e,c,minc,zone)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc==0 and c:GetLevel()>4 and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
		and Duel.GetFieldGroupCount(tp-1,LOCATION_MZONE,0)~=0 and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local hg=Duel.GetMatchingGroup(Card.IsCanBeXyzMaterial,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	if (Duel.GetFieldGroupCount(tp-1,LOCATION_MZONE,0)~=0) and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)) then 
		local hg2=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_DECK,0,nil)
		hg:Merge(hg2)
	end
    local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,hg)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sc=g:Select(tp,1,1,nil):GetFirst()
        Duel.XyzSummon(tp,sc,nil,hg,1,99)
    end
end