cmake_minimum_required(VERSION 3.10)

project(discord_rpc)

# Get Discord RPC files
if (WIN32)
	file(GLOB DISCORD_RPC_SOURCES lib/discord-rpc/src/discord_rpc.cpp lib/discord-rpc/rpc_connection.cpp lib/discord-rpc/serialization.cpp
		lib/discord-rpc/src/connection_windows.cpp
		lib/discord-rpc/src/discord_register_windows.cpp)
elseif (APPLE)
	file(GLOB DISCORD_RPC_SOURCES lib/discord-rpc/src/discord_rpc.cpp lib/discord-rpc/rpc_connection.cpp lib/discord-rpc/serialization.cpp
		lib/discord-rpc/src/connection_unix.cpp
		lib/discord-rpc/src/discord_register_macos.cpp)
else()
	file(GLOB DISCORD_RPC_SOURCES lib/discord-rpc/src/discord_rpc.cpp lib/discord-rpc/rpc_connection.cpp lib/discord-rpc/serialization.cpp
		lib/discord-rpc/src/connection_unix.cpp
		lib/discord-rpc/src/discord_register_linux.cpp)
endif()

# Add Windows defines
if (WIN32)
	add_compile_definitions(WIN32_LEAN_AND_MEAN
		NOMCX
		NOSERVICE
		NOIME)
endif()

# Set HashLink paths
if (NOT APPLE)
	set(HL_BIN $ENV{HASHLINKPATH})
else()
	set(HL_BIN /urs/local/lib)
endif()
set(HL_INCLUDE ${HL_BIN}/include)

include_directories(${HL_INCLUDE} lib/discord-rpc/include lib/rapidjson/include)

# Link additional static libraries
if (MINGW)
	link_libraries(-lpsapi -ladvapi32)
elseif (WIN32)
	link_libraries(psapi.lib advapi32.lib)
endif()
if (MINGW OR NOT WIN32)
	link_libraries(-lpthread)
endif()

# Link HashLink static library
if (WIN32 AND NOT MINGW)
	link_libraries(${HL_BIN}/libhl.lib)
else()
	link_libraries(-lhl)
endif()

add_library(${PROJECT_NAME} SHARED extension.cpp ${DISCORD_RPC_SOURCES})
set_target_properties(${PROJECT_NAME}
	PROPERTIES
	PREFIX ""
	OUTPUT_NAME ${PROJECT_NAME}
	SUFFIX .hdll)

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
	COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${PROJECT_NAME}> ../..)
