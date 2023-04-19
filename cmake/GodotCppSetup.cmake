include_guard()

if(NOT PROJECT_IS_TOP_LEVEL)
	message(AUTHOR_WARNING "This fork is meant to be used by godot-jolt and is not suited for general use.")
endif()

include(GodotCppConfigurations)
include(GodotCppOptions)
