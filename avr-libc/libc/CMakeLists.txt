# Recursively find all C and Assembly source files in all subfolders
file(GLOB_RECURSE LIBC_SOURCES 
    CONFIGURE_DEPENDS 
    "${CMAKE_CURRENT_SOURCE_DIR}/*.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.S"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.s"
)

# Guard against empty directories
list(LENGTH LIBC_SOURCES LIBC_COUNT)
if(LIBC_COUNT EQUAL 0)
    message(FATAL_ERROR "No source files found inside libc/ or its subdirectories!")
endif()

# Create the static library target
add_library(c STATIC ${LIBC_SOURCES})

# AVR specific assembly preprocessing flag
target_compile_options(c PRIVATE $<$<COMPILE_LANGUAGE:ASM>:-x assembler-with-cpp>)

