function(gba_configure_assets output_asm_sources output_headers)
    set(generated_root "${CMAKE_CURRENT_BINARY_DIR}/generated")
    set(generated_data_dir "${generated_root}/data")
    set(generated_graphics_dir "${generated_root}/graphics")
    set(generated_music_dir "${generated_root}/music")
    file(MAKE_DIRECTORY
        "${generated_data_dir}"
        "${generated_graphics_dir}"
        "${generated_music_dir}")

    set(asm_sources "")
    set(headers "")
    set(data_files "")
    set(music_files "")

    foreach(directory IN LISTS GBA_DATA_DIRS)
        if(NOT IS_ABSOLUTE "${directory}")
            set(directory "${CMAKE_CURRENT_SOURCE_DIR}/${directory}")
        endif()
        file(GLOB directory_files CONFIGURE_DEPENDS "${directory}/*.*")
        foreach(input_file IN LISTS directory_files)
            if(NOT IS_DIRECTORY "${input_file}")
                list(APPEND data_files "${input_file}")
                set_property(DIRECTORY APPEND PROPERTY
                    CMAKE_CONFIGURE_DEPENDS "${input_file}")
            endif()
        endforeach()
    endforeach()

    foreach(directory IN LISTS GBA_MUSIC_DIRS)
        if(NOT IS_ABSOLUTE "${directory}")
            set(directory "${CMAKE_CURRENT_SOURCE_DIR}/${directory}")
        endif()
        file(GLOB directory_files CONFIGURE_DEPENDS "${directory}/*.*")
        foreach(input_file IN LISTS directory_files)
            if(NOT IS_DIRECTORY "${input_file}")
                list(APPEND music_files "${input_file}")
                set_property(DIRECTORY APPEND PROPERTY
                    CMAKE_CONFIGURE_DEPENDS "${input_file}")
            endif()
        endforeach()
    endforeach()

    if(music_files)
        set(mmutil "${GBA_DEVKITPRO}/tools/bin/mmutil")
        if(NOT EXISTS "${mmutil}")
            message(FATAL_ERROR "Required devkitPro tool was not found: ${mmutil}")
        endif()
        execute_process(
            COMMAND "${mmutil}" ${music_files}
                "-o${generated_music_dir}/soundbank.bin"
                "-h${generated_music_dir}/soundbank.h"
            WORKING_DIRECTORY "${generated_music_dir}"
            RESULT_VARIABLE mmutil_result
            OUTPUT_VARIABLE mmutil_output
            ERROR_VARIABLE mmutil_error)
        if(NOT mmutil_result EQUAL 0)
            message(FATAL_ERROR
                "mmutil failed while generating the soundbank:\n"
                "${mmutil_output}${mmutil_error}")
        endif()
        if(NOT EXISTS "${generated_music_dir}/soundbank.bin"
                OR NOT EXISTS "${generated_music_dir}/soundbank.h")
            message(FATAL_ERROR "mmutil did not generate soundbank.bin and soundbank.h.")
        endif()
        list(APPEND data_files "${generated_music_dir}/soundbank.bin")
        list(APPEND headers "${generated_music_dir}/soundbank.h")
    endif()

    if(data_files)
        set(bin2s "${GBA_DEVKITPRO}/tools/bin/bin2s")
        if(NOT EXISTS "${bin2s}")
            message(FATAL_ERROR "Required devkitPro tool was not found: ${bin2s}")
        endif()

        set(data_output_names "")
        foreach(input_file IN LISTS data_files)
            get_filename_component(filename "${input_file}" NAME)
            if(filename IN_LIST data_output_names)
                message(FATAL_ERROR
                    "Data files with the same filename cannot be flattened into "
                    "the generated data directory: ${filename}")
            endif()
            list(APPEND data_output_names "${filename}")

            string(REPLACE "." "_" symbol_name "${filename}")
            set(assembly_file "${generated_data_dir}/${filename}.s")
            set(header_file "${generated_data_dir}/${symbol_name}.h")
            execute_process(
                COMMAND "${bin2s}" -a 4 -H "${symbol_name}.h" "${input_file}"
                WORKING_DIRECTORY "${generated_data_dir}"
                OUTPUT_FILE "${assembly_file}"
                RESULT_VARIABLE bin2s_result
                ERROR_VARIABLE bin2s_error)
            if(NOT bin2s_result EQUAL 0)
                message(FATAL_ERROR
                    "bin2s failed for '${input_file}':\n${bin2s_error}")
            endif()
            if(NOT EXISTS "${assembly_file}" OR NOT EXISTS "${header_file}")
                message(FATAL_ERROR
                    "bin2s did not generate the expected outputs for '${input_file}'.")
            endif()
            list(APPEND asm_sources "${assembly_file}")
            list(APPEND headers "${header_file}")
        endforeach()
    endif()

    set(graphics_output_names "")
    foreach(directory IN LISTS GBA_GRAPHICS_DIRS)
        if(NOT IS_ABSOLUTE "${directory}")
            set(directory "${CMAKE_CURRENT_SOURCE_DIR}/${directory}")
        endif()
        file(GLOB graphics_files CONFIGURE_DEPENDS "${directory}/*.png")
        foreach(image_file IN LISTS graphics_files)
            get_filename_component(image_name "${image_file}" NAME_WE)
            if(image_name IN_LIST graphics_output_names)
                message(FATAL_ERROR
                    "Graphics files with the same basename cannot be flattened "
                    "into the generated graphics directory: ${image_name}")
            endif()
            list(APPEND graphics_output_names "${image_name}")
            get_filename_component(image_directory "${image_file}" DIRECTORY)
            set(grit_file "${image_directory}/${image_name}.grit")
            if(NOT EXISTS "${grit_file}")
                message(FATAL_ERROR
                    "Graphics source '${image_file}' requires '${grit_file}'.")
            endif()
            set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
                "${image_file}" "${grit_file}")

            set(output_base "${generated_graphics_dir}/${image_name}")
            execute_process(
                COMMAND "${GBA_DEVKITPRO}/tools/bin/grit"
                    "${image_file}" -fts "-ff${grit_file}" "-o${output_base}"
                WORKING_DIRECTORY "${generated_graphics_dir}"
                RESULT_VARIABLE grit_result
                OUTPUT_VARIABLE grit_output
                ERROR_VARIABLE grit_error)
            if(NOT grit_result EQUAL 0)
                message(FATAL_ERROR
                    "grit failed for '${image_file}':\n${grit_output}${grit_error}")
            endif()
            if(NOT EXISTS "${output_base}.s" OR NOT EXISTS "${output_base}.h")
                message(FATAL_ERROR
                    "grit did not generate the expected .s and .h files for "
                    "'${image_file}'.")
            endif()
            list(APPEND asm_sources "${output_base}.s")
            list(APPEND headers "${output_base}.h")
        endforeach()
    endforeach()

    set(${output_asm_sources} "${asm_sources}" PARENT_SCOPE)
    set(${output_headers} "${headers}" PARENT_SCOPE)
endfunction()
