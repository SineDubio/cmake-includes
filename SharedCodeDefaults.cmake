function(pamplejuce_shared_code_defaults)
    set(oneValueArgs TARGET)
    cmake_parse_arguments(PJ_SCD "" "${oneValueArgs}" "" ${ARGN})

    if (NOT PJ_SCD_TARGET)
        set(PJ_SCD_TARGET SharedCode)
    endif ()

    if (MSVC)
        # fast math and better simd support in RELEASE
        # https://learn.microsoft.com/en-us/cpp/build/reference/fp-specify-floating-point-behavior?view=msvc-170#fast
        target_compile_options(${PJ_SCD_TARGET} INTERFACE $<$<CONFIG:RELEASE>:/fp:fast>)
        target_compile_options(${PJ_SCD_TARGET} INTERFACE $<$<CONFIG:RELEASE>:/Ox>)
    else ()
        # See the implications here:
        # https://stackoverflow.com/q/45685487
        target_compile_options(${PJ_SCD_TARGET} INTERFACE $<$<CONFIG:RELEASE>:-Ofast>)
        target_compile_options(${PJ_SCD_TARGET} INTERFACE $<$<CONFIG:RelWithDebInfo>:-Ofast>)
    endif ()

    # Tell MSVC to properly report what c++ version is being used
    if (MSVC)
        target_compile_options(${PJ_SCD_TARGET} INTERFACE /Zc:__cplusplus)
    endif ()

    # C++23, please
    # Use cxx_std_23 for C++23 (as of CMake v 3.20)
    target_compile_features(${PJ_SCD_TARGET} INTERFACE cxx_std_23)
endfunction()

# Legacy single-product consumers get today's exact behavior at include time.
if (NOT PAMPLEJUCE_MULTI_PRODUCT)
    pamplejuce_shared_code_defaults()
endif ()
