cmake_minimum_required(VERSION 3.16)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# =====================================================
# 项目配置 — 换芯片时改这 3 个变量
# =====================================================
set(PROJ_DIR      ${CMAKE_SOURCE_DIR})
set(ARM_CPU       "cortex-m33"   CACHE STRING "Target CPU core")
set(DEVICE_NAME   "YTM32B1MD1"   CACHE STRING "MCU model")

project(${DEVICE_NAME})

# =====================================================
# 载入构建模版
# =====================================================
include(${CMAKE_SOURCE_DIR}/cmake/config.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/targets/GENERATED_CONFIG_TARGET.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/targets/GENERATED_SDK_TARGET.cmake)

# =====================================================
# 可执行文件
# =====================================================
set(project_elf ${DEVICE_NAME}.elf)
add_executable(${project_elf} app/main.c)

target_include_directories(${project_elf} PRIVATE app)

target_compile_definitions(${project_elf} PUBLIC
    "${DEVICE_NAME}"
    "CPU_${DEVICE_NAME}"
)

# 链接 MCAL 静态库 + 链接脚本
target_link_libraries(${project_elf}
    "-Wl,--whole-archive" GENERATED_CONFIG_TARGET GENERATED_SDK_TARGET "-Wl,--no-whole-archive"
)

configcore(${project_elf} ${CMAKE_SOURCE_DIR})

if (CORTEXM)
    compilerSpecificPlatformConfigAppForM(${project_elf} ${CMAKE_SOURCE_DIR})
endif()

target_link_libraries(${project_elf}
    "--entry=Reset_Handler;-T${PROJ_DIR}/board/yt_linker.ld"
)
