push = require 'push'

Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 800
WINDOW_HEIGHT = 450

VIRTUAL_WIDTH = 400
VIRTUAL_HEIGHT = 225

paddleSpeed = 150
PADDLE_WIDTH = 5
PADDLE_HEIGHT = 20

AIStatus = 'disabled'

function love.load()
    math.randomseed(os.time())
    
    love.window.setTitle("Pong")

    love.graphics.setDefaultFilter('nearest', 'nearest')

    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)

    --[[Setting up sound
    -- the type can be static or stream 
    -- stream for big audio files in order to not take up a lot of memory
    -- static for small files in order to store them in the memory and not take them from the disk
    
    -- all of this can be written as a table
    
    paddleHitSound = love.audio.newSource('sounds/paddle_hit.wav', 'static')
    scoreSound = love.audio.newSource('sounds/score.wav', 'static')
    wallHitSound = love.audio.newSource('sounds/wall_hit.wav', 'static')
    ]]

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    --window setup
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    --init paddle
    player1 = Paddle(10, 30, PADDLE_WIDTH, PADDLE_HEIGHT)
    player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 50, PADDLE_WIDTH, PADDLE_HEIGHT)

    --init ball
    ball = Ball(VIRTUAL_WIDTH/2 - 2, VIRTUAL_HEIGHT/2 - 2, 4, 4)

    --init score
    p1Score = 0
    p2Score = 0
    playerToServe = 1

    --init state
    gameState = 'welcome'
end

function love.update(dt)
    -- whenever we are in game for the things to move
    if gameState == 'play' then
        checkPaddleMovment()
        checkColission()
        player1:update(dt)
        player2:update(dt)
        ball:update(dt)
        checkIfScore()
    end
end

function randomiseangle()
    if ball.dy < 0 then
        ball.dy = - math.random(10, 150)
    else
        ball.dy = math.random(10, 150)
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    winMessage()
    helpMessages()

    player1:render()
    player2:render()
    ball:render()

    push:apply('end')
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if key == 'enter' or key == 'return' then
        if gameState == 'end' then
            gameState = 'welcome'
            if p1Score == 10 then
                playerToServe = 2
            else
                playerToServe = 1
            end
            p1Score = 0
            p2Score = 0
            ball:reset(playerToServe)
        elseif gameState == 'welcome' then 
            gameState = 'serve'
            ball:reset(playerToServe)
        elseif gameState == 'serve' then
            gameState = 'play'
        end
    end

    if key == '`' then
        if AIStatus == 'disabled' then
            AIStatus = 'enabled'
        else
            AIStatus = 'disabled'
        end
    end
end

function love.resize(width, height)
    push:resize(width, height)
end

function checkColission()
    --paddle 1 col
    if ball:collide(player1) then
        ball.dx = -ball.dx * 1.1
        -- 5 for paddle size
        ball.x = player1.x + 5
        sounds['paddle_hit']:play()
        randomiseangle()
    end

    --paddle 2 col
    if ball:collide(player2) then
        ball.dx = -ball.dx * 1.1
        --here is 4 because of the size of the ball whereas higher is 5 because of the width of the paddle
        ball.x = player2.x - 4
        sounds['paddle_hit']:play()
        randomiseangle()
    end

    --top col
    if ball.y < 0 then
        ball.dy = -ball.dy
        ball.y = 5
        sounds['wall_hit']:play()
    end

    --bottom col
    -- -4 because of the ball size
    if ball.y > VIRTUAL_HEIGHT - 4 then
        ball.dy = -ball.dy
        ball.y = VIRTUAL_HEIGHT - 4
        sounds['wall_hit']:play()
    end
end

function checkIfScore()
    --p2 score
    if ball.x < 0 then
        p2Score = p2Score + 1
        playerToServe = 1
        gameState = 'serve'
        sounds['score']:play()
        ball:reset(playerToServe)
    end
    
    --p1 score
    if ball.x > VIRTUAL_WIDTH then
        p1Score = p1Score + 1
        playerToServe = 2
        gameState = 'serve'
        sounds['score']:play()
        ball:reset(playerToServe)
    end
end

function checkPaddleMovment()
    --movement for player 1
    if love.keyboard.isDown('w') then
        player1.speed = - paddleSpeed
    elseif love.keyboard.isDown('s') then
        player1.speed = paddleSpeed
    else
        player1.speed = 0
    end

    --movement for player 2
    if AIStatus == 'disabled' then
        if love.keyboard.isDown('up') then
            player2.speed = - paddleSpeed
        elseif love.keyboard.isDown('down') then
            player2.speed = paddleSpeed
        else
            player2.speed = 0
        end
    else
        --[[easy way of AI
        if ball.x > VIRTUAL_WIDTH - 20 then
            player2.y = ball.y
        end
        ]]
        --[[another easy AI]]
        player2.y = ball.y
    end
end

function helpMessages()
    love.graphics.setFont(smallFont)
    love.graphics.printf('FPS: ' .. tostring(love.timer.getFPS()), 5, 5, VIRTUAL_WIDTH, 'left')

    if gameState == 'welcome' then
        love.graphics.printf('Welcome to the game!', 0, 0, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to continue', 0, 8, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'serve' then
        if playerToServe == 1 then
            love.graphics.printf('Player 1 is serving', 0, 0, VIRTUAL_WIDTH, 'center')
        else
            love.graphics.printf('Player 2 is serving', 0, 0, VIRTUAL_WIDTH, 'center')
        end
        love.graphics.printf('Press Enter to continue', 0, 8, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'end' then
        love.graphics.printf('The game finished', 0, 0, VIRTUAL_WIDTH, 'center')
    end

    --Score message
    love.graphics.setFont(scoreFont)
    love.graphics.printf(tostring(p1Score), 0, 15, VIRTUAL_WIDTH - 100, 'center')
    love.graphics.printf(tostring(p2Score), 0, 15, VIRTUAL_WIDTH + 100, 'center')
end

function winMessage()
    if p1Score == 10 or p2Score == 10 then
        gameState = 'end'
        if p1Score == 10 then
            love.graphics.printf('Player 1 Won!', 0, VIRTUAL_HEIGHT/2, VIRTUAL_WIDTH, 'center')
        else
            love.graphics.printf('Player 2 Won!', 0, VIRTUAL_HEIGHT/2, VIRTUAL_WIDTH, 'center')
        end
    end
end