## Sketchy mobile app
This is a sketchy as hell mobile app (hopefully Android and iOS) written almost entirely in C using SDL.

## Android build
Something like this ought to work if you have the Android SDK and NDK installed:
```shell
cmake -S. -Bbuild -DCMAKE_TOOLCHAIN_FILE="<ANDROID SDK>\ndk\25.1.8937393\build\cmake\android.toolchain.cmake" -DANDROID_SDK="<ANDROID SDK>" -GNinja -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=29
```

