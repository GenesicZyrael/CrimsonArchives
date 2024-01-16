-- Gem-Knight Zefranite
local s,id=GetID()
local params = {nil,aux.OR(aux.FilterBoolFunction(Card.IsSetCard,SET_GEM_KNIGHT),aux.FilterBoolFunction(Card.IsSetCard,SET_ZEFRA))}
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--splimit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)
	-- Allow cards in the Extra Deck and Pendulum Zones as fusion materials
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e3:SetCountLimit(1,{id,0})
	e3:SetRange(LOCATION_PZONE)
	e3:SetTargetRange(LOCATION_PZONE+LOCATION_DECK,0)
	e3:SetTarget(s.eeftg)
	e3:SetCondition(s.eefcon)
	e3:SetOperation(s.eefope)
	e3:SetLabelObject({s.extrafil_replacement})
	e3:SetValue(s.eefval)
	c:RegisterEffect(e3)
	--Pendulum Set
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation(Fusion.SummonEffTG(table.unpack(params)),Fusion.SummonEffOP(table.unpack(params))))
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(s.condition)
	c:RegisterEffect(e5)
	--Material check
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
	e6:SetRange(LOCATION_PZONE)
	e6:SetCode(EFFECT_MATERIAL_CHECK)
	e6:SetValue(s.valcheck)
	c:RegisterEffect(e6)
end
s.listed_series={SET_GEM_KNIGHT,SET_ZEFRA}
-- {Pendulum Summon Restriction: Zefra & Gem-Knight Monsters}
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(SET_GEM_KNIGHT) or c:IsSetCard(SET_ZEFRA) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- {Pendulum Effect: Use cards in Pendulum Zones or 1 Gem-Knight and Zefra from Deck as Fusion Materials}
function s.mtfilter(c)
	return c:HasFlagEffect(id)
end
function s.valcheck(e,c)
	local tp=e:GetHandler():GetOwner()
	if Duel.GetFlagEffect(tp,id)~=0 then return false end
	if c:GetMaterial():IsExists(s.mtfilter,1,nil) then
		s.eefval(e,c)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
function s.eeftg(e,c)
	return c:IsFaceup() and c:IsCanBeFusionMaterial()
end
function s.eefcon(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandler():GetOwner()
	if Duel.GetFlagEffect(tp,id)~=0 then return false end
	return true
end
function s.extrafil_repl_filter(c,tp)
	if Duel.GetFlagEffect(tp,id)~=0 then return false end
	c:RegisterFlagEffect(id,RESET_EVENT+0x4fe0000+RESET_PHASE+PHASE_END,0,1)
	return c:IsMonster() and c:IsCanBeFusionMaterial() 
		and ( c:IsSetCard(SET_GEM_KNIGHT) or c:IsSetCard(SET_ZEFRA) )
end
function s.extrafil_replacement(e,tp,mg)
	local tp=e:GetHandler():GetOwner()
	local g=Duel.GetMatchingGroup(s.extrafil_repl_filter,tp,LOCATION_DECK,0,nil,tp)
	return g,s.fcheck_replacement
end
function s.fcheck_replacement(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.eefope(e,fc,tp,rg)
	local tp=e:GetHandler():GetOwner()
	if Duel.GetFlagEffect(tp,id)~=0 then return false end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	Duel.SendtoGrave(fc:GetMaterial(),REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
end
function s.eefval(e,c)
	local tp=e:GetHandler():GetOwner()
	if Duel.GetFlagEffect(tp,id)~=0 then return 0 end
	return 1
end
-- {Monster Effect: Place in Pendulum Zone, then Fusion Summon if possible}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return (Duel.CheckLocation(tp,LOCATION_PZONE,0) 
			or Duel.CheckLocation(tp,LOCATION_PZONE,1)) 
	end	
end
function s.operation(fustg,fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if not e:GetHandler():IsRelateToEffect(e) then return end
		if Duel.SelectYesNo(tp,aux.Stringid(id,2))
			and ( Duel.CheckLocation(tp,LOCATION_PZONE,0) 
			   or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then 
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
		if fustg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			fusop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end