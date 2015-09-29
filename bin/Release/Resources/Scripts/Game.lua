print("start game")

--SOUND RESOURCES
hitSounds = scan((path.."Resources/Sound/Hit/"));
swingSounds = scan((path.."Resources/Sound/Swing/"));
MusicSounds = scan((path.."Resources/Sound/Music/"));
for i=1,#hitSounds do
    hitSounds[i]=Resource:loadFromFile("Sound",hitSounds[i])
end
for i=1,#swingSounds do
    swingSounds[i]=Resource:loadFromFile("Sound",swingSounds[i])
end
for i=1,#MusicSounds do
    MusicSounds[i]=Resource:loadFromFile("SoundStream",MusicSounds[i])
end
--IMAGE RESOURCES
bloodTextures = scan((path.."Resources/Textures/Blood/"))
for i=1,#bloodTextures do
    bloodTex = Resource:loadFromFile("glTexture",bloodTextures[i])
    bloodTex:setTarget(GL_TEXTURE_2D);
    bloodTex:setTextureProperty(GL_TEXTURE_WRAP_S,GL_REPEAT);
    bloodTex:setTextureProperty(GL_TEXTURE_WRAP_T,GL_REPEAT);
    bloodTex:setTextureProperty(GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR);
    bloodTex:setTextureProperty(GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    bloodTex:loadTexture();
    bloodTextures[i]=bloodTex
end
disptex = Resource:loadFromFile("glTexture",path.."Resources/Textures/bar.png")
disptex:setTarget(GL_TEXTURE_2D);
disptex:setTextureProperty(GL_TEXTURE_WRAP_S,GL_REPEAT);
disptex:setTextureProperty(GL_TEXTURE_WRAP_T,GL_REPEAT);
disptex:setTextureProperty(GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR);
disptex:setTextureProperty(GL_TEXTURE_MAG_FILTER,GL_LINEAR);
disptex:loadTexture();
bTex = Resource:loadFromFile("glTexture",path.."Resources/Textures/background.png")
bTex:setTarget(GL_TEXTURE_2D);
bTex:setTextureProperty(GL_TEXTURE_WRAP_S,GL_REPEAT);
bTex:setTextureProperty(GL_TEXTURE_WRAP_T,GL_REPEAT);
bTex:setTextureProperty(GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR);
bTex:setTextureProperty(GL_TEXTURE_MAG_FILTER,GL_LINEAR);
bTex:loadTexture();
badguyTex = Resource:loadFromFile("glTexture",path.."Resources/Textures/badguy.png")
badguyTex:setTarget(GL_TEXTURE_2D);
badguyTex:setTextureProperty(GL_TEXTURE_WRAP_S,GL_REPEAT);
badguyTex:setTextureProperty(GL_TEXTURE_WRAP_T,GL_REPEAT);
badguyTex:setTextureProperty(GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR);
badguyTex:setTextureProperty(GL_TEXTURE_MAG_FILTER,GL_LINEAR);
badguyTex:loadTexture();
swordTex = Resource:loadFromFile("glTexture",path.."Resources/Textures/swordUP.png")
swordTex:setTarget(GL_TEXTURE_2D);
swordTex:setTextureProperty(GL_TEXTURE_WRAP_S,GL_REPEAT);
swordTex:setTextureProperty(GL_TEXTURE_WRAP_T,GL_REPEAT);
swordTex:setTextureProperty(GL_TEXTURE_MIN_FILTER,GL_LINEAR);
swordTex:setTextureProperty(GL_TEXTURE_MAG_FILTER,GL_LINEAR_MIPMAP_LINEAR);
swordTex:loadTexture();
charTex = Resource:loadFromFile("glTexture",path.."Resources/Textures/char.png")
charTex:setTarget(GL_TEXTURE_2D);
charTex:setTextureProperty(GL_TEXTURE_WRAP_S,GL_REPEAT);
charTex:setTextureProperty(GL_TEXTURE_WRAP_T,GL_REPEAT);
charTex:setTextureProperty(GL_TEXTURE_MIN_FILTER,GL_LINEAR);
charTex:setTextureProperty(GL_TEXTURE_MAG_FILTER,GL_LINEAR_MIPMAP_LINEAR);
charTex:loadTexture();
wait()
print(Clock())
math.randomseed(Clock())

--- Create new Objects
swordSpeaker = Instance:new("Speaker",root)
hitSpeaker = Instance:new("Speaker",root)
musicSpeaker = Instance:new("Speaker",root)
musicSpeaker.Buffer= MusicSounds[math.random(1,#MusicSounds)]
musicSpeaker:Play(true)
dispUI = Instance:new("UI",root);
dispUI.Name = "yellow box"
dispUI.Size = vec4(.25,0,.5,0);
dispUI.Position = vec4(0,0,.5,0);
dispUI.Color=vec4(1,1,0,1);
dispUI.zIndex=-2
dispUI:setTexture(disptex)
dispUIval = Instance:new("IntValue",dispUI);
dispUIval.Name  = "Value"
dispUIval.Value =  gClock();

background = Instance:new("UI",root)
background.Name = "Background"
background.Size = vec4(2,0,1,0)
background.Color = vec4(1,1,1,1)
background.Position=vec4(-1,0,0,0);
background.textureScale= vec2(2,1)
background.zIndex=2
background:setTexture(bTex);

character = Instance:new("UI",root);
character.Name = "Character"
character.Size = vec4(.1,0,.3,0);
character.Position = vec4(-.8,0,0,0);
character.Color=vec4(1,1,1,1);
character.zIndex=1
character:setTexture(charTex)


moving = Instance:new("IntValue",character)
moving.Name = "Moving"
moving.Value = 0

space = Instance:new("IntValue",character)
space.Name = "space"
space.Value = 0

BloodSpots = Instance:new("IntValue",root)
BloodSpots.Name = "BloodSpots"
BloodSpots.Value = 0

spacePressed = Instance:new("IntValue",character)
spacePressed.Name = "spacePressed"
spacePressed.Value = 0

Sword = Instance:new("UI",character);
Sword.Name = "Sword"
Sword.Size = vec4(.5,0,.5,0);
Sword.Position = vec4(1,0,0,0);
Sword.Color=vec4(1,1,1,1);
Sword.zIndex=0
Sword:setTexture(swordTex)


badGuyStorage = Instance:new("Object",root);
badGuyStorage.Name = "badGuyStorage"


wait()

badguycount=0
TimelastSpawned=0
badGuySpeed = 1
goodGuySpeed = 2
print(this)
function newBlood(numBlood,pos)
    for i=0,numBlood do
        bloodUI = Instance:new("UI",root)
        bloodUI.Name = "blood"..BloodSpots.Value
        bloodUI.Size = vec4(0,0,0,0)
        bloodUI.Position = vec4(math.random(-50,50)/100,0,math.random(-50,50)/100,0)
        if(pos~=nil) then
            bloodUI.Position = pos
        end
        bloodUI.Color = vec4(1,1,1,.7)
        bloodUI:setTexture(bloodTextures[math.random(1,#bloodTextures)])
        bloodUI.zIndex=-1
        bloodUIScript = Instance:new("LuaScript",bloodUI)

        bloodUIScript:loadString([[t=gClock()
                                   b=this.Parent
                                   while(gClock()-t<100) do
                                        wait()
                                        newsize = (gClock()-t)/200
                                        b.Size = vec4(newsize,0,newsize,0)
                                   end
                                   while(b.Color.a>0)do
                                     b.Color = b.Color-vec4(0,0,0,.5/FPS)
                                     b.Position = b.Position-vec4(0,0,.5/FPS,0)
                                     wait()
                                   end
                                   root:removeChild(b)]])
        BloodSpots.Value = BloodSpots.Value+1
    end
end
function newBadGuy()
    badGuy = Instance:new("UI",badGuyStorage)
    badGuy.Name = "badguy"..badguycount
    badGuy.Size = vec4(.2,0,.3,0)
    badGuy.Position = vec4(1.1,0,math.random(-100,100)/100,0)
    badGuy.Color = vec4(1,1,1,1)
    badGuy:setTexture(badguyTex)
    badguycount = badguycount+1
    Time = Instance:new("IntValue",badGuy)
    Time.Name = "Time"
    Time.Value = gClock()
end
function isCollided(ui1, ui2)
    return math.abs(ui1.Position.x-ui2.Position.x)<.1 and math.abs(ui1.Position.z-ui2.Position.z)<.25

end

function hasChild(a,b)
    for i,v in pairs(a:getChildren()) do
        if(v==b) then
            return true;
        end
    end
    return false;
end
function onkey(key)
    pressed = key.key.keysym.sym
    if pressed==32 and space.Value ==0 then
        space.Value=1
        spacePressed.Value = gClock()
        swordSpeaker.Buffer = (swingSounds[math.random(1,#swingSounds)])
        swordSpeaker:Play(false)
    elseif pressed == KEY_UP then
        moving.Value = 1
    elseif pressed == KEY_DOWN then
        moving.Value = -1
    end
end
function upkey(key)
    pressed = key.key.keysym.sym
    if pressed == KEY_UP or pressed == KEY_DOWN then
        moving.Value = 0
    elseif pressed ==32 then
        space.Value=0
    end
end

Controller:addEvent(upkey,EVENT_KeyUp)
Controller:addEvent(onkey,EVENT_KeyDown)
while true do
    if gClock()-TimelastSpawned>1000 then
        newBadGuy()
        TimelastSpawned=gClock()
    end
    for i,v in pairs(badGuyStorage:getChildren()) do
        if(isCollided(v,character) and space.Value==1) then
            hitSpeaker.Buffer = (hitSounds[math.random(1,#hitSounds)])
            hitSpeaker:Play(false)
            newBlood(1,v.Position)
            badGuyStorage:removeChild(v)
            dispUIval.Value = gClock()
        end
        if v.Position.x<=-1 then
            badGuyStorage:removeChild(v)
        else
            timeDif = gClock()-v:findFirstChild("Time").Value
            v.Position = v.Position+vec4(-badGuySpeed/FPS,0,0,0)--vec4(1-timeDif/badGuySpeed,0,v.Position.z,0)
        end
    end

    msToDie = math.max(5000-(gClock()/10),10)
    HealthBar = 1-(gClock()-dispUIval.Value)/msToDie --Percent health left
    if HealthBar <= 0 then
        print("you lost jackass")
        quit()
    end
    col = vec3(math.min((1-HealthBar),1),math.max(HealthBar,0),0):normalize()
    dispUI.Color = vec4(col.x,col.y,col.z,1)
    dispUI.Position = vec4(-1+.25*HealthBar,0,.9,0)
    dispUI.Size = vec4(.25*HealthBar,0,.1,0)
    character.Position = character.Position+vec4(0,0,moving.Value*goodGuySpeed/FPS,0)
    background.Position = background.Position-vec4(badGuySpeed/FPS,0,0,0)
    if(gClock()-spacePressed.Value>100) then
        space.Value=0
    end
    if space.Value==1 then
        Sword.Rotation = -90
        Sword.Position = vec4(1,0,-.5,0);
    else
        Sword.Rotation = 0
        Sword.Position = vec4(1,0,0,0);
    end
    if(background.Position.x<=-1) then
        background.Position = vec4(1,0,0,0)
    end
    musicSpeaker:Update()
    wait()
end


