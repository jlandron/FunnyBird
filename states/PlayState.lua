--[[
    play state class inherits from BaseState and moves the code from main to 
    here so that once out of title screen, the game plays
]]
PlayState = Class{__includes = BaseState}

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

function PlayState:init(  )
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0

    self.score = 0

    self.lastY = -PIPE_HEIGHT + math.random(80) + 20
end

function PlayState:enter()end
function PlayState:exit()end

function PlayState:update( dt )
    self.timer = self.timer + dt
    if self.timer > 2 then
        local y = math.max( -PIPE_HEIGHT + 10  , 
            math.min( self.lastY + math.random( -20, 20 ),VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT ) )
        self.lastY = y

        table.insert( self.pipePairs,PipePair(y))
        self.timer = 0  
    end
    --update the pipes
    for k, pair in pairs(self.pipePairs) do
        if not pair.scored then
            if pair.x + PIPE_WIDTH < self.bird.x then
                self.score = self.score + 1
                pair.scored = true
                sounds['score']:play()
            end
        end
        pair:update(dt)
    end
    --check if pipes are off screen, if so, remove them
    for k, pair in pairs(self.pipePairs) do
        if pair.remove then
            table.remove( self.pipePairs, k)
        end
    end
    --update the bird
    self.bird:update(dt)
    --check for collision using AABB detection
    for k, pair in pairs(self.pipePairs) do
        for l, pipe in pairs(pair.pipes) do
            if self.bird:collides(pipe) then
                sounds['explosion']:play()
                sounds['hurt']:play()

                gStateMachine:change('score', {
                    score = self.score})
            end
        end
    end
    --check if bird hit the ground
    if self.bird.y > VIRTUAL_HEIGHT - 15 then
        sounds['explosion']:play()
        sounds['hurt']:play()
        
        gStateMachine:change('score', {
            score = self.score})
    end
end
function PlayState:render(  )
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end
    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)
    self.bird:render()
end