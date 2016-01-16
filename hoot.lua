local function table_import(t, t2)
  for k, v in pairs(t2) do t[k] = v end
end


local function factory()
  -- Our new hoot object
    local hoot = {}
  -- When you call hoot(self) self gets shoved in this list as the key with a wrapped version as the value
    hoot.wrapped_list = {}
  -- For iteration performance, all timers from all objects also exist here
  -- (This means they need to be created and cleared in pairs /:)
    hoot.timer_set = {}


  -- Wrapper class (in factory for hoot closure!)
    local Wrapper = {}
    function Wrapper:get(key) return self.timers[key] end
    function Wrapper:clear(key)
      local timer = self.timers[key]
      if not timer then return end
      self.timers[key] = nil
      hoot.timer_set[timer] = nil
      return true
    end
    function Wrapper:destroy()
      for _, timer in pairs(self.timers) do hoot.timer_set[timer] = nil end
      hoot.wrapped_list[self.original] = nil
    end
    function Wrapper:set(f, delay, options)
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

      -- Pick a unqiue random key
        if not key then
          repeat
            key = math.random()
          until self.timers[key]==nil
        end

      local timer = {wrapped=self, key=key, delay=delay, f=f, options=options}
      self.timers[key] = timer
      hoot.timer_set[timer] = true

      return key
    end


  setmetatable(hoot, {
    __call = function(self, original)
      if self.wrapped_list[original] then return self.wrapped_list[original] end

      local wrapped = {original=original, timers={}}
      table_import(wrapped, Wrapper)
      self.wrapped_list[original] = wrapped
      return wrapped
    end;
  })


  function hoot.update(dt)
    for timer in pairs(hoot.timer_set) do
      if timer.delay>0 then
        timer.delay = timer.delay - dt

        local original = timer.wrapped.original

        if timer.options and timer.options.update then
          timer.options.update(original)
        end

        if timer.delay<=0 then
          if type(timer.f)=='string' then
            if original[timer.f] then original[timer.f](original) end
          elseif type(timer.f)=='function' then
            timer.f(original)
          end

          timer.wrapped:clear(timer.key)
        end
      end
    end
  end
  function hoot.destroy() hoot.wrapped_list = {} end
  function hoot.new() return factory() end

  return hoot
end

return factory()
