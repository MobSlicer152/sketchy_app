#pragma once

#include <errno.h>
#include <inttypes.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "SDL.h"
#include "lvgl.h"

#ifdef __ANDROID__
#include <android/log.h>
#endif

//
// Log a message
//

#ifdef __ANDROID__
#define LogMessage(Level, ...) __android_log_print(ANDROID_LOG_##Level, \
                                                   "SketchyApp", __VA_ARGS__)
#endif

//
// Gets a string for the current errno value
//

#define ErrnoString() strerror(errno)

//
// Gets the number of elements in an array
//

#define ArraySize(Array) (sizeof(Array) / sizeof((Array)[0]))

//
// Global app state
//

typedef struct _APP_STATE
{
    bool Running;

    SDL_Window* Window;
    int Width;
    int Height;

    SDL_Renderer* Renderer;

    bool Active;
} APP_STATE, *PAPP_STATE;

extern APP_STATE State;

