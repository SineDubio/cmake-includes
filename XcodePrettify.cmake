# MacOS only: Cleans up folder and target organization on Xcode.

function(pamplejuce_xcode_prettify)
    set(oneValueArgs PLUGIN_TARGET SHARED_CODE SOURCE_DIR ASSETS_TARGET)
    set(multiValueArgs FORMATS SOURCES)
    cmake_parse_arguments(PAMP_XP "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (NOT PAMP_XP_PLUGIN_TARGET)
        set(PAMP_XP_PLUGIN_TARGET "${PROJECT_NAME}")
    endif ()
    if (NOT PAMP_XP_SHARED_CODE)
        set(PAMP_XP_SHARED_CODE SharedCode)
    endif ()
    if (NOT PAMP_XP_SOURCE_DIR)
        set(PAMP_XP_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Source")
    endif ()
    if (NOT PAMP_XP_ASSETS_TARGET)
        set(PAMP_XP_ASSETS_TARGET Assets)
    endif ()
    if (NOT PAMP_XP_FORMATS)
        set(PAMP_XP_FORMATS ${FORMATS})
    endif ()
    if (NOT PAMP_XP_SOURCES)
        set(PAMP_XP_SOURCES ${SourceFiles})
    endif ()

    # No, we don't want our source buried in extra nested folders
    set_target_properties(${PAMP_XP_SHARED_CODE} PROPERTIES FOLDER "")

    # The Xcode source tree should uhhh, still look like the source tree, yo
    source_group(TREE ${PAMP_XP_SOURCE_DIR} PREFIX "" FILES ${PAMP_XP_SOURCES})

    # It tucks the Plugin varieties into a "Targets" folder and generate an Xcode Scheme manually
    # Xcode scheme generation is turned off globally to limit noise from other targets
    # The non-hacky way of doing this is via the global PREDEFINED_TARGETS_FOLDER property
    # However that doesn't seem to be working in Xcode
    # Not all plugin types (au, vst) available on each build type (win, macos, linux)
    foreach (target ${PAMP_XP_FORMATS} "All")
        if (TARGET ${PAMP_XP_PLUGIN_TARGET}_${target})
            set_target_properties(${PAMP_XP_PLUGIN_TARGET}_${target} PROPERTIES
                # Tuck the actual plugin targets into a folder where they won't bother us
                FOLDER "Targets"
                # Let us build the target in Xcode
                XCODE_GENERATE_SCHEME ON)

            # Set the default executable that Xcode will open on build
            # Note: you must manually build the AudioPluginHost.xcodeproj in the JUCE subdir
            if ((NOT target STREQUAL "All") AND (NOT target STREQUAL "Standalone"))
                set_target_properties(${PAMP_XP_PLUGIN_TARGET}_${target} PROPERTIES
                    XCODE_SCHEME_EXECUTABLE "${CMAKE_SOURCE_DIR}/JUCE/extras/AudioPluginHost/Builds/MacOSX/build/Debug/AudioPluginHost.app")
            endif ()
        endif ()
    endforeach ()

    if (TARGET ${PAMP_XP_ASSETS_TARGET})
        set_target_properties(${PAMP_XP_ASSETS_TARGET} PROPERTIES FOLDER "Targets")
    endif ()
endfunction()

# Legacy single-product consumers get today's exact behavior at include time.
if (NOT _PAMPLEJUCE_USE_FUNCTIONS)
    pamplejuce_xcode_prettify()
endif ()
