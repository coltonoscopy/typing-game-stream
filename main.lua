--[[
    Typing Game

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Timer = require 'lib/knife.timer'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

ALPHABET = "abcdefghijklmnopqrstuvwxyz'"

local font = love.graphics.newFont('fonts/font.ttf', 64)

local currentTime = 60
local currentCharIndex = 1
local score = 0

local words = {}
local fullString
local halfString

local start = true
local gameOver = false
local cursor = false

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)

    love.graphics.setFont(font)

    Timer.every(1, function()
        currentTime = currentTime - 1
        if currentTime == 0 then
            gameOver = true
            currentTime = 60
        end
    end)

    Timer.every(0.5, function()
        cursor = not cursor
    end)

    math.randomseed(os.time())

    initializeDictionary()
    chooseWord()
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if start and key == 'space' then
        start = false
    end

    if gameOver and key == 'space' then
        gameOver = false
        score = 0
        chooseWord()
    end

    if not start and not gameOver then
        for i = 1, #ALPHABET do
            local char = ALPHABET:sub(i, i)

            -- if we have pressed this key of the alphabet...
            if key == char then

                -- if we have typed the current correct letter...
                if char == fullString:sub(currentCharIndex, currentCharIndex) then

                    -- successfully typed full word
                    if currentCharIndex == fullString:len() then
                        score = score + fullString:len()
                        chooseWord()
                    else
                        currentCharIndex = currentCharIndex + 1
                    end
                else

                    -- else if we typed the wrong letter...
                    currentCharIndex = 1
                end
            end
        end
    end
end

function love.update(dt)

    if not start and not gameOver then
        Timer.update(dt)
    end
end

function love.draw()

    -- draw the current goal word in yellow
    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.print(fullString, WINDOW_WIDTH / 2 - font:getWidth(fullString) / 2, WINDOW_HEIGHT / 2 - 32)
    love.graphics.setColor(1, 1, 1, 1)

    -- draw the progress of the word we're typing in white
    local halfString = currentCharIndex == 1 and '' or fullString:sub(1, currentCharIndex - 1)
    love.graphics.print(halfString, WINDOW_WIDTH / 2 - font:getWidth(fullString) / 2, WINDOW_HEIGHT / 2 + 16)
    
    -- add cursor to the half-string text based on cursor state
    if cursor then
        love.graphics.print('|', WINDOW_WIDTH / 2 - font:getWidth(fullString) / 2 + font:getWidth(halfString), WINDOW_HEIGHT / 2 + 16)
    end

    -- draw the timer in the top-left
    love.graphics.print(tostring(currentTime))

    -- draw the score in the top-right
    love.graphics.printf(tostring(score), 0, 0, WINDOW_WIDTH, 'right')

    love.graphics.printf(tostring(#words) .. ' words loaded!',
        0, 64, WINDOW_WIDTH, 'center')

    -- draw starting panel
    if start then
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.rectangle('fill', 128, 128, WINDOW_WIDTH - 256, WINDOW_HEIGHT - 256)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf('Press Space to Start', 0, WINDOW_HEIGHT / 2 - 32, WINDOW_WIDTH, 'center')
    end

    if gameOver then
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.rectangle('fill', 128, 128, WINDOW_WIDTH - 256, WINDOW_HEIGHT - 256)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf('Game Over', 0, WINDOW_HEIGHT / 2 - 32, WINDOW_WIDTH, 'center')
        love.graphics.printf('Your Score: ' .. tostring(score), 0, WINDOW_HEIGHT / 2 + 18, WINDOW_WIDTH, 'center')
        love.graphics.printf('Press Space to Restart', 0, WINDOW_HEIGHT / 2 + 64, WINDOW_WIDTH, 'center')
    end
end

function initializeDictionary()
    for line in love.filesystem.lines('large.txt') do
        table.insert(words, line) 
    end
end

function chooseWord()
    currentCharIndex = 1
    fullString = words[math.random(#words)]
end