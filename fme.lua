local t_timers={}
local instances={}

local table_import = function(t, t2)
  for k, v in pairs(t2) do t[k] = v end
end

local methods = {}
function methods:set(f, frames, options)
  local key

  -- If f is string, use default key to f
    if type(f)=='string' then
      key = f
    end

  -- options
    if options then
      if options.key~=nil then
        key = options.key
      end

      if options.ifexists=='noop' then
        if self.timers[key] and self.timers[key].frames>0 then return end
      end
    end

  if not frames then frames = 0 end
  if key==nil then
    repeat
      key = math.random()
    until self.timers[key]==nil
  end
  self.timers[key] = {frames=frames, f=f}
end
function methods:get(key) return self.timers[key] end
function methods:clear(key) self.timers[key] = nil end
function methods:destroy() t_timers[self.t] = nil instances[self.t] = nil end
function methods:update()
  for key, timer in pairs(self.timers) do
    if timer.frames>0 then
      timer.frames = timer.frames - 1
      if timer.frames==0 then
        if type(timer.f)=='string' then
          if self.t[timer.f] then self.t[timer.f](self.t) end
        else
          timer.f(self.t)
        end

        self.timers[key] = nil
      end
    end
  end
end

return function(t)
  if instances[t] then return instances[t] end

  t_timers[t] = {}
  local instance = {t=t, timers=t_timers[t]}
  table_import(instance, methods)
  instances[t] = instance
  return instance
end
