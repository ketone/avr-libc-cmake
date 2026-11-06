# Recursively find all C and Assembly source files in all subfolders
file(GLOB_RECURSE LIBM_SOURCES 
    CONFIGURE_DEPENDS 
    "${CMAKE_CURRENT_SOURCE_DIR}/*.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.S"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.s"
)

# Guard against empty directories
list(LENGTH LIBM_SOURCES LIBM_COUNT)
if(LIBM_COUNT EQUAL 0)
    message(FATAL_ERROR "No source files found inside libm/ or its subdirectories!")
endif()

# Create the static library target
add_library(m STATIC ${LIBM_SOURCES})

# AVR specific assembly preprocessing flag
target_compile_options(m PRIVATE $<$<COMPILE_LANGUAGE:ASM>:-x assembler-with-cpp>)

