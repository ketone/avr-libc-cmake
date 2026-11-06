# Find all source files in common/ (Handles both .s and .S extensions)
file(GLOB COMMON_SOURCES 
    CONFIGURE_DEPENDS 
    "${CMAKE_CURRENT_SOURCE_DIR}/*.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.S"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.s"
)

# Robust check to see if we actually found files
list(LENGTH COMMON_SOURCES COMMON_COUNT)
if(COMMON_COUNT EQUAL 0)
    message(WARNING "No source files found directly in common/. Creating an empty placeholder target.")
    # Create a dummy source file so CMake doesn't error out if the folder is empty
    set(COMMON_SOURCES "${CMAKE_CURRENT_BINARY_DIR}/dummy.c")
    file(WRITE "${COMMON_SOURCES}" "// Dummy file for empty common directory\n")
endif()

# Build as an OBJECT library for easy target blending
add_library(avr_common OBJECT ${COMMON_SOURCES})

# Expose common directory as a public include path for downstream targets
target_include_directories(avr_common PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

# AVR specific assembly preprocessing flag
target_compile_options(avr_common PRIVATE $<$<COMPILE_LANGUAGE:ASM>:-x assembler-with-cpp>)

