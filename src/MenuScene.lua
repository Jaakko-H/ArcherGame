
local MenuScene = class("MenuScene",function()
    return cc.Scene:create()
end)

function MenuScene.create()
    local scene = MenuScene.new()
    scene:addChild(scene:addBackground())
    scene:addInterface()
    scene:addKeyListener()
    return scene
end

function MenuScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
end

function MenuScene:addBackground()
    local backGround = cc.Layer:create()
    
    local bg = cc.Sprite:create("bg.png")
    bg:setScaleX(1 * self.visibleSize.width / 480)
    bg:setScaleY(1 * self.visibleSize.height / 320)
    bg:setPosition(self.origin.x + self.visibleSize.width / 3 + 80, self.origin.y + self.visibleSize.height / 1.4)
    bg:setOpacity(75)
    
    backGround:addChild(bg)
    return backGround
end

function MenuScene:addInterface()
    local instructionLabel1 = cc.Label:createWithTTF("Hit your enemy 10 times to win.", "fonts/Marker Felt.ttf", 20)
    instructionLabel1:setPosition(cc.p(self.visibleSize.width / 2, self.visibleSize.height / 5 * 4))
    instructionLabel1:setColor(cc.c3b(200, 200, 0))
    local instructionLabel2 = cc.Label:createWithTTF("Avoid taking hit thrice.\nPress any key to start!", "fonts/Marker Felt.ttf", 20)
    instructionLabel2:setPosition(cc.p(self.visibleSize.width / 2, self.visibleSize.height / 5 * 3.5))
    instructionLabel2:setColor(cc.c3b(200, 200, 0))
    self:addChild(instructionLabel1)
    self:addChild(instructionLabel2)
    
    local controls = cc.Label:createWithTTF("move = arrow keys \nspace = jump \nv = shoot \nr = restart" , "fonts/Marker Felt.ttf" ,20)
    controls:setPosition(cc.p(self.visibleSize.width / 6 * 5, self.visibleSize.height / 5))
    self:addChild(controls)
end

function MenuScene:addKeyListener()
    local function onKeyPressed(code, event)
        local GameScene = require("GameScene").create()
        cc.Director:getInstance():replaceScene(cc.TransitionCrossFade:create(1, GameScene))
    end

    local keyListener = cc.EventListenerKeyboard:create()
    keyListener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(keyListener, self)
end

return MenuScene