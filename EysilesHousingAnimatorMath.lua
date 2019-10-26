
-- A gret preview for easing functions: 
-- https://docs.coronalabs.com/api/library/easing/index.html#easing-functions

-- t: current time
-- b: start value
-- c: change in value
-- d: duration
-- a: amplitud
-- p: period

EHAMath = {}

function EHAMath.normalize (a)
  if a > math.pi then return a - 2 * math.pi end
  if a < -math.pi then return a + 2 * math.pi end
  return a
end

function EHAMath.easelinear(t, b, c, d)
  return c * t / d + b
end

function EHAMath.easeinquad(t, b, c, d)
  t = t / d
  return c * t^2 + b
end

function EHAMath.easeoutquad(t, b, c, d)
  t = t / d
  return -c * t * (t - 2) + b
end

function EHAMath.easeinoutquad(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * t^2 + b
  else
    return -c / 2 * ((t - 1) * (t - 3) - 1) + b
  end
end

function EHAMath.easeoutinquad(t, b, c, d)
  if t < d / 2 then
    return EHAMath.easeoutquad (t * 2, b, c / 2, d)
  else
    return EHAMath.easeinquad((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function EHAMath.easeincubic (t, b, c, d)
  t = t / d
  return c * t^3 + b
end

function EHAMath.easeoutcubic(t, b, c, d)
  t = t / d - 1
  return c * (t^3 + 1) + b
end

function EHAMath.easeinoutcubic(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * t^3 + b
  else
    t = t - 2
    return c / 2 * (t^3 + 2) + b
  end
end

function EHAMath.easeoutincubic(t, b, c, d)
  if t < d / 2 then
    return EHAMath.easeoutcubic(t * 2, b, c / 2, d)
  else
    return EHAMath.easeincubic((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function EHAMath.easeinquart(t, b, c, d)
  t = t / d
  return c * t^4 + b
end

function EHAMath.easeoutquart(t, b, c, d)
  t = t / d - 1
  return -c * (t^4 - 1) + b
end

function EHAMath.easeinoutquart(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * t^4 + b
  else
    t = t - 2
    return -c / 2 * (t^4 - 2) + b
  end
end

function EHAMath.easeoutinquart(t, b, c, d)
  if t < d / 2 then
    return EHAMath.easeoutquart(t * 2, b, c / 2, d)
  else
    return EHAMath.easeinquart((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function EHAMath.easeinquint(t, b, c, d)
  t = t / d
  return c * t^5 + b
end

function EHAMath.easeoutquint(t, b, c, d)
  t = t / d - 1
  return c * (t^5 + 1) + b
end

function EHAMath.easeinoutquint(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * t^5 + b
  else
    t = t - 2
    return c / 2 * (t^5 + 2) + b
  end
end

function EHAMath.easeoutinquint(t, b, c, d)
  if t < d / 2 then
    return EHAMath.outquint(t * 2, b, c / 2, d)
  else
    return EHAMath.inquint((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function EHAMath.easeinsine(t, b, c, d)
  return -c * math.cos(t / d * (math.pi / 2)) + c + b
end

function EHAMath.easeoutsine(t, b, c, d)
  return c * math.sin(t / d * (math.pi / 2)) + b
end

function EHAMath.easeinoutsine(t, b, c, d)
  return -c / 2 * (math.cos(math.pi * t / d) - 1) + b
end

function EHAMath.easeoutinsine(t, b, c, d)
  if t < d / 2 then
    return EHAMath.easeoutsine(t * 2, b, c / 2, d)
  else
    return EHAMath.easeinsine((t * 2) -d, b + c / 2, c / 2, d)
  end
end

function EHAMath.easeinexpo(t, b, c, d)
  if t == 0 then
    return b
  else
    return c * math.pow(2, 10 * (t / d - 1)) + b - c * 0.001
  end
end

function EHAMath.easeoutexpo(t, b, c, d)
  if t == d then
    return b + c
  else
    return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b
  end
end

function EHAMath.easeinoutexpo(t, b, c, d)
  if t == 0 then return b end
  if t == d then return b + c end
  t = t / d * 2
  if t < 1 then
    return c / 2 * math.pow(2, 10 * (t - 1)) + b - c * 0.0005
  else
    t = t - 1
    return c / 2 * 1.0005 * (-math.pow(2, -10 * t) + 2) + b
  end
end

function EHAMath.easeoutinexpo(t, b, c, d)
  if t < d / 2 then
    return EHAMath.easeoutexpo(t * 2, b, c / 2, d)
  else
    return EHAMath.easeinexpo((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function EHAMath.easeincirc(t, b, c, d)
  t = t / d
  return(-c * (math.sqrt(1 - t^2) - 1) + b)
end

function EHAMath.easeoutcirc(t, b, c, d)
  t = t / d - 1
  return(c * math.sqrt(1 - t^2) + b)
end

function EHAMath.easeinoutcirc(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return -c / 2 * (math.sqrt(1 - t^2) - 1) + b
  else
    t = t - 2
    return c / 2 * (math.sqrt(1 - t^2) + 1) + b
  end
end

function EHAMath.easeoutincirc(t, b, c, d)
  if t < d / 2 then
    return EHAMath.easeoutcirc(t * 2, b, c / 2, d)
  else
    return EHAMath.easeincirc((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function EHAMath.easeinelastic(t, b, c, d, a, p)
  if t == 0 then return b end

  t = t / d

  if t == 1  then return b + c end

  if not p then p = d * 0.3 end

  local s

  if not a or a < math.abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * math.pi) * math.asin(c/a)
  end

  t = t - 1

  return -(a * math.pow(2, 10 * t) * math.sin((t * d - s) * (2 * math.pi) / p)) + b
end

function EHAMath.easeoutelastic(t, b, c, d, a, p)
  if t == 0 then return b end

  t = t / d

  if t == 1 then return b + c end

  if not p then p = d * 0.3 end

  local s

  if not a or a < math.abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * math.pi) * math.asin(c/a)
  end

  return a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * math.pi) / p) + c + b
end

function EHAMath.easeinoutelastic(t, b, c, d, a, p)
  if t == 0 then return b end

  t = t / d * 2

  if t == 2 then return b + c end

  if not p then p = d * (0.3 * 1.5) end
  if not a then a = 0 end

  local s

  if not a or a < math.abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * math.pi) * math.asin(c / a)
  end

  if t < 1 then
    t = t - 1
    return -0.5 * (a * math.pow(2, 10 * t) * math.sin((t * d - s) * (2 * math.pi) / p)) + b
  else
    t = t - 1
    return a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * math.pi) / p ) * 0.5 + c + b
  end
end

function EHAMath.easeoutinelastic(t, b, c, d, a, p)
  if t < d / 2 then
    return EHAMath.outelastic(t * 2, b, c / 2, d, a, p)
  else
    return EHAMath.inelastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
  end
end

function EHAMath.easeinback(t, b, c, d, s)
  if not s then s = 1.70158 end
  t = t / d
  return c * t^2 * ((s + 1) * t - s) + b
end

function EHAMath.easeoutback(t, b, c, d, s)
  if not s then s = 1.70158 end
  t = t / d - 1
  return c * (t^2 * ((s + 1) * t + s) + 1) + b
end

function EHAMath.easeinoutback(t, b, c, d, s)
  if not s then s = 1.70158 end
  s = s * 1.525
  t = t / d * 2
  if t < 1 then
    return c / 2 * (t^2 * ((s + 1) * t - s)) + b
  else
    t = t - 2
    return c / 2 * (t^2 * ((s + 1) * t + s) + 2) + b
  end
end

function EHAMath.easeoutinback(t, b, c, d, s)
  if t < d / 2 then
    return EHAMath.easeoutback(t * 2, b, c / 2, d, s)
  else
    return EHAMath.easeinback((t * 2) - d, b + c / 2, c / 2, d, s)
  end
end

function EHAMath.easeoutbounce(t, b, c, d)
  t = t / d
  if t < 1 / 2.75 then
    return c * (7.5625 * t^2) + b
  elseif t < 2 / 2.75 then
    t = t - (1.5 / 2.75)
    return c * (7.5625 * t^2 + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)
    return c * (7.5625 * t^2 + 0.9375) + b
  else
    t = t - (2.625 / 2.75)
    return c * (7.5625 * t^2 + 0.984375) + b
  end
end

function EHAMath.easeinbounce(t, b, c, d)
  return c - EHAMath.easeoutbounce(d - t, 0, c, d) + b
end

function EHAMath.easeinoutbounce(t, b, c, d)
  if t < d / 2 then
    return EHAMath.easeinbounce(t * 2, 0, c, d) * 0.5 + b
  else
    return EHAMath.easeoutbounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
  end
end

function EHAMath.easeoutinbounce(t, b, c, d)
  if t < d / 2 then
    return EHAMath.easeoutbounce(t * 2, b, c / 2, d)
  else
    return EHAMath.easeinbounce((t * 2) - d, b + c / 2, c / 2, d)
  end
end