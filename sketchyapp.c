#define RAYGUI_IMPLEMENTATION
#include "sketchyapp.h"

//
// Global app state
//

APP_STATE State;

bool
Update(
    void
    )
/*++

Routine Description:

    Updates the window and global state.

Arguments:

    None.

Return Value:

    bool - true if the application should continue running, else false.

--*/
{
    SDL_Event Event;

    while (SDL_PollEvent(&Event))
    {
        switch (Event.type)
        {
        case SDL_QUIT:
            LogMessage(INFO, "Quit event received");
            return false;
        case SDL_WINDOWEVENT:
            switch (Event.window.type)
            {
            case SDL_WINDOWEVENT_RESIZED:
                LogMessage(INFO, "Resized from %ux%u to %ux%u",
                           State.Width,
                           State.Height,
                           Event.window.data1,
                           Event.window.data2
                           );
                State.Width = Event.window.data1;
                State.Height = Event.window.data2;
                break;
            case SDL_WINDOWEVENT_FOCUS_LOST:
                LogMessage(INFO, "Focus lost");
                State.Active = false;
                break;
            case SDL_WINDOWEVENT_FOCUS_GAINED:
                LogMessage(INFO, "Focus gained");
                State.Active = true;
                break;
            }
            break;
        }
    }

    return true;
}

int32_t
main(
    int argc,
    char* argv[]
    )
/*++

Routine Description:

    Entry point of the application.

Arguments:

    argc -
        Number of command line arguments.

    argv -
        Command line arguments.

Return Value:

    int - 0 on success.

--*/
{
    bool Error;

    Error = false;

    LogMessage(INFO, "Initializing SDL");
    if (SDL_Init(SDL_INIT_VIDEO) < 0)
    {
        LogMessage(ERROR, "Failed to initialize SDL: %s", SDL_GetError());
        Error = true;
        goto Cleanup;
    }

    LogMessage(INFO, "Creating window");
    State.Window = SDL_CreateWindow(
        "Sketchy App",
        0, 0,
        0, 0,
        SDL_WINDOW_FULLSCREEN
        );
    if (!State.Window)
    {
        LogMessage(ERROR, "Failed to create window: %s", SDL_GetError());
        Error = true;
        goto Cleanup;
    }

    LogMessage(INFO, "Creating renderer");
    State.Renderer = SDL_CreateRenderer(
        State.Window,
        -1,
        SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (!State.Renderer)
    {
        LogMessage(ERROR, "Failed to create renderer: %s", SDL_GetError());
        Error = true;
        goto Cleanup;
    }

    LogMessage(INFO, "Entering main loop");
    State.Running = true;
    State.Active = true;
    while (State.Running)
    {
        State.Running = Update();
        SDL_SetRenderDrawColor(State.Renderer, 135, 0, 255, 255);
        SDL_RenderClear(State.Renderer);
    }

Cleanup:
    if (State.Renderer)
    {
        LogMessage(INFO, "Destroying renderer");
        SDL_DestroyRenderer(State.Renderer);
    }

    if (State.Window)
    {
        LogMessage(INFO, "Destroying window");
        SDL_DestroyWindow(State.Window);
    }

    LogMessage(INFO, "Shutting down SDL");
    SDL_Quit();

    LogMessage(INFO, "Exiting");

    if (Error)
        exit(-1);
    else
        return 0;
}

