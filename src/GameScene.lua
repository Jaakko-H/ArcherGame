
local GameScene = class("GameScene",function()
    return cc.Scene:createWithPhysics()
end)

function GameScene.create()
    local scene = GameScene.new()
    scene:addChild(scene:createbackGround())
    scene:addStaticBorders()
    scene:addGameLogic()
    scene:addKeyListener()
    --scene:getPhysicsWorld():setDebugDrawMask(0xffff)
    return scene
end

function GameScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
end

function GameScene:createArcher()
    local textureDog = cc.Director:getInstance():getTextureCache():addImage("archer1.png")
    local rect = cc.rect(5, 4, 35, 47)
    local frame0 = cc.SpriteFrame:createWithTexture(textureDog, rect)

    local spriteArcher = cc.Sprite:createWithSpriteFrame(frame0)
    spriteArcher:setPosition(self.visibleSize.width / 10 * 9, self.visibleSize.height / 2)

    local spriteWidth = spriteArcher:getBoundingBox().width / 10 * 7
    local spriteHeight = spriteArcher:getBoundingBox().height / 10 * 7
    local size = cc.size(spriteWidth, spriteHeight)
    local material = cc.PhysicsMaterial(1.0, 1.0, 0.0)
    local physicsBody = cc.PhysicsBody:createBox(size, material)
    physicsBody:setDynamic(false)
    spriteArcher:setPhysicsBody(physicsBody)

    local archerHp = cc.Label:createWithTTF("", "fonts/Marker Felt.ttf" ,15)
    archerHp:setName("archerHp")
    archerHp:setPosition(20, 60)
    spriteArcher:addChild(archerHp)

    local function onNodeEvent(event)
        if "exit" == event then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        end
    end

    return spriteArcher
end

function GameScene:createSkeleton()
    local textureSprite = cc.Director:getInstance():getTextureCache():addImage("skeleton_sprites.png")
    local rect = cc.rect(99, 0, 38, 48)
    local frame0 = cc.SpriteFrame:createWithTexture(textureSprite, rect)

    local spriteSkeleton = cc.Sprite:createWithSpriteFrame(frame0)
    spriteSkeleton:setPosition(self.visibleSize.width / 10, self.visibleSize.height / 2)

    local spriteWidth = spriteSkeleton:getBoundingBox().width / 10 * 7
    local spriteHeight = spriteSkeleton:getBoundingBox().height / 10 * 7
    local size = cc.size(spriteWidth, spriteHeight)
    local material = cc.PhysicsMaterial(1.0, 1.0, 0.0)
    local physicsBody = cc.PhysicsBody:createBox(size, material)
    physicsBody:setDynamic(false)
    spriteSkeleton:setPhysicsBody(physicsBody)

    local skeletonHp = cc.Label:createWithTTF("", "fonts/Marker Felt.ttf" ,15)
    skeletonHp:setName("skeletonHp")
    skeletonHp:setPosition(20, 60)
    spriteSkeleton:addChild(skeletonHp)

    return spriteSkeleton
end

function GameScene:createArrow()
    -- arrow
    local textureDog = cc.Director:getInstance():getTextureCache():addImage("archer1.png")
    local rect = cc.rect(458, 229, 35, 8)
    local frame0 = cc.SpriteFrame:createWithTexture(textureDog, rect)

    local spriteArrow = cc.Sprite:createWithSpriteFrame(frame0)
    spriteArrow:setPosition(self.spriteChar:getPositionX(), self.spriteChar:getPositionY())

    local spriteWidth = spriteArrow:getBoundingBox().width / 10 * 8
    local spriteHeight = spriteArrow:getBoundingBox().height / 10 * 8
    local size = cc.size(spriteWidth, spriteHeight)
    local material = cc.PhysicsMaterial(1.0, 1.0, 0.0)
    local physicsBody = cc.PhysicsBody:createBox(size, material)
    physicsBody:setDynamic(false)
    spriteArrow:setPhysicsBody(physicsBody)

    if self.spriteChar.facing == 1 then
        local flipAction = cc.FlipX:create(true)
        spriteArrow:runAction(flipAction)
    end

    return spriteArrow
end

function GameScene:createbackGround()
    local backGround = cc.Layer:create()

    local bg = cc.Sprite:create("bg.png")
    bg:setScaleX(1 * self.visibleSize.width / 480)
    bg:setScaleY(1 * self.visibleSize.height / 320)
    bg:setPosition(self.origin.x + self.visibleSize.width / 3 + 80, self.origin.y + self.visibleSize.height / 1.4)
    self.bg = bg
    backGround:setName("backGround")
    backGround:addChild(bg)

    local spriteChar = self:createArcher()
    backGround:addChild(spriteChar)
    self.spriteChar = spriteChar
    self.spriteChar.state = "idle"
    self.spriteChar.facing = -1
    self:animateChar()
    self.spriteChar.hp = 3

    local spriteSkeleton = self:createSkeleton()
    backGround:addChild(spriteSkeleton)
    self.spriteSkeleton = spriteSkeleton
    self.spriteSkeleton.state = "walk"
    self:animateEnemy()
    self.spriteSkeleton.hp = 10

    spriteChar:getChildByName("archerHp"):setString("" .. self.spriteChar.hp )
    spriteSkeleton:getChildByName("skeletonHp"):setString("" .. self.spriteSkeleton.hp )
    self.minutes = 0
    self.seconds = 0

    local controls = cc.Label:createWithTTF("move = arrow keys \nspace = jump \nv = shoot \nr = restart" , "fonts/Marker Felt.ttf" ,20)
    controls:setPosition(cc.p(self.visibleSize.width / 6 * 5, self.visibleSize.height / 5))
    self:addChild(controls)

    local timer = cc.Label:createWithTTF("0" .. self.minutes .. ":0" .. self.seconds , "fonts/Marker Felt.ttf" ,20)
    timer:setPosition(cc.p(self.visibleSize.width / 6, self.visibleSize.height / 5))
    timer:setName("timer")
    self:addChild(timer)

    local function onNodeEvent(event)
        if "exit" == event and self.schedulerID then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        end
    end
    backGround:registerScriptHandler(onNodeEvent)
    self.backGround = backGround
    return backGround
end

function GameScene:addStaticBorders()
    -- Bottom
    self:addStaticBox(self.visibleSize.width / 2, 0, self.visibleSize.width, 1)
    -- Top
    self:addStaticBox(self.visibleSize.width / 2, self.visibleSize.height, self.visibleSize.width, 1)
    -- Left
    self:addStaticBox(0, self.visibleSize.height / 2, 1, self.visibleSize.height)
    -- Right
    self:addStaticBox(self.visibleSize.width, self.visibleSize.height / 2, 1, self.visibleSize.height)
end

function GameScene:addStaticBox(x, y, width, height)
    local material = cc.PhysicsMaterial(0.1, 1.0, 0.0)
    local body = cc.PhysicsBody:createBox(cc.size(width, height), material)
    body:setDynamic(false)
    local sprite = cc.Sprite:create()
    sprite:setPosition(x, y)
    sprite:setPhysicsBody(body)
    self:addChild(sprite)
end

function GameScene:addKeyListener()
    local function onKeyPressed(code, event)
        if code == 141 then --the r key
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
            local GameScene = require("GameScene").create()
            cc.Director:getInstance():replaceScene(cc.TransitionCrossFade:create(1, GameScene))
        end
        if not self.canMove then
            return
        elseif self.spriteChar.state == "jump" and code == 26 then
            self.directionX = -1
            self.keyLeft = true
        elseif self.spriteChar.state == "jump" and code == 27 then
            self.directionX = 1
            self.keyRight = true
        elseif self.spriteChar.state == "shoot" and code == 26 then
            self.keyLeft = true
            self.shoots = false
            self.canShoot = true
            self.spriteChar.state = "walk"
            self:animateChar()
            self.directionX = -1
        elseif self.spriteChar.state == "shoot" and code == 27 then
            self.keyRight = true
            self.shoots = false
            self.canShoot = true
            self.spriteChar.state = "walk"
            self:animateChar()
            self.directionX = 1
        elseif self.spriteChar.state == "shoot" and code == 59 and self.canJump then
            self.spriteChar.state = "jump"
            self:animateChar()
            self.directionY = 1 --ylös
            self.keyJump = true
            self.canJump = false
            self.canShoot = false
            self.shoots = false
            self.jumpElapsed = 0
            self.jumped = true
            local x, y = self.spriteChar:getPosition()
            local vec2 = {x, y}
            self.jumpAction = cc.JumpBy:create(1, vec2, 80, 1)
            self.spriteChar:runAction(self.jumpAction)
            print("DirectionY:", self.directionY)
        elseif code == 26 then
            self.keyLeft = true
            self.spriteChar.state = "walk"
            self:animateChar()
            self.directionX = -1
            print("DirectionX:", self.directionX)
        elseif code == 27 then
            self.keyRight = true
            self.spriteChar.state = "walk"
            self:animateChar()
            self.directionX = 1
            print("DirectionX:", self.directionX)
        elseif code == 59 and self.canJump then
            self.spriteChar.state = "jump"
            self:animateChar()
            self.directionY = 1 --ylös
            self.keyJump = true
            self.canJump = false
            self.canShoot = false
            self.shoots = false
            self.jumpElapsed = 0
            self.jumped = true
            local x, y = self.spriteChar:getPosition()
            local vec2 = {x, y}
            self.jumpAction = cc.JumpBy:create(1, vec2, 80, 1)
            self.spriteChar:runAction(self.jumpAction)
            print("DirectionY:", self.directionY)
        elseif code == 145 and self.canShoot and not self.arrowExists then
            if self.spriteChar.state == "walk" then
                self.directionX = 0
                self.spriteChar.state = "shoot"
                self:animateChar()
                self.keyShoot = true
                self.canShoot = false
                self.shootElapsed = 0
                self.shoots = true
                print("Shot!")
            else
                self.spriteChar.state = "shoot"
                self:animateChar()
                self.keyShoot = true
                self.canShoot = false
                self.shootElapsed = 0
                self.shoots = true
                print("Shot!")
            end
            --elseif code == 125 then
            --self.spriteChar.state = "jumpBack"
            --self:animateChar()
            --self.keyJumpBack = true
            --print("Jumped back!")
        else
            print(code)
        end
    end

    local function onKeyReleased(code, event)
        if self.isDead or self.winGame then
            return
        elseif code == 26 and self.keyRight == true then
            self.directionX = 1
            self.keyLeft = false
            print("DirectionX:", self.directionX)
        elseif self.spriteChar.state == "jump" and code == 26 then
            self.directionX = 0
            self.keyLeft = false
            print("DirectionX:", self.directionX)
        elseif self.spriteChar.state == "shoot" and code == 26 then
            self.keyLeft = false
        elseif code == 26 then
            self.spriteChar.state = "idle"
            self:animateChar()
            self.directionX = 0
            self.keyLeft = false
            print("DirectionX:", self.directionX)
        end
        if code == 27 and self.keyLeft == true then
            self.directionX = -1
            self.keyRight = false
            print("DirectionX:", self.directionX)
        elseif self.spriteChar.state == "jump" and code == 27 then
            self.directionX = 0
            self.keyRight = false
            print("DirectionX:", self.directionX)
        elseif self.spriteChar.state == "shoot" and code == 27 then
            self.keyRight = false
        elseif code == 27 then
            self.spriteChar.state = "idle"
            self:animateChar()
            self.directionX = 0
            self.keyRight = false
            print("DirectionX:", self.directionX)
        end
        if code == 59 then
            self.keyJump = false
        elseif code == 145 then
            self.keyShoot = false
        end
    end

    local keyListener = cc.EventListenerKeyboard:create()
    keyListener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    keyListener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(keyListener, self)
end

function GameScene:addGameLogic()
    self.timeElapsed = 0
    self.directionX = 0
    self.directionY = 0
    self.hitElapsed = 0
    self.keyLeft = false
    self.keyRight = false
    self.keyShoot = false
    self.keyJumpBack = false
    self.canJump = true
    self.canShoot = true
    self.wasHit = false
    self.canMove = true
    self.isDead = false
    self.winGame = false
    self.enemyHit = false
    self.enemyDead = false
    self.arrowExists = false
    self.gameStarted = false

    local counter = 0
    local initialDelay = 0
    local moveRight = true

    local function tick()
        if not self.gameStarted and initialDelay < 60 then
            initialDelay = initialDelay + 1
        elseif not self.gameStarted then
            self.gameStarted = true
            self.spriteChar.state = "idle"
            self:animateChar()
            self.spriteSkeleton.state = "walk"
            self:animateEnemy()
        end
        
        if self.gameStarted then
            if self.timeElapsed then
                if not self.isDead and not self.winGame then
                    self.timeElapsed = self.timeElapsed + 1
                end
                if self.timeElapsed % 60 == 0 and not self.isDead and not self.winGame then
                    self.seconds = self.seconds + 1
                    local minutesFormat = "0" .. self.minutes
                    local secondsFormat = "0" .. self.seconds
    
                    if self.minutes >= 10 then
                        minutesFormat = "" .. self.minutes
                    end
                    if self.seconds >= 10 then
                        secondsFormat = "" .. self.seconds
                    end
    
                    self:getChildByName("timer"):setString(minutesFormat .. ":" .. secondsFormat)
                end
                if self.timeElapsed % (60 * 60) == 0 and not self.isDead and not self.winGame then
                    self.minutes = self.minutes + 1
                    self.seconds = 0
                    local minutesFormat = "0" .. self.minutes
                    local secondsFormat = "0" .. self.seconds
    
                    if self.minutes >= 10 then
                        minutesFormat = "" .. self.minutes
                    end
                    if self.seconds >= 10 then
                        secondsFormat = "" .. self.seconds
                    end
    
                    self:getChildByName("timer"):setString(minutesFormat .. ":" .. secondsFormat)
                end
            end
    
            self:gameUpdate()
    
            if self.spriteSkeleton then
                local x, y = self.spriteSkeleton:getPosition()
                if x == self.origin.x + self.visibleSize.width then
                    moveRight = false
    
                    local flipAction = cc.FlipX:create(true)
                    self.spriteSkeleton:runAction(flipAction)
    
                elseif x == self.origin.x then
                    moveRight = true
                    local flipAction = cc.FlipX:create(false)
                    self.spriteSkeleton:runAction(flipAction)
    
                end
    
                if self.spriteSkeleton.state == "walk" and not self.winGame and not self.isDead then
                    if moveRight == true then
                        x = x + 2
                    elseif moveRight == false then
                        x = x - 2
                    end
                    self.spriteSkeleton:setPositionX(x)
                end
    
                if not self.winGame and not self.isDead then
                    counter = counter + 1
    
                    if counter == 1 then
                        self.spriteSkeleton.state = "walk"
                        self:animateEnemy()
                    elseif counter == 150 then
                        self.spriteSkeleton.state = "attack"
                        self:animateEnemy()
                    elseif counter == 180 then
                        counter = 0
                    end
                end
            end
    
            if self.jumped and self.jumpElapsed < 60 then
                self.jumpElapsed = self.jumpElapsed + 1
    
                if self.jumpElapsed == 30 and not self.wasHit then
                    self:archerFall(self.spriteChar)
                    self.directionY = -1
                    print("DirectionY:", self.directionY)
                end
            elseif self.jumped and self.jumpElapsed == 60 then
                self.canJump = true
                self.canShoot = true
                self.jumped = false
                self.directionY = 0
                print("DirectionY:", self.directionY)
    
                if self.spriteChar.hp == 0 then
                    self.directionX = 0
                    self.spriteChar.state = "die"
                    self:animateChar()
                    self:endGame()
                elseif self.winGame then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
                    self.spriteChar.state = "win"
                    self:animateChar()
                elseif self.wasHit then
                    self.hitElapsed = 0
                    self.spriteChar.state = "hit"
                    self:animateChar()
                elseif self.directionX == 0 then
                    self.spriteChar.state = "idle"
                    self:animateChar()
                else
                    self.spriteChar.state = "walk"
                    self:animateChar()
                end
            end
    
            if self.shoots and self.shootElapsed < 72 then
                self.shootElapsed = self.shootElapsed + 1
    
                if self.shootElapsed == 24 then
                    self.arrowExists = true
                    local spriteArrow = self:createArrow()
                    self.backGround:addChild(spriteArrow)
                    self.spriteArrow = spriteArrow
                    self.spriteArrow.lifeTime = 32
                    self.spriteArrow.elapsed = 0
                    self.spriteArrow.facing = self.spriteChar.facing
                end
            elseif self.spriteChar.state == "die" or self.spriteChar.state == "win" then
                self.shoots = false
            elseif self.shoots and self.keyLeft then
                self.shoots = false
                self.canShoot = true
                self.directionX = -1
                self.spriteChar.state = "walk"
                self:animateChar()
            elseif self.shoots and self.keyRight then
                self.shoots = false
                self.canShoot = true
                self.directionX = 1
                self.spriteChar.state = "walk"
                self:animateChar()
            elseif self.shoots then
                self.shoots = false
                self.canShoot = true
                self.directionX = 0
                self.spriteChar.state = "idle"
                self:animateChar()
            end
    
            if self.keyLeft and not self.keyRight and self.spriteChar.state == "walk" then
                self.directionX = -1
            elseif self.keyRight and not self.keyLeft and self.spriteChar.state == "walk" then
                self.directionX = 1
            end
    
            if self.keyLeft and not self.keyRight and self.spriteChar.state == "jump" then
                self.directionX = -1
            elseif self.keyRight and not self.keyLeft and self.spriteChar.state == "jump" then
                self.directionX = 1
            end
        end
    end

    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0, false)
end

function GameScene:gameUpdate()
    if self.spriteSkeleton then
        if self.spriteSkeleton.state == "hit" and self.enemyHit then
            self.enemyHit = false
            self.spriteSkeleton.state = "walk"
        end
        local rectChar = self.spriteChar:getBoundingBox()
        rectChar.width = rectChar.width / 10 * 7
        rectChar.height = rectChar.height / 10 * 7

        local rectSkeleton = self.spriteSkeleton:getBoundingBox()
        rectSkeleton.width = rectSkeleton.width / 10 * 7
        rectSkeleton.height = rectSkeleton.height / 10 * 7

        if cc.rectIntersectsRect(rectChar, rectSkeleton) and not self.wasHit and not self.isDead then
            self.canMove = false
            self.spriteChar.hp = self.spriteChar.hp - 1
            self.spriteChar:getChildByName("archerHp"):setString("" .. self.spriteChar.hp )

            if self.spriteChar.hp == 0 then
                self.isDead = true

                if self.spriteChar.state == "jump" then
                    self:archerHit(self.spriteChar)
                else
                    self.spriteChar.state = "die"
                    self.directionX = 0
                    self:animateChar()
                    self:endGame()
                end
            else
                self.hitElapsed = 0
                self.wasHit = true

                if self.spriteChar.state == "jump" then
                    self:archerHit(self.spriteChar)
                else
                    self.spriteChar.state = "hit"
                    self:animateChar()
                end
            end
        end
    end

    if self.spriteArrow and self.spriteSkeleton then
        local rectArrow = self.spriteArrow:getBoundingBox()
        rectArrow.width = rectArrow.width / 10 * 8
        rectArrow.height = rectArrow.height / 10 * 8

        local rectSkeleton = self.spriteSkeleton:getBoundingBox()
        rectSkeleton.width = rectSkeleton.width / 10 * 8
        rectSkeleton.height = rectSkeleton.height / 10 * 8

        if cc.rectIntersectsRect(rectArrow, rectSkeleton) and not self.enemyDead and self.spriteArrow.elapsed < self.spriteArrow.lifeTime then
            self.spriteSkeleton.hp = self.spriteSkeleton.hp - 1
            self.enemyHit = true
            self.spriteSkeleton:getChildByName("skeletonHp"):setString("" .. self.spriteSkeleton.hp )

            --self.blinkAction = cc.Blink:create(0.1, 1)
            --self.spriteSkeleton:runAction(self.blinkAction)

            local spriteArrow = self.spriteArrow
            self.backGround:removeChild(spriteArrow, true)
            self.spriteArrow = nil
            self.arrowExists = false

            if self.spriteSkeleton.hp == 0 then
                --local spriteSkeleton = self.spriteSkeleton
                --self.backGround:removeChild(spriteSkeleton)
                --self.spriteSkeleton = nil
                self:victory()
            end
        end
    end

    if self.spriteArrow then
        if self.spriteArrow.elapsed < self.spriteArrow.lifeTime + 32 then
            self.spriteArrow.elapsed = self.spriteArrow.elapsed + 1
        end

        if self.spriteArrow.elapsed == self.spriteArrow.lifeTime - 24 then
            GameScene:arrowRotation(self.spriteArrow)
        end

        if self.spriteArrow.elapsed < self.spriteArrow.lifeTime - 12 then
            if self.spriteArrow.facing == 1 then
                local x, y = self.spriteArrow:getPosition()
                x = x + 4
                self.spriteArrow:setPosition(x, y)
            else
                local x, y = self.spriteArrow:getPosition()
                x = x - 4
                self.spriteArrow:setPosition(x, y)
            end
        elseif self.spriteArrow.elapsed < self.spriteArrow.lifeTime then
            if self.spriteArrow.facing == 1 then
                local x, y = self.spriteArrow:getPosition()
                x = x + 3
                y = y - 0.5
                self.spriteArrow:setPosition(x, y)
            else
                local x, y = self.spriteArrow:getPosition()
                x = x - 3
                y = y - 0.5
                self.spriteArrow:setPosition(x, y)
            end
        elseif self.spriteArrow.elapsed < self.spriteArrow.lifeTime + 16 then
            if self.spriteArrow.facing == 1 then
                local x, y = self.spriteArrow:getPosition()
                x = x + 2
                y = y - 0.75
                self.spriteArrow:setPosition(x, y)
            else
                local x, y = self.spriteArrow:getPosition()
                x = x - 2
                y = y - 0.75
                self.spriteArrow:setPosition(x, y)
            end
        elseif self.spriteArrow.elapsed < self.spriteArrow.lifeTime + 32 then
        --arrow hits the ground
        else
            local spriteArrow = self.spriteArrow
            self.backGround:removeChild(spriteArrow, true)
            self.spriteArrow = nil
            self.arrowExists = false
        end
    end

    if self.wasHit then
        if self.hitElapsed < 120 then
            self.hitElapsed = self.hitElapsed + 1
        else
            self.wasHit = false
        end

        if self.hitElapsed == 30 then
            self.canMove = true

            if not self.jumped then
                if self.keyLeft then
                    self.directionX = -1
                    self.spriteChar.state = "walk"
                    self:animateChar()
                elseif self.keyRight then
                    self.directionX = 1
                    self.spriteChar.state = "walk"
                    self:animateChar()
                else
                    self.spriteChar.state = "idle"
                    self:animateChar()
                end
            end
        end
    end

    if not self.directionX then
        return
    elseif self.directionX == 0 then
        --direction on 0 eli hahmo ei liiku mihinkään suuntaan koordinaatistossa
        return
    elseif self.directionX == 1 and self.canMove then
        local flipAction = cc.FlipX:create(true)
        local x, y = self.spriteChar:getPosition()
        if self.spriteChar:getPositionX() < self.visibleSize.width then
            self.spriteChar:setPosition(x + 1, y)
        end
        self.spriteChar:runAction(flipAction)
        self.spriteChar.facing = 1
    elseif self.directionX == -1 and self.canMove then
        local flipAction = cc.FlipX:create(false)
        local x, y = self.spriteChar:getPosition()
        if self.spriteChar:getPositionX() > 0 then
            self.spriteChar:setPosition(x - 1, y)
        end
        self.spriteChar:runAction(flipAction)
        self.spriteChar.facing = -1
    end
end

function GameScene:endGame()
    self.canMove = false
    self.spriteChar:removeChildByName("archerHp")
    self.spriteSkeleton:removeChildByName("skeletonHp")
    self.spriteSkeleton:stopAllActions()
    self.fadeBG = cc.FadeTo:create(1, 75)
    self.bg:runAction(self.fadeBG)
    
    local endLabel = cc.Label:createWithTTF("You lose!\nPress r to try again!", "fonts/Marker Felt.ttf", 20)
    endLabel:setPosition(cc.p(self.visibleSize.width / 2, self.visibleSize.height / 5 * 3.5))
    endLabel:setColor(cc.c3b(200, 0, 0))
    self:addChild(endLabel)
    print("You died! Game over!")
end

function GameScene:victory()
    self.canMove = false
    self.winGame = true
    self.spriteChar:removeChildByName("archerHp")
    self.spriteSkeleton:removeChildByName("skeletonHp")
    self.spriteSkeleton.state = "die"
    self:animateEnemy()
    self.fadeBG = cc.FadeTo:create(1, 75)
    self.bg:runAction(self.fadeBG)
    
    local record = self.timeElapsed
    local timer = self:getChildByName("timer")
    local timerString = timer:getString()
    local winLabel = cc.Label:createWithTTF("You win!\nTime elapsed: " .. timerString .. "\nPress r to try again!", "fonts/Marker Felt.ttf", 20)
    winLabel:setPosition(cc.p(self.visibleSize.width / 2, self.visibleSize.height / 5 * 3.5))
    winLabel:setColor(cc.c3b(0, 200, 0))
    self:addChild(winLabel)
    print("You win!")

    if self.spriteChar.state == "jump" then
    --let the jump finish
    else
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        self.spriteChar.state = "win"
        self:animateChar()
    end
end

function GameScene:animateChar()
    if not self.spriteChar.state then
        return
    elseif self.spriteChar.state == "idle" then
        self.spriteChar:stopAllActions()
        GameScene:archerIdle(self.spriteChar)
    elseif self.spriteChar.state == "walk" then
        self.spriteChar:stopAllActions()
        GameScene:archerWalk(self.spriteChar)
    elseif self.spriteChar.state == "jump" then
        self.spriteChar:stopAllActions()
        GameScene:archerJump(self.spriteChar)
    elseif self.spriteChar.state == "shoot" then
        self.spriteChar:stopAllActions()
        GameScene:archerShoot(self.spriteChar)
    elseif self.spriteChar.state == "jumpBack" then
        self.spriteChar:stopAllActions()
        GameScene:archerJumpBack(self.spriteChar)
    elseif self.spriteChar.state == "hit" then
        self.spriteChar:stopAllActions()
        GameScene:archerHit(self.spriteChar)
    elseif self.spriteChar.state == "die" then
        self.spriteChar:stopAllActions()
        GameScene:archerDie(self.spriteChar)
    elseif self.spriteChar.state == "win" then
        self.spriteChar:stopAllActions()
        GameScene:archerWin(self.spriteChar)
    end
end

function GameScene:animateEnemy()
    if not self.spriteSkeleton.state then
        return
    elseif self.spriteSkeleton.state == "walk" then
        self.spriteSkeleton:stopAllActions()
        GameScene:skeletonMove(self.spriteSkeleton)
    elseif self.spriteSkeleton.state == "attack" then
        self.spriteSkeleton:stopAllActions()
        GameScene:skeletonAttack(self.spriteSkeleton)
    elseif self.spriteSkeleton.state == "die" then
        self.spriteSkeleton:stopAllActions()
        GameScene:skeletonDie(self.spriteSkeleton)
    end
end

function GameScene:archerIdle(spriteChar)
    -- Archer idle animation
    local textureDog = cc.Director:getInstance():getTextureCache():addImage("archer1.png")
    local rect = cc.rect(5, 4, 35, 47)
    local frame0 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(44, 4, 35, 47)
    local frame1 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(85, 4, 35, 47)
    local frame2 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(126, 4, 35, 47)
    local frame3 = cc.SpriteFrame:createWithTexture(textureDog, rect)

    local animation = cc.Animation:createWithSpriteFrames({frame0,frame1,frame2,frame3,}, 0.2)
    local animate = cc.Animate:create(animation);

    if spriteChar then
        spriteChar:runAction(cc.RepeatForever:create(animate))
    end
end

function GameScene:archerWalk(spriteChar)
    local textureDog = cc.Director:getInstance():getTextureCache():addImage("archer1.png")
    local rect = cc.rect(4, 71, 32, 50)
    local frame0 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(42, 71, 40, 50)
    local frame1 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(92, 71, 38, 50)
    local frame2 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(133, 71, 34, 50)
    local frame3 = cc.SpriteFrame:createWithTexture(textureDog, rect)

    local animation = cc.Animation:createWithSpriteFrames({frame0,frame1,frame2,frame3,}, 0.2)
    local animate = cc.Animate:create(animation);

    if spriteChar then
        spriteChar:runAction(cc.RepeatForever:create(animate))
    end
end

function GameScene:archerJump(spriteChar)
    -- Archer jump
    local textureDog = cc.Director:getInstance():getTextureCache():addImage("archer1.png")
    local rect = cc.rect(387, 69, 47, 49)
    local frame0 = cc.SpriteFrame:createWithTexture(textureDog, rect)

    if spriteChar then
        spriteChar:setSpriteFrame(frame0)
    end
end

function GameScene:archerFall(spriteChar)
    -- Archer fall from jump
    local textureDog = cc.Director:getInstance():getTextureCache():addImage("archer1.png")
    local rect = cc.rect(441, 69, 46, 50)
    local frame0 = cc.SpriteFrame:createWithTexture(textureDog, rect)

    if spriteChar then
        spriteChar:setSpriteFrame(frame0)
    end
end

function GameScene:archerShoot(spriteChar)
    local textureDog = cc.Director:getInstance():getTextureCache():addImage("archer1.png")
    local rect = cc.rect(1, 139, 38, 50)
    local frame0 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(40, 139, 48, 50)
    local frame1 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(95, 139, 49, 50)
    local frame2 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(151, 139, 49, 50)
    local frame3 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(208, 139, 49, 50)
    local frame4 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(265, 139, 38, 50)
    local frame5 = cc.SpriteFrame:createWithTexture(textureDog, rect)

    local animation = cc.Animation:createWithSpriteFrames({frame0,frame1,frame2,frame3,frame4,frame5}, 0.2)
    local animate = cc.Animate:create(animation);

    if spriteChar then
        spriteChar:runAction(animate)
    end
end

function GameScene:archerJumpBack(spriteChar)
    -- Archer jump back animation
    local textureDog = cc.Director:getInstance():getTextureCache():addImage("archer1.png")
    local rect = cc.rect(0, 280, 48, 45)
    local frame0 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(62, 279, 45, 48)
    local frame1 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(122, 276, 50, 48)
    local frame2 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(179, 275, 48, 48)
    local frame3 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(239, 275, 48, 48)
    local frame4 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(296, 285, 36, 40)
    local frame5 = cc.SpriteFrame:createWithTexture(textureDog, rect)

    local animation = cc.Animation:createWithSpriteFrames({frame0,frame1,frame2,frame3,frame5}, 0.2)
    local animate = cc.Animate:create(animation);

    if spriteChar then
        spriteChar:runAction(cc.RepeatForever:create(animate))
    end
end

function GameScene:archerDie(spriteChar)
    local textureDog = cc.Director:getInstance():getTextureCache():addImage("archer1.png")
    local rect = cc.rect(389, 6, 39, 44)
    local frame0 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(441, 9, 40, 38)
    local frame1 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(272, 9, 41, 43)
    local frame2 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(323, 19, 56, 33)
    local frame3 = cc.SpriteFrame:createWithTexture(textureDog, rect)

    local animation = cc.Animation:createWithSpriteFrames({frame0,frame1,frame2,frame3}, 0.2)
    local animate = cc.Animate:create(animation);
    --local x = 0
    --local y = -10
    --local vec2 = cc.vec2(x, y)
    --local move = cc.MoveBy:create(1, vec2)
    --local sequence = cc.Sequence:create(animate, move)

    if spriteChar then
        spriteChar:runAction(animate)
    end
end

function GameScene:archerHit(spriteChar)
    local textureDog = cc.Director:getInstance():getTextureCache():addImage("archer1.png")
    local rect = cc.rect(389, 6, 39, 44)
    local frame0 = cc.SpriteFrame:createWithTexture(textureDog, rect)

    --local blinkAction = cc.Blink:create(3, 24)

    if spriteChar then
        spriteChar:setSpriteFrame(frame0)
        --spriteChar:runAction(blinkAction)
    end
end

function GameScene:archerWin(spriteChar)
    local textureDog = cc.Director:getInstance():getTextureCache():addImage("archer1.png")
    local rect = cc.rect(325, 135, 26, 50)
    local frame0 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    local rect = cc.rect(361, 135, 32, 50)
    local frame1 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    local rect = cc.rect(401, 135, 34, 50)
    local frame2 = cc.SpriteFrame:createWithTexture(textureDog, rect)

    local animation = cc.Animation:createWithSpriteFrames({frame0,frame1,frame2}, 0.2)
    local animate = cc.Animate:create(animation);

    if spriteChar then
        spriteChar:runAction(animate)
    end
end

function GameScene:skeletonMove(spriteSkeleton)
    local textureSprite = cc.Director:getInstance():getTextureCache():addImage("skeleton_sprites.png")
    local rect = cc.rect(99, 0, 38, 48)
    local frame0 = cc.SpriteFrame:createWithTexture(textureSprite, rect)
    rect = cc.rect(143, 0, 38, 48)
    local frame1 = cc.SpriteFrame:createWithTexture(textureSprite, rect)
    rect = cc.rect(184, 0, 38, 48)
    local frame2 = cc.SpriteFrame:createWithTexture(textureSprite, rect)
    rect = cc.rect(225, 0, 38, 48)
    local frame3 = cc.SpriteFrame:createWithTexture(textureSprite, rect)
    rect = cc.rect(263, 0, 38, 48)
    local frame4 = cc.SpriteFrame:createWithTexture(textureSprite, rect)
    rect = cc.rect(305, 0, 38, 48)
    local frame5 = cc.SpriteFrame:createWithTexture(textureSprite, rect)
    rect = cc.rect(345, 0, 38, 48)
    local frame6 = cc.SpriteFrame:createWithTexture(textureSprite, rect)
    rect = cc.rect(389, 0, 38, 48)
    local frame7 = cc.SpriteFrame:createWithTexture(textureSprite, rect)
    rect = cc.rect(429, 0, 38, 48)
    local frame8 = cc.SpriteFrame:createWithTexture(textureSprite, rect)

    local animation = cc.Animation:createWithSpriteFrames({frame2,frame3,frame4,frame5,frame6,frame4,frame3,frame7,frame8}, 0.1)
    local animate = cc.Animate:create(animation)

    if spriteSkeleton then
        spriteSkeleton:runAction(cc.RepeatForever:create(animate))
    end
end

function GameScene:skeletonAttack(spriteSkeleton)
    -- Skeleton hit animation
    local textureDog = cc.Director:getInstance():getTextureCache():addImage("skeleton_sprites.png")
    local rect = cc.rect(5, 56, 37, 41)
    local frame0 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(52, 52, 35, 48)
    local frame1 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(93, 50, 31, 53)
    local frame2 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(130, 51, 51, 52)
    local frame3 = cc.SpriteFrame:createWithTexture(textureDog, rect)

    local animation = cc.Animation:createWithSpriteFrames({frame0,frame1,frame2,frame3}, 0.1)
    local animate = cc.Animate:create(animation);

    if spriteSkeleton then
        spriteSkeleton:runAction(cc.RepeatForever:create(animate))
    end
end

function GameScene:skeletonDie(spriteSkeleton)
    local fadeOut = cc.FadeOut:create(1)

    if spriteSkeleton then
        spriteSkeleton:runAction(fadeOut)
    end
end

function GameScene:arrowRotation(spriteArrow)
    if spriteArrow.facing == 1 then
        local x, y = spriteArrow:getPosition()
        local rotateAction = cc.RotateBy:create(0.5, 30)
        spriteArrow:runAction(rotateAction)
        spriteArrow:setPosition(x, y)
    else
        local x, y = spriteArrow:getPosition()
        local rotateAction = cc.RotateBy:create(0.5, -30)
        spriteArrow:runAction(rotateAction)
        spriteArrow:setPosition(x, y)
    end
end

return GameScene