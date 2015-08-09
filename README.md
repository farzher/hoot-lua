#[fme.lua](https://raw.github.com/farzher/fme-lua/master/fme.lua) (FraME timer)
A better way to deal with frame based timer events. Intended for [LÖVE](https://love2d.org/)


##What? Why?

To cleanup this type of code
```lua
self.wakeup_timer = 0
self.is_down = false

function Enemy:knockdown()
  self.is_down = true
  self.wakeup_timer = 60
end

function Enemy:update()
  if self.is_down then
    self.wakeup_timer = self.wakeup_timer - 1
    if self.wakeup_timer == 0 then
      self.is_down = false
    end
  end

  if self.is_down then print('Im down!') end
end
```

And replace it with this type of code
```lua
function Enemy:knockdown()
  fme(self):set('is_down', 60)
end

function Enemy:update()
  fme(self):update()

  if fme(self):get('is_down') then print('Im down!') end
end
```



##Installation
```lua
fme = require 'fme'
```


##Usage Examples


Set the lifespan of this object to 5 seconds
```lua
function Bullet:destroy()
  -- TODO: Remove object from game
end
fme(self):set('destroy', 60*5)
```


When hit, toggle being flipped on our side. If flipped for 2 seconds, automatically jump back up
```lua
function Creep:hit()
  self.is_flipped = not self.is_flipped

  if self.is_flipped then
    fme(self):set('hit', 60*2)
  else
    fme(self):clear('hit')
  end

  -- Jump up
    self.vy = -200
    self.body:setLinearVelocity(self.vx, self.vy)
end
```
![](https://raw.github.com/farzher/fme-lua/master/wakeup.gif)



##Documentation (it's not much)

###`fme(self):set(func, frames, options)`

Set a new timer that will trigger after `frames` frames.

`func` can be a `function` or `string` of a function name on `self`. If it exists it'll be called with `self` as the first argument.



###`fme(self):get(key)`

Returns timer info if it exists, else `nil`

Timer info looks like this `{frames=16, f='mycallback'}`


###`fme(self):clear(key)`
Clear the timer. It'll never trigger


###`fme(self):destroy()`
Cleanup all `fme` memory associated with `self`





