#include <map>
#include <string>
#include "GLOBAL.h"
#include <Windows.h>

#include "CombinedController.h"

#include "InstanceFactory.h"
#include "ResourceFactory.h"

#include "GameShader.h"
#include "Model.h"
#include "LuaScript.h"
#include "glTexture.h"
#include "Sound.h"

#include "Speaker.h"
#include "UI.h"
#include "ValueClasses.h"





std::string path;
bool running = true;
Object root;
CombinedController* engineController;
lua_State* l;
ResourceFactory RF;
InstanceFactory IF;
GameShader UIShader;
Model* planeModel;
UI defaultUI;
float curtime=0;

void resizeViewport(SDL_Event e)
{

    if(e.window.event==SDL_WINDOWEVENT_RESIZED)
    {
        glViewport(0,0,e.window.data1,e.window.data2);
    }
}

std::vector<std::string> getFilesInPath(std::string folder)
{
    std::vector<std::string> names;
    char search_path[200];
    sprintf(search_path, "%s*.*", folder.c_str());
    WIN32_FIND_DATA fd;
    HANDLE hFind = ::FindFirstFile(search_path, &fd);
    if(hFind != INVALID_HANDLE_VALUE)
    {
        do
        {
            // read all (real) files in current folder, delete '!' read other 2 default folder . and ..
            if(! (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) )
            {
                names.push_back(folder+fd.cFileName);
            }
        }while(::FindNextFile(hFind, &fd));
        ::FindClose(hFind);
    }
    return names;
}
int getFilesInPathLua(lua_State *l)
{
    luabridge::LuaRef arg = luabridge::LuaRef::fromStack(l,1);
    luabridge::LuaRef table = luabridge::newTable(l);
    if(arg.isString())
    {
        std::vector<std::string> files = getFilesInPath(arg.cast<std::string>());
        for(int i=0;i<files.size();i++)
            table[i+1] = files[i];
        luabridge::push(l,table);
        return 1;
    }
    return 0;
}
template<class t> void getRenderables(Object* p,std::vector<t*> &returnVec)
{
    for(int i=0;i<p->getChildArray().size();i++)
    {
        Object* renderUI =(Object*)p->getChildArray()[i];
        if(renderUI!=NULL)
        {
            if(renderUI->type() == t::TypeID())
            {
                returnVec.push_back((t*)renderUI);
            }
        }
        if(renderUI->getChildArray().size()>0)
            getRenderables<t>(renderUI,returnVec);
    }
}
bool compare(UI* a, UI* b)
{
    return a->getZIndex()>b->getZIndex();
}
void deepRender(Object* obj)
{
    std::vector<UI*> renderables;
    getRenderables<UI>(obj,renderables);
    std::sort(renderables.begin(),renderables.end(),compare);
    for(int i=0;i<renderables.size();i++)
        renderables[i]->Render(&UIShader);
}
void quit()
{
    running=false;
}
float gameClock(){
    return curtime;
}
int main(int argc, char *argv[])
{
    path = (std::string)SDL_GetBasePath();
    GLOBAL::Init();
    SDL_Init(SDL_INIT_EVERYTHING);
    IMG_Init(IMG_INIT_JPG|IMG_INIT_PNG);



    engineController = new CombinedController(100,100,512,512,SDL_WINDOW_OPENGL| SDL_WINDOW_RESIZABLE);
    engineController->setTitle("Sword");
    engineController->addEvent(resizeViewport,SDL_WINDOWEVENT);
    engineController->makeCurrent();
    root.setName("ROOT");
    UIShader.loadFromFile(path+"Resources/Shaders/MultiShader2D.glsl");
    UIShader.LinkProgram();
    UIShader.setProjectionMatrix(glm::ortho(-engineController->getSize().x,engineController->getSize().x,-engineController->getSize().y,engineController->getSize().y,-1.f,100.f));
    planeModel = RF.loadFromFile<Model>(path+"Resources/3D/cube.obj");
    defaultUI.setMesh(planeModel);
    defaultUI.setPosition(glm::vec4(0,0,0,0));
    defaultUI.setSize(glm::vec4(1,0,1,0));
    defaultUI.setWindow(engineController);
    IF.setDefaultObject(&defaultUI);

    l = luaL_newstate();
    luaopen_io(l);
    luaopen_base(l);
    luaopen_table(l);
    luaopen_string(l);
    luaopen_math(l);
    luaL_openlibs(l);
    KeyController::RegisterLua(l);
    LuaScript::RegisterLua(l);
    InstanceFactory::RegisterLua(l);
    ResourceFactory::RegisterLua(l);
    UI::RegisterLua(l);
    ObjectValue::RegisterLua(l);
    IntValue::RegisterLua(l);
    glTexture::RegisterLua(l);
    Speaker::RegisterLua(l);

    luabridge::setGlobal(l,&root,"root");
    luabridge::setGlobal(l,&IF,"Instance");
    luabridge::setGlobal(l,&RF,"Resource");
    luabridge::setGlobal(l,path,"path");
    luabridge::setGlobal(l,((KeyController*)engineController),"Controller");
    luabridge::getGlobalNamespace(l).addFunction("quit",quit).addFunction("gClock",gameClock).addCFunction("scan",getFilesInPathLua);
    std::vector<std::string> paths = getFilesInPath(path+"Resources/Scripts/");
    for(int i=0;i<paths.size();i++)
    {
        LuaScript *lsc = new LuaScript(&root);
        lsc->setState(l);
        lsc->loadFromFile(paths[i]);
        lsc->Run();
    }
    float FPS=1;
    while(running)
    {
        engineController->CheckKeys();
        Uint64 t = SDL_GetPerformanceCounter();
        luabridge::setGlobal(l,FPS,"FPS");
        std::vector<LuaScript*> scriptGuy;
        getRenderables<LuaScript>(&root,scriptGuy);
        for(int i=0;i<scriptGuy.size();i++)
        {
            LuaScript *scrpt = scriptGuy[i];
            if(scrpt->getState()==NULL)
            {
                scrpt->setState(l);
                scrpt->Run();
            }
            else
            {
                scrpt->Continue();
            }
        }
        UIShader.Activate();
        glClearColor(0,0,0,1);
        glClear(GL_DEPTH_BUFFER_BIT|GL_COLOR_BUFFER_BIT);
        glDisable(GL_DEPTH_TEST);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
        deepRender(&root);
        engineController->Swap();
        float sBetweenFrames =((float)(SDL_GetPerformanceCounter()-t)/((float)SDL_GetPerformanceFrequency()));
        FPS = 1.0/sBetweenFrames;
        curtime+=(sBetweenFrames*1000);
    }
    IMG_Quit();
    SDL_Quit();
    return 0;
}

