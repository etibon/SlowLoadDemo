#
# This module defines a function to configure, build and install dependencies
# at project configuration time.
#
# For parallel build, set the following env var to the desired number of jobs:
#
#   - CMAKE_BUILD_PARALLEL_LEVEL
#
# or pass the option (e.g. `-j4`) to the build command after `BUILD_ARGS`.
#

include(FetchContent)

list(PREPEND CMAKE_PREFIX_PATH ${FETCHCONTENT_BASE_DIR}/install)

function(install_dep DEP_NAME)
    set(options NO_CMAKE)
    set(singleValueArgs GITHUB_URL GITHUB_REPO GIT_TAG)
    set(multiValueArgs PATCH_FILES CONFIG_ARGS BUILD_ARGS INSTALL_ARGS)
    cmake_parse_arguments(PARSE_ARGV 1
            DEP "${options}" "${singleValueArgs}" "${multiValueArgs}"
            )

#    if ("GITHUB_URL" IN_LIST DEP_KEYWORDS_MISSING_VALUES)
#        set(GITHUB_URL https://github.com/)
#    endif()

    set(FETCHCONTENT_QUIET FALSE)

    if (DEP_PATCH_FILES)
        set(patch_command ${GIT_EXECUTABLE} apply ${DEP_PATCH_FILES})
    endif()

    FetchContent_Declare(${DEP_NAME}
            GIT_REPOSITORY https://github.com/${DEP_GITHUB_REPO}
            GIT_TAG ${DEP_GIT_TAG}
            GIT_SHALLOW TRUE
            GIT_PROGRESS TRUE
            PATCH_COMMAND ${patch_command}
            )
    FetchContent_Populate(${DEP_NAME})

    # expose variables created by FetchContent_Populate into the parent scope so that they can be used
    # in the calling CMakelists.txt.
    set(${DEP_NAME}_SOURCE_DIR ${${DEP_NAME}_SOURCE_DIR} PARENT_SCOPE )
    set(${DEP_NAME}_BINARY_DIR ${${DEP_NAME}_BINARY_DIR} PARENT_SCOPE )

    if (DEP_NO_CMAKE)
        set(${DEP_NAME}_FOUND TRUE PARENT_SCOPE)
        return()
    endif()

    execute_process(COMMAND ${CMAKE_COMMAND}
            -S ${${DEP_NAME}_SOURCE_DIR}
            -B ${${DEP_NAME}_BINARY_DIR}
            -DCMAKE_BUILD_TYPE=Release
            -DCMAKE_INSTALL_PREFIX=${FETCHCONTENT_BASE_DIR}/install
            -DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}
            -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
            ${DEP_CONFIG_ARGS}
            )
    execute_process(COMMAND ${CMAKE_COMMAND}
            --build ${${DEP_NAME}_BINARY_DIR}
            ${DEP_BUILD_ARGS}
            )
    execute_process(COMMAND ${CMAKE_COMMAND}
            --install ${${DEP_NAME}_BINARY_DIR}
            ${DEP_INSTALL_ARGS}
            )
endfunction()

#install(DIRECTORY ${FETCHCONTENT_BASE_DIR}/install/ DESTINATION .)
