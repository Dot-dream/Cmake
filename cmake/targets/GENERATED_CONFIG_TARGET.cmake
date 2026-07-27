cmake_minimum_required(VERSION 3.16)



set(sources
    ${PROJ_DIR}/board/RamInit0.S
    ${PROJ_DIR}/board/RamInit1.c
    ${PROJ_DIR}/board/RamInit2.c
    ${PROJ_DIR}/board/Mcu_Cfg.c
    ${PROJ_DIR}/board/Mcu_PBcfg.c
    ${PROJ_DIR}/board/Can_Cfg.c
    ${PROJ_DIR}/board/Can_PBcfg.c
    ${PROJ_DIR}/board/Port_Cfg.c
    ${PROJ_DIR}/board/Port_PBcfg.c
    ${PROJ_DIR}/board/IntCtrl_Lld_Cfg.c
    ${PROJ_DIR}/board/Mpu_Lld_Cfg.c
    ${PROJ_DIR}/board/Platform_Cfg.c
    ${PROJ_DIR}/board/Platform_Mld_Cfg.c
    ${PROJ_DIR}/board/startup.S
    ${PROJ_DIR}/board/vector.S
    ${PROJ_DIR}/board/vector_table_copy.c
    ${PROJ_DIR}/board/system.c
)
set(includes
    ${PROJ_DIR}/board
)
set(priIncludes
)

add_library(GENERATED_CONFIG_TARGET STATIC ${sources})

target_include_directories(GENERATED_CONFIG_TARGET PUBLIC ${includes})


target_include_directories(GENERATED_CONFIG_TARGET PRIVATE ${priIncludes})
configcore(GENERATED_CONFIG_TARGET ${CMAKE_SOURCE_DIR})

target_compile_definitions(GENERATED_CONFIG_TARGET PUBLIC
    YTM32B1MD1
    CPU_YTM32B1MD1
)
target_compile_options(GENERATED_CONFIG_TARGET PUBLIC
    -fdiagnostics-color=always
)



target_link_libraries(GENERATED_CONFIG_TARGET
    GENERATED_SDK_TARGET
)
