# Relies on Tests.cmake having been included first (Catch2 package + catch_discover_tests).

function(pamplejuce_add_benchmarks)
    set(oneValueArgs TARGET DIRECTORY PLUGIN_TARGET SHARED_CODE SOURCE_INCLUDE_DIR)
    cmake_parse_arguments(PJ_BENCH "" "${oneValueArgs}" "" ${ARGN})

    if (NOT PJ_BENCH_TARGET)
        set(PJ_BENCH_TARGET Benchmarks)
    endif ()
    if (NOT PJ_BENCH_DIRECTORY)
        set(PJ_BENCH_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/benchmarks")
    endif ()
    if (NOT PJ_BENCH_PLUGIN_TARGET)
        set(PJ_BENCH_PLUGIN_TARGET "${PROJECT_NAME}")
    endif ()
    if (NOT PJ_BENCH_SHARED_CODE)
        set(PJ_BENCH_SHARED_CODE SharedCode)
    endif ()
    if (NOT PJ_BENCH_SOURCE_INCLUDE_DIR)
        set(PJ_BENCH_SOURCE_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/source")
    endif ()

    file(GLOB_RECURSE BenchmarkFiles CONFIGURE_DEPENDS "${PJ_BENCH_DIRECTORY}/Catch2Main.cpp" "${PJ_BENCH_DIRECTORY}/*.h")

    # Organize the test source in the Tests/ folder in the IDE
    source_group(TREE ${PJ_BENCH_DIRECTORY} PREFIX "" FILES ${BenchmarkFiles})

    add_executable(${PJ_BENCH_TARGET} ${BenchmarkFiles})
    target_compile_features(${PJ_BENCH_TARGET} PRIVATE cxx_std_20)
    catch_discover_tests(${PJ_BENCH_TARGET})

    # Our benchmark executable also wants to know about our plugin code...
    target_include_directories(${PJ_BENCH_TARGET} PRIVATE ${PJ_BENCH_SOURCE_INCLUDE_DIR})

    # Copy over compile definitions from our plugin target so it has all the JUCEy goodness
    target_compile_definitions(${PJ_BENCH_TARGET} PRIVATE $<TARGET_PROPERTY:${PJ_BENCH_PLUGIN_TARGET},COMPILE_DEFINITIONS>)

    # And give tests access to our shared code
    target_link_libraries(${PJ_BENCH_TARGET} PRIVATE ${PJ_BENCH_SHARED_CODE} Catch2::Catch2)

    # Make an Xcode Scheme for the test executable so we can run tests in the IDE
    set_target_properties(${PJ_BENCH_TARGET} PROPERTIES XCODE_GENERATE_SCHEME ON)

    # When running Tests we have specific needs
    target_compile_definitions(${PJ_BENCH_TARGET} PUBLIC
        JUCE_MODAL_LOOPS_PERMITTED=1 # let us run Message Manager in tests
        RUN_PAMPLEJUCE_TESTS=1 # also run tests in module .cpp files guarded by RUN_PAMPLEJUCE_TESTS
    )
endfunction()

# Legacy single-product consumers get today's exact behavior at include time.
if (NOT PAMPLEJUCE_MULTI_PRODUCT)
    pamplejuce_add_benchmarks()
endif ()
