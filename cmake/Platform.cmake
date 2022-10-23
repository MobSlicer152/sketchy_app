#  Platform setup functions for applications
#
#  Copyright 2022 MobSlicer152
#  This file was adapted from my own code but
#  the license is different now

cmake_minimum_required(VERSION 3.15)

# Magic string for no content files
set(NO_CONTENT_STR "NO_CONTENT")

function(platform_setup target sources)
	# Extra sources
	if (ANDROID)
		set(sources ${sources} ${CMAKE_CURRENT_BINARY_DIR}/AndroidManifest.xml ${CMAKE_CURRENT_BINARY_DIR}/strings.xml ${CMAKE_CURRENT_BINARY_DIR}/Entry.java android/AndroidManifest.xml.in android/strings.xml.in android/src/Entry.java.in)
	endif()

	set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
	set(BUILD_STATIC_LIBS ON CACHE BOOL "" FORCE)

	# Create the target
	if (ANDROID)
		add_library(${target} SHARED ${sources})
	else()
		add_executable(${target} ${sources})
	endif()

	# Content files are optional
	if (${ARGC} GREATER 4)
		set(content_files ${ARG5})
	else()
		set(content_files ${NO_CONTENT_STR})
	endif()

	# Platform-specific setup
	if (ANDROID)
		android_setup(${target} ${content_files})
	endif()

	# Install the application
	install(TARGETS ${target}
		RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX})

	# Install assets
	if (NOT ${content_files} STREQUAL ${NO_CONTENT_STR})
		foreach (file ${content_files})
			get_filename_component(dir ${file} DIRECTORY)
			install(FILES ${file}
				DESTINATION ${CMAKE_INSTALL_PREFIX}/${dir})
		endforeach()
	endif()
endfunction()

function(android_setup target content_files)
	if (NOT DEFINED ANDROID_SDK)
		message(FATAL_ERROR "Android SDK location not defined")
	endif()

	set(apk_dir ${CMAKE_CURRENT_BINARY_DIR}/android-project/app/build/outputs/apk)
	set(jni_dir ${CMAKE_CURRENT_BINARY_DIR}/android-project/app/jni)
	set(src_dir ${CMAKE_CURRENT_BINARY_DIR}/android-project/app/src/main)
	set(content_dir ${src_dir}/res)

	if ("${CMAKE_HOST_SYSTEM_NAME}" MATCHES "Windows")
		set(gradle cmd /c gradlew.bat)
	else()
		set(gradle ./gradlew)
	endif()

	configure_file(android/AndroidManifest.xml.in AndroidManifest.xml @ONLY)
	configure_file(android/Android.mk.in Android.mk @ONLY)
	configure_file(android/build.gradle.in build.gradle @ONLY)
	configure_file(android/strings.xml.in strings.xml @ONLY)
	configure_file(android/src/Entry.java.in Entry.java @ONLY)

	string(REPLACE "." "/" java_package "${APP_JAVA_ID}")

	get_filename_component(java_dir ${Java_JAVA_EXECUTABLE} DIRECTORY)
	file(REAL_PATH .. java_home BASE_DIRECTORY ${java_dir})

	add_custom_target(${target}-apk ALL
			  COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/deps/sdl2/android-project ${CMAKE_CURRENT_BINARY_DIR}/android-project
			  COMMAND ${CMAKE_COMMAND} -E rm -rf ${jni_dir}
			  COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_BINARY_DIR}/build.gradle ${CMAKE_CURRENT_BINARY_DIR}/android-project/app/build.gradle
			  COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_BINARY_DIR}/Android.mk ${jni_dir}/Android.mk
			  COMMAND ${CMAKE_COMMAND} -E make_directory ${jni_dir}/${ANDROID_ABI}
			  COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:${target}> ${jni_dir}/${ANDROID_ABI}/$<TARGET_FILE_NAME:${target}>
			  COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_BINARY_DIR}/AndroidManifest.xml ${src_dir}/AndroidManifest.xml
			  COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_BINARY_DIR}/strings.xml ${content_dir}/values/strings.xml
			  COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_BINARY_DIR}/Entry.java ${src_dir}/java/${java_package}/${APP_UPPER_ID}.java
			  COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_CURRENT_BINARY_DIR}/android-project ${CMAKE_COMMAND} -E env ANDROID_SDK_ROOT=${ANDROID_SDK} JAVA_HOME=${java_home} ${gradle} build
			  COMMAND ${CMAKE_COMMAND} -E copy ${apk_dir}/debug/app-debug.apk ${CMAKE_CURRENT_BINARY_DIR}/${target}-debug.apk
			  COMMAND ${CMAKE_COMMAND} -E copy ${apk_dir}/release/app-release-unsigned.apk ${CMAKE_CURRENT_BINARY_DIR}/${target}-release.apk
			  DEPENDS ${target}
			  BYPRODUCTS ${CMAKE_CURRENT_BINARY_DIR}/android-project/app/build)


	if (NOT ${content_files} STREQUAL ${NO_CONTENT_STR})
		foreach(file ${content_files})
			get_filename_component(dir ${file} DIRECTORY)
			add_custom_command(TARGET ${target} POST_BUILD
					   COMMAND ${CMAKE_COMMAND} -E make_directory ${src_dir}/${dir}
					   COMMAND ${CMAKE_COMMAND} -E copy ${file} ${src_dir}/${dir})
		endforeach()
	endif()
endfunction()
