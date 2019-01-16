--[[
    Typing Game

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Timer = require 'lib/knife.timer'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

ALPHABET = 'abcdefghijklmnopqrstuvwxyz'

local font = love.graphics.newFont('fonts/font.ttf', 64)

local currentTime = 60
local currentCharIndex = 1
local score = 0

local words = {}
local fullString
local halfString

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)

    love.graphics.setFont(font)

    Timer.every(1, function()
        currentTime = currentTime - 1
    end)

    math.randomseed(os.time())

    initializeDictionary()
    chooseWord()
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

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

function love.update(dt)
    Timer.update(dt)
end

function love.draw()

    -- draw the current goal word in yellow
    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.printf(fullString, 0, WINDOW_HEIGHT / 2 - 32, WINDOW_WIDTH, 'center')
    love.graphics.setColor(1, 1, 1, 1)

    -- draw the progress of the word we're typing in white
    local halfString = currentCharIndex == 1 and '' or fullString:sub(1, currentCharIndex - 1)
    love.graphics.printf(halfString, 0, WINDOW_HEIGHT / 2 + 16, 
        WINDOW_WIDTH - font:getWidth(fullString:sub(halfString:len() + 1, fullString:len())), 'center')

    -- draw the timer in the top-left
    love.graphics.print(tostring(currentTime))

    -- draw the score in the top-right
    love.graphics.printf(tostring(score), 0, 0, WINDOW_WIDTH, 'right')

    love.graphics.printf(tostring(#words) .. ' words loaded!',
        0, 64, WINDOW_WIDTH, 'center')
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