include_guard()

set(launch_script ${CMAKE_CURRENT_SOURCE_DIR}/godot_jolt.py)
set(generator_script ${CMAKE_CURRENT_SOURCE_DIR}/binding_generator.py)
set(extension_api ${CMAKE_CURRENT_SOURCE_DIR}/gdextension/extension_api.json)
set(arch_bits $<IF:$<EQUAL:${CMAKE_SIZEOF_VOID_P},8>,64,32>)

execute_process(
	COMMAND ${Python_EXECUTABLE} ${launch_script}
		print
			-a ${extension_api}
			-o ${CMAKE_CURRENT_BINARY_DIR}
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	OUTPUT_VARIABLE generated_files
	ERROR_VARIABLE print_error
	RESULT_VARIABLE print_exit_code
)

if(NOT ${print_exit_code} EQUAL 0)
	message(FATAL_ERROR "Failed to print list of generated files, with stderr: '${print_error}'.")
endif()

if("${generated_files}" STREQUAL "")
	message(FATAL_ERROR "Failed to print list of generated files, for unknown reason.")
endif()

add_custom_command(
	OUTPUT ${generated_files}
	COMMENT "Generating bindings..."
	COMMAND ${Python_EXECUTABLE} ${launch_script}
		generate
			-a ${extension_api}
			-o ${CMAKE_CURRENT_BINARY_DIR}
			-b ${arch_bits}
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	MAIN_DEPENDENCY ${extension_api}
	DEPENDS ${launch_script} ${generator_script}
	VERBATIM
)

set(${PROJECT_NAME}_GENERATED_SOURCES ${generated_files})
set(${PROJECT_NAME}_GENERATED_HEADERS ${generated_files})

list(FILTER ${PROJECT_NAME}_GENERATED_SOURCES INCLUDE REGEX [[\.c(..)?$]])
list(FILTER ${PROJECT_NAME}_GENERATED_HEADERS INCLUDE REGEX [[\.h(..)?$]])
