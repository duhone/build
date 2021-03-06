set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set(CMAKE_CXX_STANDARD 17)
# set(CMAKE_CXX_CLANG_TIDY clang-tidy -checks=cppcoreguidelines-*)

function(addCommon target)	
	target_compile_options(${target} PRIVATE $<$<CXX_COMPILER_ID:MSVC>:/GR->)
	
	target_compile_options(${target} PRIVATE $<$<CXX_COMPILER_ID:MSVC>:/arch:AVX>)
	target_compile_options(${target} PRIVATE $<$<CXX_COMPILER_ID:MSVC>:/fp:fast>)
	target_compile_options(${target} PRIVATE $<$<CXX_COMPILER_ID:MSVC>:/fp:except->)
	target_compile_options(${target} PRIVATE $<$<CXX_COMPILER_ID:MSVC>:/MP>)

	target_compile_options(${target} PRIVATE $<$<CXX_COMPILER_ID:Clang>:-ffast-math>)

	target_compile_options(${target} PRIVATE $<$<CXX_COMPILER_ID:GNU>:-ffast-math>)
		
	target_compile_options(${target} PRIVATE $<$<AND:$<CXX_COMPILER_ID:MSVC>,$<OR:$<CONFIG:RelWithDebInfo>,$<CONFIG:Profile>,$<CONFIG:Final>>>:/O2>)
	target_compile_options(${target} PRIVATE $<$<AND:$<CXX_COMPILER_ID:MSVC>,$<OR:$<CONFIG:RelWithDebInfo>,$<CONFIG:Profile>,$<CONFIG:Final>>>:/Oi>)
	target_compile_options(${target} PRIVATE $<$<AND:$<CXX_COMPILER_ID:MSVC>,$<OR:$<CONFIG:RelWithDebInfo>,$<CONFIG:Profile>,$<CONFIG:Final>>>:/Ot>)
	target_compile_options(${target} PRIVATE $<$<AND:$<CXX_COMPILER_ID:MSVC>,$<OR:$<CONFIG:RelWithDebInfo>,$<CONFIG:Profile>,$<CONFIG:Final>>>:/Ob2>)
	target_compile_options(${target} PRIVATE /sdl-)
		
	target_compile_definitions(${target} PRIVATE $<$<CONFIG:Debug>:CR_DEBUG=1>)
	target_compile_definitions(${target} PRIVATE $<$<NOT:$<CONFIG:Debug>>:CR_DEBUG=0>)
	target_compile_definitions(${target} PRIVATE $<$<CONFIG:RelWithDebInfo>:CR_RELEASE=1>)
	target_compile_definitions(${target} PRIVATE $<$<NOT:$<CONFIG:RelWithDebInfo>>:CR_RELEASE=0>)
	target_compile_definitions(${target} PRIVATE $<$<CONFIG:Profile>:CR_PROFILE=1>)
	target_compile_definitions(${target} PRIVATE $<$<NOT:$<CONFIG:Profile>>:CR_PROFILE=0>)
	target_compile_definitions(${target} PRIVATE $<$<CONFIG:Final>:CR_FINAL=1>)
	target_compile_definitions(${target} PRIVATE $<$<NOT:$<CONFIG:Final>>:CR_FINAL=0>)
	target_compile_definitions(${target} PRIVATE $<$<AND:$<CXX_COMPILER_ID:MSVC>,$<OR:$<CONFIG:Profile>,$<CONFIG:Final>>>:NDEBUG>)
	
	# generator expressions aren't working with INTERPROCEDURAL_OPTIMIZATION_PROFILE
	set_target_properties(${target} PROPERTIES INTERPROCEDURAL_OPTIMIZATION_PROFILE TRUE)
	set_target_properties(${target} PROPERTIES INTERPROCEDURAL_OPTIMIZATION_FINAL TRUE)	
	
	target_link_options(${target} PRIVATE $<$<AND:$<CXX_COMPILER_ID:MSVC>,$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>>:/Debug:fastlink>)
endfunction()


function(settings3rdParty target)	
	addCommon(${target})
	
	source_group("Public Headers" FILES ${PUBLIC_HDRS})
	source_group("Source" FILES ${SRCS})
	source_group("Build" FILES ${BUILD})
	
	target_compile_options(${target} PRIVATE /W0)
	target_compile_options(${target} PRIVATE /WX-)
	
	set_property(TARGET ${target} APPEND PROPERTY FOLDER 3rdParty)
endfunction()

function(settingsCR target)	
	addCommon(${target})
	
	source_group(TREE ${root} FILES ${PUBLIC_HDRS})
	source_group(TREE ${root} FILES ${SRCS})
	source_group(TREE ${root} FILES ${BUILD})
		
	target_compile_options(${target} PRIVATE /W4)
	target_compile_options(${target} PRIVATE /WX)
	
	target_include_directories(${target} PRIVATE "${CMAKE_CURRENT_LIST_DIR}/../../3rdParty/include")
	
	# disable unit tests in profile and final builds
	target_compile_definitions(${target} PRIVATE $<$<AND:$<CXX_COMPILER_ID:MSVC>,$<OR:$<CONFIG:Profile>,$<CONFIG:Final>>>:DOCTEST_CONFIG_DISABLE>)
	
	set_target_properties(${target} PROPERTIES
		VS_GLOBAL_RunCodeAnalysis false

		# Use visual studio core guidelines
		VS_GLOBAL_EnableMicrosoftCodeAnalysis false

		# Use clangtidy
		VS_GLOBAL_EnableClangTidyCodeAnalysis true
		VS_GLOBAL_ClangTidyChecks "-checks=-*,modernize-*, -modernize-avoid-c-arrays, -modernize-use-trailing-return-type, \
bugprone-*, -bugprone-bool-pointer-implicit-conversion, cppcoreguidelines-*, -cppcoreguidelines-avoid-c-arrays, -cppcoreguidelines-pro-bounds-constant-array-index, misc-*, performance-*, readability-*, -readability-uppercase-literal-suffix"
	)
endfunction()

function(createPCH target)	
	target_precompile_headers(${target} PRIVATE 
		<cstdlib>
		<type_traits>
		<bitset>
		<functional>
		<utility>
		<chrono>
		<cstddef>
		<initializer_list>
		<tuple>
		<optional>
		<variant>
		<memory>
		<memory_resource>
		<cstdint>
		<cinttypes>
		<limits>
		<exception>
		<cctype>
		<cstring>
		<string>
		<string_view>
		<charconv>
		<array>
		<vector>
		<deque>
		<queue>
		<iterator>
		<algorithm>
		<execution>
		<cmath>
		<random>
		<numeric>
		<cstdio>
		<atomic>
		<thread>
		<mutex>
		<shared_mutex>
		<future>
		<condition_variable>
		<filesystem>
		<3rdParty/fmt.h>
		<3rdParty/function2.h>
		<3rdParty/spdlog.h>
		<3rdParty/glm.h>
		<3rdParty/robinmap.h>
	)
endfunction()

# doesn't really work yet
function(usePCH target fromTarget)	
	target_precompile_headers(${target} REUSE_FROM ${fromTarget})
endfunction()