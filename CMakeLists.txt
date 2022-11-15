cmake_minimum_required(VERSION 3.22 FATAL_ERROR)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

include(GodotCppPrelude)

project(godot-cpp
	DESCRIPTION "C++ bindings for the Godot Engine's GDExtensions API."
	LANGUAGES CXX
)

find_package(Python 3.8 COMPONENTS Interpreter REQUIRED)

include(GodotCppSetup)
include(GodotCppGenerateCode)

file(GLOB_RECURSE godot-cpp_SOURCES CONFIGURE_DEPENDS src/*.c*)
file(GLOB_RECURSE godot-cpp_HEADERS CONFIGURE_DEPENDS include/*.h*)

list(APPEND godot-cpp_SOURCES ${godot-cpp_GENERATED_SOURCES})
list(APPEND godot-cpp_HEADERS ${godot-cpp_GENERATED_HEADERS})

add_library(godot-cpp STATIC ${godot-cpp_SOURCES} ${godot-cpp_HEADERS})
add_library(godot-cpp::godot-cpp ALIAS godot-cpp)

set(is_editor_config $<CONFIG:EditorDebug,EditorDistribution>)
set(is_optimized_config $<CONFIG:Distribution,EditorDistribution>)

set(deterministic $<BOOL:${GDCPP_CROSS_PLATFORM_DETERMINISTIC}>)
set(not_deterministic $<NOT:${deterministic}>)

set(target_avx512 $<STREQUAL:${GDCPP_X86_INSTRUCTION_SET},AVX512>)
set(target_avx2 $<STREQUAL:${GDCPP_X86_INSTRUCTION_SET},AVX2>)
set(target_avx $<STREQUAL:${GDCPP_X86_INSTRUCTION_SET},AVX>)
set(target_sse2 $<STREQUAL:${GDCPP_X86_INSTRUCTION_SET},SSE2>)

set(is_msvc_like $<BOOL:${MSVC}>)
set(is_msvc_cl $<CXX_COMPILER_ID:MSVC>)
set(is_llvm_clang $<CXX_COMPILER_ID:Clang>)
set(is_clang_cl $<AND:${is_msvc_like},${is_llvm_clang}>)

target_compile_features(godot-cpp
	PRIVATE cxx_std_17
)

target_include_directories(godot-cpp
	PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
	PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/gen/include
	PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/godot-headers
)

target_compile_definitions(godot-cpp
	PUBLIC $<${is_editor_config}:DEBUG_ENABLED>
	PUBLIC $<${is_editor_config}:DEBUG_METHODS_ENABLED>
	PUBLIC $<${is_editor_config}:TOOLS_ENABLED>
	PUBLIC $<${is_msvc_like}:TYPED_METHOD_BIND>
)

if(MSVC)
	target_compile_options(godot-cpp
		PRIVATE /W0 # Disable warnings
		PRIVATE /GF # Enable string pooling
		PRIVATE /Gy # Enable function-level linking
		PRIVATE /EHsc # Enable exception handling
		PRIVATE $<${not_deterministic}:/fp:fast> # Enable aggressive floating-point optimizations
		PRIVATE $<${is_optimized_config}:/GS-> # Disable security checks
		PRIVATE $<${target_avx}:/arch:AVX> # Enable AVX instructions
		PRIVATE $<${target_avx2}:/arch:AVX2> # Enable AVX2 instructions
		PRIVATE $<${target_avx512}:/arch:AVX512> # Enable AVX-512 instructions
		PRIVATE $<${is_msvc_cl}:/MP> # Multi-threaded compilation
		PRIVATE $<${is_clang_cl}:-Qunused-arguments> # Disable warnings about unused arguments
	)
else()
	set(use_avx512 ${target_avx512})
	set(use_avx2 $<OR:${target_avx2},${use_avx512}>)
	set(use_bmi1 ${use_avx2})
	set(use_fma3 $<AND:${use_avx2},${not_deterministic}>)
	set(use_f16c ${use_avx2})
	set(use_avx $<OR:${target_avx},${use_avx2}>)
	set(use_sse4_2 ${use_avx})
	set(use_sse2 $<OR:${target_sse2},${use_sse4_2}>)

	target_compile_options(godot-cpp
		PRIVATE -w # Disable warnings
		PRIVATE $<${deterministic}:-ffp-contract=off> # Disable floating-point contractions
		PRIVATE $<${not_deterministic}:-ffast-math> # Enable aggressive floating-point optimizations
		PRIVATE $<${use_sse2}:-msse2> # Enable SSE2 instructions
		PRIVATE $<${use_sse4_2}:-msse4.2> # Enable SSE4.2 instructions
		PRIVATE $<${use_sse4_2}:-mpopcnt> # Enable the POPCNT instruction
		PRIVATE $<${use_avx}:-mavx> # Enable AVX instructions
		PRIVATE $<${use_f16c}:-mf16c> # Enable F16C instructions
		PRIVATE $<${use_fma3}:-mfma> # Enable FMA3 instructions
		PRIVATE $<${use_bmi1}:-mbmi> # Enable BMI1 instructions
		PRIVATE $<${use_bmi1}:-mlzcnt> # Enable the LZCNT instruction
		PRIVATE $<${use_avx2}:-mavx2> # Enable AVX2 instructions
		PRIVATE $<${use_avx512}:-mavx512f> # Enable AVX-512 Foundation instructions
		PRIVATE $<${use_avx512}:-mavx512vl> # Enable AVX-512 Vector Length instructions
		PRIVATE $<${use_avx512}:-mavx512dq> # Enable AVX-512 Doubleword and Quadword instructions
	)
endif()
