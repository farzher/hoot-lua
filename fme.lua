local t_counters={}
local instances={}

local table_import = function(t, t2)
  for k, v in pairs(t2) do t[k] = v end
end

local methods = {}
function methods:set(f, frames, options)
  local k

  -- If f is string, use default k to f
    if type(f)=='string' then
      k = f
    end

  -- options
    if options then
      if options.k~=nil then
        k = options.k
      end

      if options.ifexists=='noop' then
        if self.counters[k] and self.counters[k].frames>0 then return end
      end
    end

  if not frames then frames = 0 end
  if k==nil then
    repeat
      k = math.random()
    until self.counters[k]==nil
  end
  self.counters[k] = {frames=frames, f=f}
end
function methods:get(k) return self.counters[k] end
function methods:clear(k) self.counters[k] = nil end
function methods:destroy() t_counters[self.t] = nil instances[self.t] = nil end
function methods:update()
  for k, counter in pairs(self.counters) do
    if counter.frames>0 then
      counter.frames = counter.frames - 1
      if counter.frames==0 then
        if type(counter.f)=='string' then
          if self.t[counter.f] then self.t[counter.f](self.t) end
        else
          counter.f(self.t)
        end

        self.counters[k] = nil
      end
    end
  end
end



-- local FC = {}
-- setmetatable(FC, {
--   __call = function(self, t)
--     if instances[t] then return instances[t] end

--     t_counters[t] = {}
--     local instance = {t=t, counters=t_counters[t]}
--     table_import(instance, methods)
--     instances[t] = instance
--     return instance
--   end;
-- })

-- return FC
return function(t)
  if instances[t] then return instances[t] end

  t_counters[t] = {}
  local instance = {t=t, counters=t_counters[t]}
  table_import(instance, methods)
  instances[t] = instance
  return instance
end
