cmake_minimum_required(VERSION 3.15)

set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/cmake/avr-toolchain.cmake" CACHE FILEPATH "Toolchain file" FORCE)

project(avrlib_core VERSION 1.0.0 LANGUAGES C ASM)

# Enable compile commands JSON output
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(MCU atmega328p)
set(F_CPU 16000000UL)

if(NOT CMAKE_TOOLCHAIN_FILE)
    message(FATAL_ERROR "You must specify the toolchain file! Use -DCMAKE_TOOLCHAIN_FILE=avr-toolchain.cmake")
endif()

# Global Compiler Optimization and Warning Flags from Autotools
add_compile_options(
    -Os 
    -Wall 
    -Wextra 
    -g 
    -fno-jump-tables
    -Wno-maybe-uninitialized
)

# Global Include Directories accessible to all targets
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/avr-libc/include)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/avr-libc/common)

# Process subdirectories in logical dependency order
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/avr-libc/common)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/avr-libc/crt1)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/avr-libc/libc)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/avr-libc/libm)

# --- Sample Firmware Target Configuration ---

# 1a. Define your executable and source files
set(SOURCES 
    main.c 
    _exit.c
)

# 1b. Add the executable target
add_executable(sample_firmware ${SOURCES})

# 1c. Loop through each source file and append the listing flag
foreach(src_file IN LISTS SOURCES)
    set_source_files_properties(${src_file} PROPERTIES 
        COMPILE_OPTIONS "-Wa,-adhln=${CMAKE_CURRENT_BINARY_DIR}/${src_file}.lst"
    )
endforeach()

# 2. Force bare-metal linking flags
target_link_options(sample_firmware PRIVATE
    -nostdlib                    # Do not use system standard libraries
    -Wl,--gc-sections            # Garbage collect unused code sections to save space
	-Wl,-Map=sample_firmware.map # output memory map file
)

# 3. Explicitly link your custom avrlib components
# Note: $<TARGET_OBJECTS:X> is used to pull the raw compiled .o files directly into the linker
target_link_libraries(sample_firmware PRIVATE
    $<TARGET_OBJECTS:avr_crt1>   # Your custom startup code vectors
    $<TARGET_OBJECTS:avr_common> # Shared codebase tools
    c                            # Static C library
)

# 4. Post-build step: Generate standard Intel HEX file for hardware programmers
add_custom_command(TARGET sample_firmware POST_BUILD
    COMMAND avr-objcopy -O ihex -R .eeprom sample_firmware sample_firmware.hex
    COMMENT "Generating Intel HEX file: sample_firmware.hex"
)

# 5. Post-build step: Print flash memory size usage metrics in the terminal
add_custom_command(TARGET sample_firmware POST_BUILD
    COMMAND avr-size sample_firmware
    COMMENT "Firmware Memory Utilization Status:"
)

