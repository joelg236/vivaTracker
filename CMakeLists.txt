cmake_minimum_required(VERSION 3.0)

project("vivaTracker")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

# add opencv package to the project
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS}) 

file(GLOB files "*.h" "*.cpp")
add_executable(${CMAKE_PROJECT_NAME} ${files})
if(THREADS_HAVE_PTHREAD_ARG)
  target_compile_options(PUBLIC ${CMAKE_PROJECT_NAME} "-pthread")
endif()
if(CMAKE_THREAD_LIBS_INIT)
  target_link_libraries(${CMAKE_PROJECT_NAME} "${CMAKE_THREAD_LIBS_INIT}")
endif()

# Include libraries and trackers to project
subdirs(vivalib trackerlib)
include_directories(${CMAKE_SOURCE_DIR}/vivalib)
include_directories(${CMAKE_SOURCE_DIR}/trackerlib)
target_link_libraries(${CMAKE_PROJECT_NAME} ${OpenCV_LIBS} trackerlib vivalib)

#Needed because Struck tracker
set(EIGEN3_INCLUDE_DIRS "" CACHE FILEPATH "Path to eigen3 directory")
include_directories(${EIGEN3_INCLUDE_DIRS})

#Datasets and Trackers
include("macros.cmake")
check_datasets()
check_trackers()

# Copy resources in source folder to build folders
file(GLOB hidden ".*")
file(GLOB resources "*.*")
list(REMOVE_ITEM resources ${files} ${hidden} "${CMAKE_SOURCE_DIR}/CMakeLists.txt" "${CMAKE_SOURCE_DIR}/macros.cmake" "${CMAKE_SOURCE_DIR}/precomp.h.in")
file(COPY ${resources} DESTINATION "Debug")
file(COPY ${resources} DESTINATION "Release")
