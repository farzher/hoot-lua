local function table_import(t, t2)
  for k, v in pairs(t2) do t[k] = v end
end


local methods = {}
function methods:set(f, delay, options)
  local key

  -- If f is string, default key to f
    if type(f)=='string' then key = f end

  -- options
    if options then
      if options.key~=nil then key = options.key end

      if options.ifactive=='nop' then
        if self.timers[key] and self.timers[key].delay>0 then return end
      end
    end

  if not key then
    repeat
      key = math.random()
    until self.timers[key]==nil
  end
  self.timers[key] = {delay=delay, f=f, options=options}
  return key
end
function methods:get(key) return self.timers[key] end
function methods:clear(key) self.timers[key] = nil end
function methods:destroy() self.instances[self.t] = nil end



local function factory()
  local hoot = {}
  hoot.instances = {}
  setmetatable(hoot, {
    __call = function(self, t)
      if self.instances[t] then return self.instances[t] end

      local instance = {t=t, timers={}}
      table_import(instance, methods)
      self.instances[t] = instance
      return instance
    end;
  })
  function hoot.update(dt)
    for _, instance in pairs(hoot.instances) do
      for key, timer in pairs(instance.timers) do
        if timer.delay>0 then
          timer.delay = timer.delay - dt

          if timer.options and timer.options.update then
            timer.options.update(instance.t)
          end

          if timer.delay<=0 then
            if type(timer.f)=='string' then
              if instance.t[timer.f] then instance.t[timer.f](instance.t) end
            else
              timer.f(instance.t)
            end

            instance.timers[key] = nil
          end
        end
      end
    end
  end
  function hoot.destroy() hoot.instances = {} end
  function hoot.new() return factory() end

  return hoot
end

return factory()
