cmake_minimum_required(VERSION 3.5)

# Find MuJoCo using the binary distributed via pip because it can be reused if
# other packages need to link against Mujoco. MuJoCo is not a part of rosdistro
# yet, so we cannot "automatically" install/verify its existence with colcon and
# rosdep. This is a bit unconventional and may need to be modified later, but
# for now, this fits our needs.

# cmake-lint: disable=C0103

find_package(PythonInterp REQUIRED)
execute_process(
  COMMAND "${PYTHON_EXECUTABLE}" -c
          "import mujoco,os;print(os.path.dirname(mujoco.__file__))"
  OUTPUT_VARIABLE MUJOCO_PATH
  OUTPUT_STRIP_TRAILING_WHITESPACE
  RESULT_VARIABLE result
  ERROR_VARIABLE error_output)
if(NOT ${result} EQUAL 0)
  message(
    SEND_ERROR
      "Failed to find Mujoco library from Python3 install (${PYTHON_EXECUTABLE}):\n"
      ${error_output})
  set(mujoco_FOUND FALSE)
  return()
endif()

file(GLOB MUJOCO_LIB ${MUJOCO_PATH}/libmujoco.so*)
if(NOT MUJOCO_LIB)
  message(SEND_ERROR "MUJOCO_LIB library not found in directory ${MUJOCO_PATH}")
  set(mujoco_FOUND FALSE)
  return()
endif()
list(LENGTH MUJOCO_LIB LIST_LENGTH)
if(NOT LIST_LENGTH EQUAL 1)
  message(
    SEND_ERROR
      "Multiple versions of the MUJOCO_LIB library found in directory ${MUJOCO_PATH}: including ${MUJOCO_LIB}"
  )
  set(mujoco_FOUND FALSE)
  return()
endif()

add_library(mujoco SHARED IMPORTED)
set_target_properties(
  mujoco PROPERTIES IMPORTED_LOCATION "${MUJOCO_LIB}"
                    INTERFACE_INCLUDE_DIRECTORIES "${MUJOCO_PATH}/include")
set(mujoco_FOUND TRUE)
