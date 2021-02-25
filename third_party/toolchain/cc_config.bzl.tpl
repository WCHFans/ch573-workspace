load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "action_config",
    "artifact_name_pattern",
    "env_entry",
    "env_set",
    "feature",
    "feature_set",
    "flag_group",
    "flag_set",
    "make_variable",
    "tool",
    "tool_path",
    "variable_with_value",
    "with_feature_set",
)
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")

def _impl(ctx):
    if (ctx.attr.cpu == "riscv"):
        toolchain_identifier = "riscv32-imac"
    elif (ctx.attr.cpu == "local"):
        toolchain_identifier = "local_linux"
    else:
        fail("Unreachable")

    if (ctx.attr.cpu == "riscv"):
        host_system_name = "riscv"
    elif (ctx.attr.cpu == "local"):
        host_system_name = "local"
    else:
        fail("Unreachable")

    if (ctx.attr.cpu == "riscv"):
        target_system_name = "riscv"
    elif (ctx.attr.cpu == "local"):
        target_system_name = "local"
    else:
        fail("Unreachable")

    if (ctx.attr.cpu == "riscv"):
        target_cpu = "riscv"
    elif (ctx.attr.cpu == "local"):
        target_cpu = "local"
    else:
        fail("Unreachable")

    if (ctx.attr.cpu == "riscv"):
        target_libc = "riscv"
    elif (ctx.attr.cpu == "local"):
        target_libc = "local"
    else:
        fail("Unreachable")

    compiler = "compiler"

    if (ctx.attr.cpu == "riscv"):
        abi_version = "riscv"
    elif (ctx.attr.cpu == "local"):
        abi_version = "local"
    else:
        fail("Unreachable")

    if (ctx.attr.cpu == "riscv"):
        abi_libc_version = "riscv"
    elif (ctx.attr.cpu == "local"):
        abi_libc_version = "local"
    else:
        fail("Unreachable")

    cc_target_os = None

    builtin_sysroot = None

    all_compile_actions = [
        ACTION_NAMES.c_compile,
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.linkstamp_compile,
        ACTION_NAMES.assemble,
        ACTION_NAMES.preprocess_assemble,
        ACTION_NAMES.cpp_header_parsing,
        ACTION_NAMES.cpp_module_compile,
        ACTION_NAMES.cpp_module_codegen,
        ACTION_NAMES.clif_match,
        ACTION_NAMES.lto_backend,
    ]

    all_cpp_compile_actions = [
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.linkstamp_compile,
        ACTION_NAMES.cpp_header_parsing,
        ACTION_NAMES.cpp_module_compile,
        ACTION_NAMES.cpp_module_codegen,
        ACTION_NAMES.clif_match,
    ]

    preprocessor_compile_actions = [
        ACTION_NAMES.c_compile,
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.linkstamp_compile,
        ACTION_NAMES.preprocess_assemble,
        ACTION_NAMES.cpp_header_parsing,
        ACTION_NAMES.cpp_module_compile,
        ACTION_NAMES.clif_match,
    ]

    codegen_compile_actions = [
        ACTION_NAMES.c_compile,
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.linkstamp_compile,
        ACTION_NAMES.assemble,
        ACTION_NAMES.preprocess_assemble,
        ACTION_NAMES.cpp_module_codegen,
        ACTION_NAMES.lto_backend,
    ]

    all_link_actions = [
        ACTION_NAMES.cpp_link_executable,
        ACTION_NAMES.cpp_link_nodeps_dynamic_library,
    ]

    objcopy_embed_data_action = action_config(
        action_name = "objcopy_embed_data",
        enabled = True,
        tools = [tool(path = "/usr/bin/objcopy")],
    )

    if (ctx.attr.cpu == "riscv"):
        action_configs = []
    elif (ctx.attr.cpu == "local"):
        action_configs = [objcopy_embed_data_action]
    else:
        fail("Unreachable")

    opt_feature = feature(name = "opt")

    dbg_feature = feature(name = "dbg")

    sysroot_feature = feature(
        name = "sysroot",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_compile_actions + all_link_actions,
                flag_groups = [flag_group(
                    flags = [
                        "--sysroot",
                        "%{sysroot}",
                    ],
                    iterate_over = "sysroot",
                    expand_if_available = "sysroot",
                )],
            ),
        ],
    )

    if (ctx.attr.cpu == "riscv"):
        unfiltered_compile_flags_feature = feature(
            name = "unfiltered_compile_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.assemble,
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.linkstamp_compile,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                        ACTION_NAMES.lto_backend,
                        ACTION_NAMES.clif_match,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-Wno-builtin-macro-redefined",
                                "-D__DATE__=\"redacted\"",
                                "-D__TIMESTAMP__=\"redacted\"",
                                "-D__TIME__=\"redacted\"",
                                "-no-canonical-prefixes",
                                "-fno-canonical-system-headers",
                            ],
                        ),
                    ],
                ),
            ],
        )
    elif (ctx.attr.cpu == "local"):
        unfiltered_compile_flags_feature = feature(
            name = "unfiltered_compile_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.assemble,
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.linkstamp_compile,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                        ACTION_NAMES.lto_backend,
                        ACTION_NAMES.clif_match,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-no-canonical-prefixes",
                                "-fno-canonical-system-headers",
                                "-Wno-builtin-macro-redefined",
                                "-D__DATE__=\"redacted\"",
                                "-D__TIMESTAMP__=\"redacted\"",
                                "-D__TIME__=\"redacted\"",
                            ],
                        ),
                    ],
                ),
            ],
        )
    else:
        unfiltered_compile_flags_feature = None

    objcopy_embed_flags_feature = feature(
        name = "objcopy_embed_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = ["objcopy_embed_data"],
                flag_groups = [flag_group(flags = ["-I", "binary"])],
            ),
        ],
    )

    if (ctx.attr.cpu == "riscv"):
        default_compile_flags_feature = feature(
            name = "default_compile_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.assemble,
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.linkstamp_compile,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                        ACTION_NAMES.lto_backend,
                        ACTION_NAMES.clif_match,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-U_FORTIFY_SOURCE",
                                "-D_FORTIFY_SOURCE=1",
                            ],
                        ),
                    ],
                ),
                # flag_set(
                #     actions = [
                #         ACTION_NAMES.assemble,
                #         ACTION_NAMES.preprocess_assemble,
                #         ACTION_NAMES.linkstamp_compile,
                #         ACTION_NAMES.c_compile,
                #         ACTION_NAMES.cpp_compile,
                #         ACTION_NAMES.cpp_header_parsing,
                #         ACTION_NAMES.cpp_module_compile,
                #         ACTION_NAMES.cpp_module_codegen,
                #         ACTION_NAMES.lto_backend,
                #         ACTION_NAMES.clif_match,
                #     ],
                #     flag_groups = [flag_group(flags = ["-g"])],
                #     with_features = [with_feature_set(features = ["dbg"])],
                # ),
                flag_set(
                    actions = [
                        ACTION_NAMES.assemble,
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.linkstamp_compile,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                        ACTION_NAMES.lto_backend,
                        ACTION_NAMES.clif_match,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-O3",
                                "-DNDEBUG",
                                "-ffunction-sections",
                                "-fdata-sections",
                            ],
                        ),
                    ],
                    with_features = [with_feature_set(features = ["opt"])],
                ),
            ],
        )
    elif (ctx.attr.cpu == "local"):
        default_compile_flags_feature = feature(
            name = "default_compile_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.assemble,
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.linkstamp_compile,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                        ACTION_NAMES.lto_backend,
                        ACTION_NAMES.clif_match,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-U_FORTIFY_SOURCE",
                                "-D_FORTIFY_SOURCE=1",
                                "-fstack-protector",
                                "-Wall",
                                "-Wunused-but-set-parameter",
                                "-Wno-free-nonheap-object",
                                "-fno-omit-frame-pointer",
                            ],
                        ),
                    ],
                ),
                flag_set(
                    actions = [
                        ACTION_NAMES.assemble,
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.linkstamp_compile,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                        ACTION_NAMES.lto_backend,
                        ACTION_NAMES.clif_match,
                    ],
                    flag_groups = [flag_group(flags = ["-g"])],
                    with_features = [with_feature_set(features = ["dbg"])],
                ),
                flag_set(
                    actions = [
                        ACTION_NAMES.assemble,
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.linkstamp_compile,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                        ACTION_NAMES.lto_backend,
                        ACTION_NAMES.clif_match,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-g0",
                                "-O2",
                                "-DNDEBUG",
                                "-ffunction-sections",
                                "-fdata-sections",
                            ],
                        ),
                    ],
                    with_features = [with_feature_set(features = ["opt"])],
                ),
                flag_set(
                    actions = [
                        ACTION_NAMES.linkstamp_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                        ACTION_NAMES.lto_backend,
                        ACTION_NAMES.clif_match,
                    ],
                    flag_groups = [flag_group(flags = ["-std=c++0x"])],
                ),
            ],
        )
    else:
        default_compile_flags_feature = None

    if (ctx.attr.cpu == "local"):
        default_link_flags_feature = feature(
            name = "default_link_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = all_link_actions,
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-lstdc++",
                                "-B/usr/bin/",
                                "-Wl,-z,relro,-z,now",
                                "-no-canonical-prefixes",
                                "-pass-exit-codes",
                                "-Wl,--build-id=md5",
                            ],
                        ),
                    ],
                ),
                flag_set(
                    actions = all_link_actions,
                    flag_groups = [flag_group(flags = ["-Wl,--gc-sections"])],
                    with_features = [with_feature_set(features = ["opt"])],
                ),
            ],
        )
    elif (ctx.attr.cpu == "riscv"):
        default_link_flags_feature = feature(
            name = "default_link_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = all_link_actions,
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-lstdc++",
                                "-no-canonical-prefixes",
                                "-Wl,--build-id=md5",
                            ],
                        ),
                    ],
                ),
                flag_set(
                    actions = all_link_actions,
                    flag_groups = [flag_group(flags = ["-Wl,--gc-sections"])],
                    with_features = [with_feature_set(features = ["opt"])],
                ),
            ],
        )
    else:
        default_link_flags_feature = None

    supports_dynamic_linker_feature = feature(name = "supports_dynamic_linker", enabled = True)

    supports_pic_feature = feature(name = "supports_pic", enabled = True)

    user_compile_flags_feature = feature(
        name = "user_compile_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.lto_backend,
                    ACTION_NAMES.clif_match,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["%{user_compile_flags}"],
                        iterate_over = "user_compile_flags",
                        expand_if_available = "user_compile_flags",
                    ),
                ],
            ),
        ],
    )

    if (ctx.attr.cpu == "local"):
        features = [
            default_compile_flags_feature,
            default_link_flags_feature,
            supports_dynamic_linker_feature,
            supports_pic_feature,
            objcopy_embed_flags_feature,
            opt_feature,
            dbg_feature,
            user_compile_flags_feature,
            sysroot_feature,
            unfiltered_compile_flags_feature,
        ]
    elif (ctx.attr.cpu == "riscv"):
        features = [
            default_compile_flags_feature,
            default_link_flags_feature,
            opt_feature,
            user_compile_flags_feature,
            unfiltered_compile_flags_feature,
        ]
    else:
        fail("Unreachable")

    if (ctx.attr.cpu == "riscv"):
        cxx_builtin_include_directories = [
            "%{RISCV_COMPILER_PATH}%/lib/gcc/riscv32-unknown-elf/10.2.0/include",
            "%{RISCV_COMPILER_PATH}%/riscv32-unknown-elf/include/c++/10.2.0",
            "%{RISCV_COMPILER_PATH}%/riscv32-unknown-elf/include/c++/10.2.0/backward",
            "%{RISCV_COMPILER_PATH}%/riscv32-unknown-elf/include/c++/10.2.0/riscv32-unknown-elf",
            "%{RISCV_COMPILER_PATH}%/lib/gcc/riscv32-unknown-elf/10.2.0/include-fixed",
            "%{RISCV_COMPILER_PATH}%/lib/gcc/riscv32-unknown-elf/10.2.0/include",
            "%{RISCV_COMPILER_PATH}%/riscv32-unknown-elf/include",
        ]

    elif (ctx.attr.cpu == "local"):
        cxx_builtin_include_directories = ["/usr/lib/gcc/", "/usr/local/include", "/usr/include"]
    else:
        fail("Unreachable")

    artifact_name_patterns = []

    make_variables = []

    if (ctx.attr.cpu == "riscv"):
        tool_paths = [
            tool_path(
                name = "ar",
                path = "wrapper/riscv32-unknown-elf-ar",
            ),
            tool_path(name = "compat-ld", path = "/bin/false"),
            tool_path(
                name = "cpp",
                path = "wrapper/riscv32-unknown-elf-cpp",
            ),
            tool_path(
                name = "dwp",
                path = "wrapper/riscv32-unknown-elf-dwp",
            ),
            tool_path(
                name = "gcc",
                path = "wrapper/riscv32-unknown-elf-g++",
            ),
            tool_path(
                name = "gcov",
                path = "wrapper/riscv32-unknown-elf-gcov",
            ),
            tool_path(
                name = "ld",
                path = "wrapper/riscv32-unknown-elf-ld",
            ),
            tool_path(
                name = "nm",
                path = "wrapper/riscv32-unknown-elf-nm",
            ),
            tool_path(
                name = "objcopy",
                path = "wrapper/riscv32-unknown-elf-objcopy",
            ),
            tool_path(
                name = "objdump",
                path = "wrapper/riscv32-unknown-elf-objdump",
            ),
            tool_path(
                name = "strip",
                path = "wrapper/riscv32-unknown-elf-strip",
            ),
        ]
    elif (ctx.attr.cpu == "local"):
        tool_paths = [
            tool_path(name = "ar", path = "/usr/bin/ar"),
            tool_path(name = "compat-ld", path = "/usr/bin/ld"),
            tool_path(name = "cpp", path = "/usr/bin/cpp"),
            tool_path(name = "dwp", path = "/usr/bin/dwp"),
            tool_path(name = "gcc", path = "/usr/bin/gcc"),
            tool_path(name = "gcov", path = "/usr/bin/gcov"),
            tool_path(name = "ld", path = "/usr/bin/ld"),
            tool_path(name = "nm", path = "/usr/bin/nm"),
            tool_path(name = "objcopy", path = "/usr/bin/objcopy"),
            tool_path(name = "objdump", path = "/usr/bin/objdump"),
            tool_path(name = "strip", path = "/usr/bin/strip"),
        ]
    else:
        fail("Unreachable")

    out = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(out, "Fake executable")

    print(ctx.attr.cpu, cxx_builtin_include_directories)
    return [
        cc_common.create_cc_toolchain_config_info(
            ctx = ctx,
            features = features,
            action_configs = action_configs,
            artifact_name_patterns = artifact_name_patterns,
            cxx_builtin_include_directories = cxx_builtin_include_directories,
            toolchain_identifier = toolchain_identifier,
            host_system_name = host_system_name,
            target_system_name = target_system_name,
            target_cpu = target_cpu,
            target_libc = target_libc,
            compiler = compiler,
            abi_version = abi_version,
            abi_libc_version = abi_libc_version,
            tool_paths = tool_paths,
            make_variables = make_variables,
            builtin_sysroot = builtin_sysroot,
            cc_target_os = cc_target_os,
        ),
        DefaultInfo(
            executable = out,
        ),
    ]

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {
        "cpu": attr.string(mandatory = True, values = ["riscv", "local"]),
    },
    provides = [CcToolchainConfigInfo],
    executable = True,
)
