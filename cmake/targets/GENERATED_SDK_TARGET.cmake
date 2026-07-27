cmake_minimum_required(VERSION 3.16)



set(sources
    ${PROJ_DIR}/Mcal/Mcu/src/Mcu.c
    ${PROJ_DIR}/Mcal/Mcu/src/Mcu_Lld.c
    ${PROJ_DIR}/Mcal/Mcu/src/Mcu_Lld_Irq.c
    ${PROJ_DIR}/Mcal/Rte/src/SchM_Mcu.c
    ${PROJ_DIR}/Mcal/Rte/src/SchM_Can.c
    ${PROJ_DIR}/Mcal/Rte/src/SchM_Port.c
    ${PROJ_DIR}/Mcal/Rte/src/SchM_Platform.c
    ${PROJ_DIR}/Mcal/Can/src/Can.c
    ${PROJ_DIR}/Mcal/Can/src/Can_Lld.c
    ${PROJ_DIR}/Mcal/Can/src/Can_Lld_Irq.c
    ${PROJ_DIR}/Mcal/Port/src/Port.c
    ${PROJ_DIR}/Mcal/Port/src/Port_Lld.c
    ${PROJ_DIR}/Mcal/Platform/src/exceptions.c
    ${PROJ_DIR}/Mcal/Platform/src/IntCtrl_Lld.c
    ${PROJ_DIR}/Mcal/Platform/src/OsIf.c
    ${PROJ_DIR}/Mcal/Platform/src/Platform_Mld.c
    ${PROJ_DIR}/Mcal/Platform/src/Platform.c
    ${PROJ_DIR}/Mcal/Platform/src/System_Lld.c
    ${PROJ_DIR}/Mcal/Platform/src/Mpu_Lld_M33.c
)
set(includes
    ${PROJ_DIR}/Mcal/Mcu/inc
    ${PROJ_DIR}/Mcal/Rte/inc
    ${PROJ_DIR}/Mcal/Can/inc
    ${PROJ_DIR}/Mcal/Port/inc
    ${PROJ_DIR}/Mcal/Platform/inc
    ${PROJ_DIR}/Mcal/Platform/core
    ${PROJ_DIR}/Mcal/Platform/YTM32B1MD1/feature
    ${PROJ_DIR}/Mcal/Platform/YTM32B1MD1/regmap
)
set(priIncludes
)

add_library(GENERATED_SDK_TARGET STATIC ${sources})

target_include_directories(GENERATED_SDK_TARGET PUBLIC ${includes})


target_include_directories(GENERATED_SDK_TARGET PRIVATE ${priIncludes})
configcore(GENERATED_SDK_TARGET ${CMAKE_SOURCE_DIR})

target_compile_definitions(GENERATED_SDK_TARGET PUBLIC
    YTM32B1MD1
    CPU_YTM32B1MD1
)
target_compile_options(GENERATED_SDK_TARGET PUBLIC
    -fdiagnostics-color=always
)



target_link_libraries(GENERATED_SDK_TARGET
    GENERATED_CONFIG_TARGET
)
