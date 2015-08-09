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

###`fme(self):set(f, frames, options)`

Set a new timer that will trigger after `frames` frames.

`f` can be a `function` or `string` of a function name on `self`. If it exists it'll be called with `self` as the first argument.



###`fme(self):get(key)`
Returns timer info if currently running, else `nil`

Timer info looks like this `{frames=16, f='mycallback'}`. `frames` is the frames left


###`fme(self):clear(key)`
Clear the timer. It'll never trigger

###`fme(self):destroy()`
Cleanup all `fme` memory associated with `self`

###`fme(self):update()`
Put this in `self`'s update. Otherwise nothing will happen



##Other Tips
- `fme` does not store anything on your table, it's left completely untouched.
- Each timer has a `key`, which is set to `f` if it's a string, or `options.key`

  If you call `set` and the `key` already exists, the default behavior is to clear the old timer and replace it.

  You can change this behavior by setting `options.ifexists="noop"` which will instead leave the old timer alone and not set the new one

  Or you can set the `key` to `nil`, which will always stack more timers
