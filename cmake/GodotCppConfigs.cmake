include_guard()

set(supported_configs
	Debug
	Distribution
	EditorDebug
	EditorDistribution
)

get_property(is_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

if(is_multi_config)
	set(CMAKE_CONFIGURATION_TYPES ${supported_configs} CACHE STRING "" FORCE)
else()
	if(NOT CMAKE_BUILD_TYPE)
		message(FATAL_ERROR "No build type specified.")
	endif()

	if(NOT CMAKE_BUILD_TYPE IN_LIST supported_configs)
		message(FATAL_ERROR "Unsupported build type: '${CMAKE_BUILD_TYPE}'")
	endif()
endif()

macro(duplicate_config src dst)
	string(TOUPPER ${src} src_upper)
	string(TOUPPER ${dst} dst_upper)

	set(CMAKE_CXX_FLAGS_${dst_upper} ${CMAKE_CXX_FLAGS_${src_upper}} CACHE STRING "")
	set(CMAKE_EXE_LINKER_FLAGS_${dst_upper} ${CMAKE_EXE_LINKER_FLAGS_${src_upper}} CACHE STRING "")
	set(CMAKE_MODULE_LINKER_FLAGS_${dst_upper} ${CMAKE_MODULE_LINKER_FLAGS_${src_upper}} CACHE STRING "")
	set(CMAKE_SHARED_LINKER_FLAGS_${dst_upper} ${CMAKE_SHARED_LINKER_FLAGS_${src_upper}} CACHE STRING "")
	set(CMAKE_STATIC_LINKER_FLAGS_${dst_upper} ${CMAKE_STATIC_LINKER_FLAGS_${src_upper}} CACHE STRING "")

	if(MSVC)
		set(CMAKE_RC_FLAGS_${dst_upper} ${CMAKE_RC_FLAGS_${src_upper}} CACHE STRING "")
	endif()
endmacro()

macro(remove_config name)
	string(TOUPPER ${name} name_upper)

	unset(CMAKE_CXX_FLAGS_${name_upper} CACHE)
	unset(CMAKE_EXE_LINKER_FLAGS_${name_upper} CACHE)
	unset(CMAKE_MODULE_LINKER_FLAGS_${name_upper} CACHE)
	unset(CMAKE_SHARED_LINKER_FLAGS_${name_upper} CACHE)
	unset(CMAKE_STATIC_LINKER_FLAGS_${name_upper} CACHE)

	if(MSVC)
		unset(CMAKE_RC_FLAGS_${name_upper} CACHE)
	endif()
endmacro()

duplicate_config(RelWithDebInfo Distribution)
duplicate_config(Debug EditorDebug)
duplicate_config(Distribution EditorDistribution)

remove_config(MinSizeRel)
remove_config(Release)
remove_config(RelWithDebInfo)
