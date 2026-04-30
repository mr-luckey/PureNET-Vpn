cmake_minimum_required(VERSION 3.22.1)

project(ovpnexec LANGUAGES C)

add_library(ovpnexec SHARED ovpnexec.c)

target_link_libraries(ovpnexec PRIVATE dl log)

target_compile_definitions(ovpnexec PRIVATE ANDROID_STANDALONE_EXECUTABLE=1)

target_link_options(ovpnexec PRIVATE
        -Wl,-z,max-page-size=16384
        -Wl,-z,common-page-size=16384
)

