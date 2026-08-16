# HEADS UP: Pamplejuce assumes anything you stick in the assets folder you want to included in your binary!
# This makes life easy, but will bloat your binary needlessly if you include unused files

function(pamplejuce_add_assets)
    set(oneValueArgs TARGET DIRECTORY)
    cmake_parse_arguments(PAMP_ASSETS "" "${oneValueArgs}" "" ${ARGN})

    if (NOT PAMP_ASSETS_TARGET)
        set(PAMP_ASSETS_TARGET Assets)
    endif ()
    if (NOT PAMP_ASSETS_DIRECTORY)
        set(PAMP_ASSETS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/assets")
    endif ()

    file(GLOB_RECURSE AssetFiles CONFIGURE_DEPENDS "${PAMP_ASSETS_DIRECTORY}/*")
    list (FILTER AssetFiles EXCLUDE REGEX "/\\.DS_Store$") # We don't want the .DS_Store on macOS though...

    # Setup our binary data as a target called Assets
    juce_add_binary_data(${PAMP_ASSETS_TARGET} SOURCES ${AssetFiles})

    # Required for Linux happiness:
    # See https://forum.juce.com/t/loading-pytorch-model-using-binarydata/39997/2
    set_target_properties(${PAMP_ASSETS_TARGET} PROPERTIES POSITION_INDEPENDENT_CODE TRUE)
endfunction()

# Legacy single-product consumers get today's exact behavior at include time.
if (NOT _PAMPLEJUCE_USE_FUNCTIONS AND NOT PAMPLEJUCE_MULTI_PRODUCT)
    pamplejuce_add_assets()
endif ()
