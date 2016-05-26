##Default **sequences** folder path
set(SEQUENCES_PATH ${CMAKE_SOURCE_DIR}/sequences/)

## Url and md5 hash value for the vot2013 dataset
set(vot2013  http://www.site.uottawa.ca/research/viva/datasets/tracking/vot2013.tar.gz)
set(md5_vot2013  7467447b0d533efcb458ab106c66497a)

## Url and md5 hash value for the vot2014 dataset
set(vot2014  http://www.site.uottawa.ca/research/viva/datasets/tracking/vot2014.tar.gz)
set(md5_vot2014  3161df3bfc62802d5f5a66a5d4af82b6)

## Url and md5 hash value for the vot2015 dataset
set(vot2015  http://www.site.uottawa.ca/research/viva/datasets/tracking/vot2015.tar.gz)
set(md5_vot2015  2e8c33eed5dc08d8e4892fd9e4c1c2ed)

## Url and md5 hash value for the vot2015tir dataset
set(vot2015tir  http://www.site.uottawa.ca/research/viva/datasets/tracking/vot2015tir.tar.gz)
set(md5_vot2015tir  367c1f685d4a28a448f6c4bc2fcb3552)

## List of datasets available
set(_DATASETS_ vot2013 vot2014 vot2015 vot2015tir)

## Create an option for each dataset
foreach(dataset ${_DATASETS_})
	string(TOUPPER "DOWNLOAD_${dataset}" opt)
	option(${opt} "Download video sequences from ${dataset} dataset" OFF)
	list(APPEND DATASETS ${${dataset}}) 
endforeach()

macro(subdirlist result curdir)
  file(GLOB children RELATIVE ${curdir} ${curdir}/*)
  set(dirlist "")
  foreach(child ${children})
    if(IS_DIRECTORY ${curdir}/${child})
        list(APPEND dirlist ${child})
    endif()
  endforeach()
  set(${result} ${dirlist})
endmacro()

macro(unzip file dest)
	file(MAKE_DIRECTORY ${dest})
	execute_process(
     command ${CMAKE_COMMAND} -E tar xzf ${file} 
     working_directory ${dest}
    )
endmacro()

macro(check_dataset url)
	get_filename_component(name ${url} NAME_WE)
	get_filename_component(filename ${url} NAME)
	string(TOUPPER "DOWNLOAD_${name}" opt)
	if(${opt})
	
		set (DATASET "${SEQUENCES_PATH}${filename}")
		set (DATASET_FOLDER ${SEQUENCES_PATH}${name}/)
		set (DATASET_MD5 ${md5_${name}})
		
		file(MAKE_DIRECTORY ${DATASET_FOLDER})
		if ( NOT EXISTS  ${DATASET})
			 message(STATUS "    downloading dataset: ${DATASET}")
		 	 file(DOWNLOAD ${url} ${DATASET} SHOW_PROGRESS EXPECTED_HASH MD5=${DATASET_MD5})
		endif()
		if ( EXISTS ${DATASET} AND NOT EXISTS  "${DATASET_FOLDER}list.txt")
			message(STATUS "    unziping dataset: ${DATASET}")
			unzip(${DATASET} ${SEQUENCES_PATH})
		endif()
	endif()
endmacro()

macro(check_datasets)
	foreach(url ${DATASETS})
		check_dataset(${url})
	endforeach()
	file(TO_NATIVE_PATH ${SEQUENCES_PATH} SEQUENCES_PATH)
	file(WRITE ${CMAKE_SOURCE_DIR}/sequences.txt "${SEQUENCES_PATH}" )
endmacro()

subdirlist(TRACKERS "${CMAKE_SOURCE_DIR}/trackers")
foreach(tracker ${TRACKERS})
	string(TOUPPER "WITH_${tracker}" opt)
	option(${opt} "Tracker enabled" OFF)
	message(STATUS "tracker included: ${tracker}")
	list(APPEND _TRACKERS_ ${tracker})
endforeach()

macro(check_trackers)
	foreach(tracker ${_TRACKERS_})
	string(TOUPPER "WITH_${tracker}" opt)
	if(${opt})
			subdirs("trackers/${tracker}")
			include_directories(${CMAKE_SOURCE_DIR}/trackers/${tracker})
			target_link_libraries( ${PROJECT_NAME} ${tracker})
			message(STATUS "    tracker included: ${tracker}")
	endif()
	endforeach()
endmacro()

configure_file(precomp.h.in precomp.h @ONLY)
include_directories(${CMAKE_CURRENT_BINARY_DIR})
