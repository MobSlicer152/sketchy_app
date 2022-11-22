cmake_minimum_required(VERSION 3.22)

include(cmake/Platform.cmake)

set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

project(SketchyApp VERSION 1.0.0 LANGUAGES C CXX)

if (ANDROID)
	find_package(Java 11)
endif()

include_directories(${CMAKE_SOURCE_DIR}
		    deps/lvgl
		    ${CMAKE_BINARY_DIR}/deps/sdl2/include)

set(SDL_SHARED OFF CACHE BOOL "" FORCE)
set(SDL_STATIC_PIC ON CACHE BOOL "" FORCE)
add_subdirectory(deps/sdl2)

set(SKETCHY_APP_HEADERS ${CMAKE_SOURCE_DIR}/sketchyapp.h)
set(SKETCHY_APP_SOURCES ${CMAKE_SOURCE_DIR}/sketchyapp.c)

set(APP_ID "sketchy_app")
set(APP_JAVA_ID "ca.randomcode.sketchy_app")
set(APP_UPPER_ID "SketchyApp")
set(APP_DISPLAY_NAME "Sketchy App")
set(APP_DESCRIPTION "A sketchy mobile app written mostly in C")
set(APP_VERSION 1.0.0.0)
platform_setup(sketchyapp "${SKETCHY_APP_HEADERS};${SKETCHY_APP_SOURCES}")
target_link_libraries(sketchyapp PRIVATE SDL2-static)

