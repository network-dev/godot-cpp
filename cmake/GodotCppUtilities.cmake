include_guard()

macro(gde_duplicate_config src dst)
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

macro(gde_remove_config name)
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
