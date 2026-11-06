# --- crt1/CMakeLists.txt ---

# 1. Dynamically identify and mock the missing config.h
set(MOCK_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/mock_include")
file(MAKE_DIRECTORY "${MOCK_CONFIG_DIR}")
if(NOT EXISTS "${MOCK_CONFIG_DIR}/config.h")
    file(WRITE "${MOCK_CONFIG_DIR}/config.h" "/* Automatically generated fallback config */\n#define HAVE_COMPILER_TLS 0\n")
endif()

# 2. Extract and format the targeted MCU for the IOSYMFILE macro
# Converts 'atmega328p' to "macros/atmega328p.S" or "iosym/atmega328p.S"
string(TOLOWER "${MCU}" MCU_LOWER)

# Search your local tree to find where avr-libc holds its target files
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/iosym/${MCU_LOWER}.S")
    set(IOSYM_PATH "\"iosym/${MCU_LOWER}.S\"")
elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/macros/${MCU_LOWER}.S")
    set(IOSYM_PATH "\"macros/${MCU_LOWER}.S\"")
else()
    # Fallback default if local files are missing: pull directly from system compiler files
    set(IOSYM_PATH "<avr/io.h>")
endif()

# 3. Locate source assembly files
file(GLOB CRT_SOURCES CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/*.S" "${CMAKE_CURRENT_SOURCE_DIR}/*.s")

if(NOT CRT_SOURCES)
    message(FATAL_ERROR "No startup assembly files found in crt1/ directory!")
endif()

# 4. Generate the target object
add_library(avr_crt1 OBJECT ${CRT_SOURCES})

# 5. Inject the missing Preprocessor definitions directly into the compiler
target_compile_definitions(avr_crt1 PRIVATE
    IOSYMFILE=${IOSYM_PATH}
    __AVR_LIBC_BUILD__
)

# 6. Include directories for our mocked headers and target include structures
target_include_directories(avr_crt1 PRIVATE 
    ${MOCK_CONFIG_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/include
)

# 7. Apply strict assembly flags
target_compile_options(avr_crt1 PRIVATE 
    -nostdlib 
    -fno-builtin
    -x assembler-with-cpp
)

set_target_properties(avr_crt1 PROPERTIES OUTPUT_NAME "crt1")

