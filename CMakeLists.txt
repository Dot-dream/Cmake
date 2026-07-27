cmake_minimum_required(VERSION 3.16)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

project(example C ASM)

# =====================================================
# 目标芯片配置
# =====================================================
set(ARM_CPU "cortex-m3" CACHE STRING "Target CPU core")

# =====================================================
# 载入构建模版
# =====================================================
include(${CMAKE_CURRENT_LIST_DIR}/cmake/config.cmake)

set(project_elf example.elf)

# =====================================================
# 源文件
# =====================================================
add_executable(${project_elf}
    board/startup_stm32f103.s
    app/main.c
)

target_include_directories(${project_elf} PRIVATE
    app
)

# =====================================================
# ARM 核心配置
# =====================================================
configcore(${project_elf} ${CMAKE_SOURCE_DIR})

if (CORTEXM)
    compilerSpecificPlatformConfigAppForM(${project_elf} ${CMAKE_SOURCE_DIR})
endif()

# =====================================================
# 链接脚本 & 数学库
# =====================================================
target_link_libraries(${project_elf}
    m                                      # math.h (libm)
    "-T${CMAKE_SOURCE_DIR}/board/stm32f103.ld"
)
