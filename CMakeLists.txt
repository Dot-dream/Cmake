cmake_minimum_required(VERSION 3.16)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# =====================================================
# CMake 构建模版 — 跨项目使用入口
# =====================================================
# 使用方法：在本目录下创建 board/、Mcal/、app/ 等项目目录
# 然后在下方去掉对应 include 注释即可

set(ARM_CPU       "cortex-m33"   CACHE STRING "Target CPU core")
set(DEVICE_NAME   "YTM32B1MD1"   CACHE STRING "MCU device model")

project(${DEVICE_NAME})

# =====================================================
# 载入构建模版
# =====================================================
include(${CMAKE_SOURCE_DIR}/cmake/config.cmake)

# 用户在创建 board/ 和 Mcal/ 项目结构后，取消注释以下行：
# include(${CMAKE_SOURCE_DIR}/cmake/targets/GENERATED_CONFIG_TARGET.cmake)
# include(${CMAKE_SOURCE_DIR}/cmake/targets/GENERATED_SDK_TARGET.cmake)

# =====================================================
# 创建一个最小可执行目标（演示用法）
# =====================================================
# 用户在创建 app/main.c 后，取消注释以下内容：
# set(project_elf ${DEVICE_NAME}.elf)
# add_executable(${project_elf} app/main.c)
# target_include_directories(${project_elf} PRIVATE app)
# target_compile_definitions(${project_elf} PUBLIC "${DEVICE_NAME}" "CPU_${DEVICE_NAME}")
# target_link_libraries(${project_elf}
#     "-Wl,--whole-archive" GENERATED_CONFIG_TARGET GENERATED_SDK_TARGET "-Wl,--no-whole-archive"
# )
# configcore(${project_elf} ${CMAKE_SOURCE_DIR})
# if (CORTEXM)
#     compilerSpecificPlatformConfigAppForM(${project_elf} ${CMAKE_SOURCE_DIR})
# endif()
# target_link_libraries(${project_elf}
#     "--entry=Reset_Handler;-T${CMAKE_SOURCE_DIR}/board/yt_linker.ld"
# )
