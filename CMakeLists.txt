cmake_minimum_required(VERSION 3.16)
project(SlowLoadDemo)

set(CMAKE_CXX_STANDARD 17)


list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
include(install_dep)

add_compile_options(-Wno-error=conversion-null)

find_package(AWSSDK QUIET COMPONENTS s3-crt)
if (NOT AWSSDK)
    install_dep(aws_sdk_cpp
            GITHUB_REPO aws/aws-sdk-cpp
            GIT_TAG 1.11.137
            CONFIG_ARGS
            -DBUILD_ONLY=s3-crt
            -DENABLE_TESTING=OFF
            -DCMAKE_CXX_FLAGS="-Wno-error=conversion-null"
    )
    find_package(AWSSDK REQUIRED COMPONENTS s3-crt)
endif()

add_executable(SlowLoadDemo main.cpp)
target_link_libraries(SlowLoadDemo ${AWSSDK_LINK_LIBRARIES})
include_directories(${AWSSDK_INCLUDE_DIRS})
