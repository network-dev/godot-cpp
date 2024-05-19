include_guard()

include(GodotCppUtilities)

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

gde_duplicate_config(RelWithDebInfo Distribution)
gde_duplicate_config(Debug EditorDebug)
gde_duplicate_config(Distribution EditorDistribution)

gde_remove_config(MinSizeRel)
gde_remove_config(Release)
gde_remove_config(RelWithDebInfo)
