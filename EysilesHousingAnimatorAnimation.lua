local EHA = EysilesHousingAnimator
EHAAnimation = {}

-- Let's not use real OOP as serializeing them will lead to recursive save
function EHAAnimation:new(o)
  local o = o or {}
  local a = { collectible = 0, plays = false, loop = false, bounce = false, rotate = true, radius = 0, animation = 'transition', ease = 'inoutquad', keyframe = 1, frame = 0, duration = 25, speed = 1, furnitures = {}, durations = {}, chain = "" }
  
  for k, v in pairs(o) do
    a[k] = v
  end
  
  return a
end

-- https://esoitem.uesp.net/viewlog.php?record=collectibles
function EHAAnimation.collectible(animation)
  if animation.collectible and animation.collectible ~= 0 then
    EHA.d("Triggerring collectible " .. animation.collectible)
    UseCollectible(animation.collectible)
  end
  
  return animation
end

function EHAAnimation.animationStart(name)
  if(EHA.animations[name]) then
    EHAAnimation.start(EHAAnimation.collectible(EHA.animations[name]))
  end
end

function EHAAnimation.animationToggle(name)
  if(EHA.animations[name]) then
    EHAAnimation.toggle(EHAAnimation.collectible(EHA.animations[name]))
  end
end

function EHAAnimation.animationDelete(name)
  EHA.animations[name] = nil 
  d("Animation: " .. name .. " deleted")
end

function EHAAnimation.animationCreate(name, number)
  local fs = {}
  local i = number
  for _, f in ipairs( EHA.furnitures ) do
      fs[i] = f
      i = i - 1

      if i < 1 then break end
  end
  local anim = EHAAnimation:new()
  EHAAnimation.addFurnitures(anim, fs)
  EHAAnimation.reset(anim)
  EHA.animations[name] = anim
  
  d("Saved animation to " .. name .. " with " .. #fs .. " keyframes")  
end

function EHAAnimation.animationReplaceKeyframe(name, number, pos)
  local i = number
  for _, f in ipairs( EHA.furnitures ) do
      EHAAnimation.setFurniture(EHA.animations[name], pos, f)
      i = i - 1
    pos = pos + 1
      
      if i < 1 then break end
  end
  
  d("Replaced " .. number .. " keyframe in " .. name)  
end

function EHAAnimation.reset(a) 
  EHA.d("Reset playing")
  a.frame = 0;
  a.keyframe = 1
  for furnitureId, f in pairs(a.furnitures) do
    local l = f[a.keyframe]
    if l then
      HousingEditorRequestChangePositionAndOrientation(StringToId64(l.id), l.x, l.y, l.z, l.pitch, l.yaw, l.roll)
      EHAInteract.setState( l.id, l.state )
    end
  end
  a.speed = math.abs(a.speed)
end

function EHAAnimation.random(a) 
  EHA.d("Randomize initial objects")
  local shuffled = {}
  
  -- Randomize positions
  for furnitureId, f in pairs(a.furnitures) do
    -- Need a deep copy here
    local l = EHA.deepcopy(f[1])
	  local pos = math.random(1, #shuffled+1)
	  table.insert(shuffled, pos, l)
  end

  -- Reaffect coordinates
  local i = 1;
  for furnitureId, f in pairs(a.furnitures) do
    local l = f[1]
    if l then
      l.x, l.y, l.z, l.pitch, l.yaw, l.roll = shuffled[i].x, shuffled[i].y, shuffled[i].z, shuffled[i].pitch, shuffled[i].yaw, shuffled[i].roll
    end
    
    i = i + 1
  end
  
  -- Reset scene
  EHAAnimation.reset(a)
end

function EHAAnimation.stop(a, force) 
  EHA.d("Stop playing")
  a.plays = false 
  if not force and a.chain then
    if a.speed > 0 then 
      EHAAnimation.animationStart(a.chain)
    else 
      EHAAnimation.animationToggle(a.chain)
    end
  end
end

function EHAAnimation.toggle(a)
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

function EHAAnimation.start(a)
  EHA.d("Start playing")
  a.speed = math.abs(a.speed)
  a.frame = 0
  a.keyframe = 1
  a.plays = true
end

function EHAAnimation.play(a)
  local fanim = EHAAnimation["do" .. a.animation]
  
  if a.plays and fanim then
    local maxKeyframe = 1
    local duration = EHAAnimation.getDuration(a)
    
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
        EHAAnimation.start(a)
      elseif a.bounce then 
        EHAAnimation.toggle(a)
      else
        EHAAnimation.stop(a)
      end
    elseif a.frame < 0 then 
      a.frame = 0
      -- A previous keyframe available ? Continue the animation
      if a.keyframe - 1 >= 1 then 
        a.keyframe = a.keyframe - 1 
        a.frame = EHAAnimation.getDuration(a)
      elseif a.bounce then 
        EHAAnimation.toggle(a)
      else 
        EHAAnimation.stop(a)
      end  
    end
  end
end

function EHAAnimation.setParameter(a, param, value, position)
  if param ~= nil and value ~= nil and a[param] ~= nil then 
    if type(a[param])  == "number" then
      a[param] = tonumber(value)
    elseif type(a[param])  == "boolean" then
      a[param] = value ~= "0"
    elseif type(a[param])  == "table" and position ~= nil then
      EHAAnimation.setParameter(a[param], tonumber(position), value)
    else
      a[param] = value
    end
    
    d("Setting value of " .. param .. " to " .. tostring(a[param]))
    return a[param]
  else 
    d("Cannot set value of " .. param .. " to " .. tostring(value))
  end
end

function EHAAnimation.getDuration(a)
  if a.durations and a.durations[a.keyframe] and a.durations[a.keyframe] ~= 0 then
    return math.max(1, a.durations[a.keyframe])
  else
    return math.max(1, a.duration)
  end
end

function EHAAnimation.fixKeyframesDurations(a)
  local durations = {}
  local maxkeyframe = 0

  for furnitureId, f in pairs(a.furnitures) do
    maxkeyframe = math.max(maxkeyframe, #f)
  end

  for i=1,maxkeyframe do
    durations[i] = a.durations[i] or 0
  end

  a.durations = durations
  EHA.d("Fixing durations.")
end

function EHAAnimation.addFurnitures(a, furnitures)
  -- Group by furnitureId
  
  for _, f in ipairs(furnitures) do
    local list = a.furnitures[f.id] or {}
    list[#list + 1] = f
    a.furnitures[f.id] = list
  end

  EHAAnimation.fixKeyframesDurations(a)
end

function EHAAnimation.setFurniture(a, pos, furniture)
  local list = a.furnitures[furniture.id] or {}
  list[pos] = furniture
  a.furnitures[furniture.id] = list

  EHAAnimation.fixKeyframesDurations(a)
end

function EHAAnimation.removeFurnitures(a, furnitureId)
  a.furnitures[furnitureId] = nil
end

function EHAAnimation.dorotate(a, furniture)

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
  
  if furnitureFrom.duration ~= nil then
    duration = furnitureFrom.duration
  end
  
  local frame = math.min(a.frame, duration)
  
  if not a.rotate then
    HousingEditorRequestChangePositionAndOrientation(StringToId64(furnitureFrom.id), 
      f(frame, furnitureFrom.x, furnitureTo.x - furnitureFrom.x, duration),
      f(frame, furnitureFrom.y, furnitureTo.y - furnitureFrom.y, duration),
      f(frame, furnitureFrom.z, furnitureTo.z - furnitureFrom.z, duration),
      furnitureFrom.pitch,
      furnitureFrom.yaw,
      furnitureFrom.roll
    )
  else 
    HousingEditorRequestChangePositionAndOrientation (StringToId64(furnitureFrom.id), 
      f(frame, furnitureFrom.x, furnitureTo.x - furnitureFrom.x, duration),
      f(frame, furnitureFrom.y, furnitureTo.y - furnitureFrom.y, duration),
      f(frame, furnitureFrom.z, furnitureTo.z - furnitureFrom.z, duration),
      f(frame, furnitureFrom.pitch, EHAMath.normalize(furnitureTo.pitch - furnitureFrom.pitch), duration),
      f(frame, furnitureFrom.yaw,   EHAMath.normalize(furnitureTo.yaw   - furnitureFrom.yaw),   duration),
      f(frame, furnitureFrom.roll,   EHAMath.normalize(furnitureTo.roll - furnitureFrom.roll),  duration)
    )
  end
  
  if(frame == 0) then
    EHAInteract.setState(furnitureFrom.id, furnitureFrom.state)
  elseif(furnitureFrom.state ~= furnitureTo.state and frame == duration) then
    EHAInteract.setState(furnitureTo.id, furnitureTo.state)
  end
  
end

function EHAAnimation.OnUpdate() 
  if GetHousingEditorMode() ~= HOUSING_EDITOR_MODE_DISABLED then
    return
  end

  for name, a in pairs( EHA.animations ) do    
    if a.plays then 
      EHAAnimation.play(a)
    end
  end
end

function EHAAnimation.SlashCommand( options )
  local animations = {}
  local name = options[3]
  
  if name == "all" then 
    animations = EHA.animations
  elseif EHA.animations[name] then
    animations[name] = EHA.animations[name]
  end
    
  -- Stack commands
  if options[2] == "create"  then EHAAnimation.animationCreate(name, tonumber(options[4]) or 2) end
  if options[2] == "replace" then EHAAnimation.animationReplaceKeyframe(name, tonumber(options[4]) or 1, tonumber(options[5]) or 1) end
  if options[2] == "delete"  then EHAAnimation.animationDelete(name) end
  
  -- Animation: commands
  if options[2] == "set"     then for n, a in pairs( animations ) do EHAAnimation.setParameter(a, options[4], options[5], options[6]) end end
  if options[2] == "set-force" then for n, a in pairs( animations ) do a[options[4]] = options[5] end end
  if options[2] == "reset"   then for n, a in pairs( animations ) do EHAAnimation.reset(a)  end end
  if options[2] == "play"    then for n, a in pairs( animations ) do EHAAnimation.start(EHAAnimation.collectible(a))  end end
  if options[2] == "stop"    then for n, a in pairs( animations ) do EHAAnimation.stop(a, true)  end end
  if options[2] == "random"  then for n, a in pairs( animations ) do EHAAnimation.random(a)  end end
  if options[2] == "toggle"  then for n, a in pairs( animations ) do EHAAnimation.toggle(EHAAnimation.collectible(a)) end end
  if options[2] == "list"    then for n, a in pairs( animations ) do d(n, a) end end

  if options[2] == "activate"  then for n, a in pairs( animations ) do EHAInteract.activate(a, ((options[4] or "on") ~= "on") and 1 or 0) end end
  if options[2] == "atoggle"  then for n, i in pairs( interacts ) do EHAInteract.toggle(i) end end

end
