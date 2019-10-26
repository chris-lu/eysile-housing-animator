local EHA = EysilesHousingAnimator

EHAAnimation = {}

-- Let's not use real OOP as serializeing them will lead to recursive save
function EHAAnimation:new(o)
  local o = o or {}
  local a = { trigger = 0, plays = false, loop = false, bounce = false, rotate = true, radius = 0, animation = 'transition', ease = 'inoutquad', keyframe = 1, frame = 0, duration = 25, speed = 1, furnitures = {}, durations = {}, chain = "" }
  
  for k, v in pairs(o) do
    a[k] = v
  end
  
  return a
end

function EHAAnimation:reset(a) 
  EHA.d("Reset playing")
  a.frame = 0;
  a.keyframe = 1
  for furnitureId, f in pairs(a.furnitures) do
    local l = f[a.keyframe]
    if l then
      HousingEditorRequestChangePositionAndOrientation(StringToId64(l.id), l.x, l.y, l.z, l.pitch, l.yaw, l.roll)
      HousingEditorRequestChangeState( StringToId64(l.id), l.state )
    end
  end
  a.speed = math.abs(a.speed)
end

function EHAAnimation:stop(a) 
  EHA.d("Stop playing")
  a.plays = false 
  if a.chain then
    if a.speed > 0 then 
      EHA.animationStart(a.chain)
    else 
      EHA.animationToggle(a.chain)
    end
  end
end

function EHAAnimation:toggle(a)
  EHA.d("Toggle playing")
  -- Be sure toggeling does not stop just at start
  if a.plays == false and a.keyframe == 1 and a.frame == 0 then
    a.speed = math.abs(a.speed)
  elseif a.plays == false and a.keyframe ~= 1  then
    a.speed = - math.abs(a.speed)
  else
    a.speed = - a.speed 
  end
  
  a.plays = true
end

function EHAAnimation:start(a)
  EHA.d("Start playing")
  a.speed = math.abs(a.speed)
  a.frame = 0
  a.keyframe = 1
  a.plays = true
end

function EHAAnimation:play(a)
  local fanim = EHAAnimation["do" .. a.animation]
  
  if a.plays and fanim then
    local maxKeyframe = 1
    local duration = EHAAnimation:getDuration(a)
    
    for furnitureId, f in pairs(a.furnitures) do
      if a.animation == 'transition' and f[a.keyframe] and f[a.keyframe + 1] then
        maxKeyframe = math.max(maxKeyframe, #f)
        
        fanim(fanim, a, f[a.keyframe], f[a.keyframe + 1], duration)
      elseif a.animation == 'rotate' then
        fanim(fanim, a, f[a.keyframe], duration)
      end
    end
  
    a.frame = a.frame + a.speed
  
  -- We need to "play" all frames, aven the last one.
    if a.frame > duration then 
      a.frame = duration
      -- Another keyframe available ? Continue the animation
      if a.keyframe + 1 < maxKeyframe then 
        a.keyframe = a.keyframe + 1
        a.frame = 1
      elseif a.loop then 
      -- if loop, restart from scratch
        EHAAnimation:start(a)
      elseif a.bounce then 
        EHAAnimation:toggle(a)
      else
        EHAAnimation:stop(a)
      end
    elseif a.frame < 0 then 
      a.frame = 0
      -- A previous keyframe available ? Continue the animation
      if a.keyframe - 1 >= 1 then 
        a.keyframe = a.keyframe - 1 
        a.frame = EHAAnimation:getDuration(a)
      elseif a.bounce then 
        EHAAnimation:toggle(a)
      else 
        EHAAnimation:stop(a)
      end  
    end
  end
end

function EHAAnimation:setParameter(a, param, value, position)
  if param ~= nil and value ~= nil and a[param] ~= nil then 
    if type(a[param])  == "number" then
      a[param] = tonumber(value)
    elseif type(a[param])  == "boolean" then
      a[param] = value ~= "0"
    elseif type(a[param])  == "table" and position ~= nil then
      EHAAnimation:setParameter(a[param], tonumber(position), value)
    else
      a[param] = value
    end
    
    d("Setting value of " .. param .. " to " .. tostring(a[param]))
    return a[param]
  else 
    d("Cannot set value of " .. param .. " to " .. tostring(value))
  end
end

function EHAAnimation:getDuration(a)
  if a.durations and a.durations[a.keyframe] and a.durations[a.keyframe] ~= 0 then
    return math.max(1, a.durations[a.keyframe])
  else
    return math.max(1, a.duration)
  end
end

function EHAAnimation:fixKeyframesDurations(a)
  local durations = {}
  local maxkeyframe = 0

  for furnitureId, f in pairs(a.furnitures) do
    maxkeyframe = math.max(maxkeyframe, #f)
  end

  for i=1,maxkeyframe do
    durations[i] = a.durations[i] or 0
  end

  a.durations = durations
  d("Fixing durations.")
end

function EHAAnimation:addFurnitures(a, furnitures)
  -- Group by furnitureId
  
  for _, f in ipairs(furnitures) do
    local list = a.furnitures[f.id] or {}
    list[#list + 1] = f
    a.furnitures[f.id] = list
  end

  EHAAnimation:fixKeyframesDurations(a)
end

function EHAAnimation:setFurniture(a, pos, furniture)
  local list = a.furnitures[furniture.id] or {}
  list[pos] = furniture
  a.furnitures[furniture.id] = list

  EHAAnimation:fixKeyframesDurations(a)
end

function EHAAnimation:removeFurnitures(a, furnitureId)
  a.furnitures[furnitureId] = nil
end

function EHAAnimation:dorotate(a, furniture)

  local mx = math.cos(math.rad(a.frame)) * a.radius
  local mz = math.sin(math.rad(a.frame)) * a.radius
  
  -- a.speed = 2 * math.pi / 100;
  a.frame = (a.frame + a.speed) % 360

  HousingEditorRequestChangePositionAndOrientation( StringToId64(furniture.id), furniture.x + mx, furniture.y, furniture.z + mz, furniture.pitch, furniture.yaw - math.rad(a.frame), furniture.roll )
end

function EHAAnimation:dotransition(a, furnitureFrom, furnitureTo, duration)
  local f = EHAMath['ease' .. a.ease]
  
  -- local speed = math.sqrt(math.pow(furnitureTo.x - furnitureFrom.x, 2) + math.pow(furnitureTo.y - furnitureFrom.y, 2)+math.pow(furnitureTo.z - furnitureFrom.z, 2)) / duration
  -- EHA.d("Speed: " .. tostring(speed))
  
  if not a.rotate then
    HousingEditorRequestChangePositionAndOrientation(StringToId64(furnitureFrom.id), 
      f(a.frame, furnitureFrom.x, furnitureTo.x - furnitureFrom.x, duration),
      f(a.frame, furnitureFrom.y, furnitureTo.y - furnitureFrom.y, duration),
      f(a.frame, furnitureFrom.z, furnitureTo.z - furnitureFrom.z, duration),
      furnitureFrom.pitch,
      furnitureFrom.yaw,
      furnitureFrom.roll
    )
  else 
    HousingEditorRequestChangePositionAndOrientation (StringToId64(furnitureFrom.id), 
      f(a.frame, furnitureFrom.x, furnitureTo.x - furnitureFrom.x, duration),
      f(a.frame, furnitureFrom.y, furnitureTo.y - furnitureFrom.y, duration),
      f(a.frame, furnitureFrom.z, furnitureTo.z - furnitureFrom.z, duration),
      f(a.frame, furnitureFrom.pitch, EHAMath.normalize(furnitureTo.pitch - furnitureFrom.pitch), duration),
      f(a.frame, furnitureFrom.yaw,   EHAMath.normalize(furnitureTo.yaw   - furnitureFrom.yaw),   duration),
      f(a.frame, furnitureFrom.roll,   EHAMath.normalize(furnitureTo.roll - furnitureFrom.roll),  duration)
    )
  end
  
  if(a.frame == 0) then
    EHAInteract.activate(a, furnitureFrom.state)
  elseif(furnitureFrom.state ~= furnitureTo.state and a.frame == duration) then
    EHAInteract.activate(a, furnitureTo.state)
  end
  
end
