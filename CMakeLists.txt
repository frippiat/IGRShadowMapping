cmake_minimum_required(VERSION 3.0)

SET(CMAKE_EXPORT_COMPILE_COMMANDS 1)
SET(CMAKE_CXX_STANDARD 11)
SET(CMAKE_CXX_STANDARD_REQUIRED ON)

project(tpShadow)

add_executable(
  tpShadow
  src/main.cpp
  src/Error.cpp
  src/Mesh.cpp
  src/ShaderProgram.cpp
)

# Add glad
add_subdirectory(dep/glad)
target_link_libraries(${PROJECT_NAME} PRIVATE glad)

# Add GLFW
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/dep/glfw/CMakeLists.txt")
  # Use GLFW from the dep folder
  add_subdirectory(dep/glfw)
  target_link_libraries(${PROJECT_NAME} PRIVATE glfw)
else()
  # Use system-installed GLFW
  find_package(glfw3 REQUIRED)
  target_link_libraries(${PROJECT_NAME} PRIVATE glfw)
endif()

# Add GLM
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/dep/glm/CMakeLists.txt")
  add_subdirectory(dep/glm)
  target_link_libraries(${PROJECT_NAME} PRIVATE glm)
else()
  find_package(glm REQUIRED)
  if(GLM_FOUND)
    include_directories("${GLM_INCLUDE_DIR}")
  endif()
endif()

# Add platform-specific dynamic library support
target_link_libraries(${PROJECT_NAME} PRIVATE ${CMAKE_DL_LIBS})

# Copy the executable to the source directory after build
add_custom_command(TARGET tpShadow
  POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:tpShadow> ${CMAKE_CURRENT_SOURCE_DIR}
)
