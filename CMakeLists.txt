cmake_minimum_required(VERSION 3.16)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# =====================================================
# CMake 构建模版 — 纯模版，不绑定任何项目结构
# =====================================================
# 用户在自己的 CMakeLists.txt 中：
#   1. set(ARM_CPU "cortex-m33")
#   2. include(path/to/cmake/config.cmake)
#   3. 自行定义 add_library / add_executable

project(example C ASM)

# 载入构建模版
include(${CMAKE_CURRENT_LIST_DIR}/cmake/config.cmake)
