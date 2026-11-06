# AVR CMake Toolchain Configuration File
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR avr)

# Force the compiler to AVR-GCC
set(CMAKE_C_COMPILER avr-gcc)
set(CMAKE_CXX_COMPILER avr-g++)
set(CMAKE_ASM_COMPILER avr-gcc)

# Define the target MCU (Defaulting to atmega328p, can be overridden)
if(NOT DEFINED MCU)
    set(MCU "atmega328p" CACHE STRING "AVR Target Microcontroller")
endif()

# Define the target CPU Frequency (Defaulting to 16MHz)
if(NOT DEFINED F_CPU)
    set(F_CPU "16000000UL" CACHE STRING "AVR Target Clock Frequency")
endif()

# Apply absolute mandatory compiler flags for AVR
set(AVR_FLAGS "-mmcu=${MCU} -DF_CPU=${F_CPU}")
set(CMAKE_C_FLAGS "${AVR_FLAGS}" CACHE STRING "C Flags" FORCE)
set(CMAKE_CXX_FLAGS "${AVR_FLAGS}" CACHE STRING "C++ Flags" FORCE)
set(CMAKE_ASM_FLAGS "${AVR_FLAGS} -x assembler-with-cpp" CACHE STRING "ASM Flags" FORCE)

# Adjust toolchain behavior: do not check compiler binaries by compiling host apps
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
