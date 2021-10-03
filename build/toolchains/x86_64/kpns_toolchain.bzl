load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "tool_path",
    "feature",
    "flag_group",
    "flag_set",
)
load("@bazel_tools//tools/cpp:unix_cc_toolchain_config.bzl", "cc_toolchain_config")
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")

TOOLCHAIN_ROOT = "external/toolchain_x86_64"
SYSROOT = "{}/x86_64-unknown-linux-gnu/sysroot".format(TOOLCHAIN_ROOT)

SYSTEM_INCLUDE_PATHS = [
    "{}/lib/gcc/x86_64-unknown-linux-gnu/11.2.0/include".format(TOOLCHAIN_ROOT),
    "{}/lib/gcc/x86_64-unknown-linux-gnu/11.2.0/include-fixed".format(TOOLCHAIN_ROOT),
    "{}/include".format(TOOLCHAIN_ROOT),
    "{}/usr/include".format(SYSROOT),
]

SYSTEM_CPP_INCLUDE_PATHS = [
    "{}/x86_64-unknown-linux-gnu/include/c++/11.2.0".format(TOOLCHAIN_ROOT),
    "{}/x86_64-unknown-linux-gnu/include/c++/11.2.0/x86_64-unknown-linux-gnu".format(TOOLCHAIN_ROOT),
    "{}/x86_64-unknown-linux-gnu/include/c++/11.2.0/backward".format(TOOLCHAIN_ROOT),
]

_ASM_ALL_ACTIONS = [
    ACTION_NAMES.assemble,
    ACTION_NAMES.preprocess_assemble,
]

_CPP_ALL_COMPILE_ACTIONS = [
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.lto_backend,
    ACTION_NAMES.clif_match,
]

_C_ALL_COMPILE_ACTIONS = [
    ACTION_NAMES.c_compile,
]

_LD_ALL_ACTIONS = [
    ACTION_NAMES.cpp_link_executable,
]

def _isystem_flags(include_paths):
    result = []
    for inc_path in include_paths:
        result.append("-isystem")
        result.append(inc_path)
    return result

_INCLUDE_FEATURE = feature(
    name = "includes",
    enabled = True,
    flag_sets = [
        flag_set(
            actions = _CPP_ALL_COMPILE_ACTIONS + _C_ALL_COMPILE_ACTIONS + _ASM_ALL_ACTIONS,
            flag_groups = [
                flag_group(
                    # Disable system includes, then re-enable includes using -I flag
                    flags = [
                        "-B{}".format(TOOLCHAIN_ROOT),
                        "-nostdinc",
                        "-no-canonical-prefixes",
                        "-fno-canonical-system-headers",
                        "-Wno-builtin-macro-redefined",
                        "--sysroot={}".format(SYSROOT),
                        "-D__DATE__=\"redacted\"",
                        "-D__TIMESTAMP__=\"redacted\"",
                        "-D__TIME__=\"redacted\"",
                    ] + _isystem_flags(SYSTEM_INCLUDE_PATHS),
                ),
            ],
        ),
        flag_set(
            actions = _CPP_ALL_COMPILE_ACTIONS,
            flag_groups = [
                flag_group(
                    flags = [
                        "-nostdinc++"
                    ] + _isystem_flags(SYSTEM_CPP_INCLUDE_PATHS),
                ),
            ],
        ),
    ],
)

_ALL_WARNINGS_FEATURE = feature(
    name = "all_warnings",
    enabled = False,
    flag_sets = [
        flag_set(
            actions = _CPP_ALL_COMPILE_ACTIONS + _C_ALL_COMPILE_ACTIONS,
            flag_groups = [
                flag_group(
                    flags = ["-Wall", "-Wpedantic"],
                ),
            ],
        ),
    ],
)
_ALL_WARNINGS_AS_ERRORS_FEATURE = feature(
    name = "all_warnings_as_errors",
    enabled = False,
    flag_sets = [
        flag_set(
            actions = _CPP_ALL_COMPILE_ACTIONS + _C_ALL_COMPILE_ACTIONS,
            flag_groups = [
                flag_group(
                    flags = ["-Werror"],
                ),
            ],
        ),
    ],
)

_REPRODUCIBLE_FEATURE = feature(
    name = "reproducible",
    enabled = True,
    flag_sets = [
        flag_set(
            actions = _CPP_ALL_COMPILE_ACTIONS + _C_ALL_COMPILE_ACTIONS + _ASM_ALL_ACTIONS,
            flag_groups = [
                flag_group(
                    flags = [
                        "-Werror=date-time",
                    ],
                ),
            ],
        ),
    ],
)

_EXCEPTIONS_FEATURE = feature(
    name = "exceptions",
    enabled = False,
    flag_sets = [
        flag_set(
            actions = _CPP_ALL_COMPILE_ACTIONS,
            flag_groups = [
                flag_group(
                    flags = [
                        # Disable Exceptions
                        "-fno-exceptions",
                        "-fno-non-call-exceptions",
                    ],
                ),
            ],
        ),
    ],
)

_COVERAGE_FEATURE = feature(
    name = "coverage",
    flag_sets = [
        flag_set(
            actions = _CPP_ALL_COMPILE_ACTIONS + _C_ALL_COMPILE_ACTIONS,
            flag_groups = [
                flag_group(
                    flags = ["--coverage", "-fprofile-instr-generate", "-fcoverage-mapping"],
                ),
            ],
        ),
        flag_set(
            actions = _LD_ALL_ACTIONS,
            flag_groups = [flag_group(flags = ["-fprofile-instr-generate"])],
        ),
    ],
    provides = ["profile"],
)

_SYMBOL_GARBAGE_COLLECTION = feature(
    name = "symbol_garbage_collection",
    enabled = True,
    flag_sets = [
        flag_set(
            actions = _CPP_ALL_COMPILE_ACTIONS + _C_ALL_COMPILE_ACTIONS,
            flag_groups = [
                flag_group(
                    flags = [
                        # Prime sections for garbage collection during compilation
                        "-ffunction-sections",
                        "-fdata-sections",
                    ],
                ),
            ],
        ),
        flag_set(
            actions = _LD_ALL_ACTIONS,
            flag_groups = [
                flag_group(
                    flags = [
                        # Remove dead sections of code at link time
                        "-Wl,--gc-sections",
                    ],
                ),
            ],
        ),
    ],
)

_DEBUG_FEATURE = feature(
    name = "dbg",
    enabled = False,
    flag_sets = [
        flag_set(
            actions = _CPP_ALL_COMPILE_ACTIONS + _C_ALL_COMPILE_ACTIONS,
            flag_groups = [
                flag_group(
                    flags = [
                        "-O0",
                        "-g3",
                    ],
                ),
            ],
        ),
        flag_set(
            actions = ["ACTION_NAMES.cpp_link_executable"],
            flag_groups = [
                flag_group(
                    flags = ["-Wl", "--gdb-index"],
                ),
            ],
        ),
    ],
    provides = ["compilation_mode"],
)

_FASTBUILD_FEATURE = feature(
    name = "fastbuild",
    enabled = False,
    flag_sets = [
        flag_set(
            actions = _CPP_ALL_COMPILE_ACTIONS + _C_ALL_COMPILE_ACTIONS,
            flag_groups = [
                flag_group(
                    flags = [
                        "-O",
                    ],
                ),
            ],
        ),
    ],
    provides = ["compilation_mode"],
)

_OPT_FEATURE = feature(
    name = "opt",
    enabled = False,
    flag_sets = [
        flag_set(
            actions = _CPP_ALL_COMPILE_ACTIONS + _C_ALL_COMPILE_ACTIONS,
            flag_groups = [
                flag_group(
                    flags = [
                        # Optimise for space
                        "-O2",
                        # Inline small functions if less instructions are likely to be executed
                        "-flto",
                    ],
                ),
            ],
        ),
        flag_set(
            actions = _LD_ALL_ACTIONS,
            flag_groups = [
                flag_group(
                    flags = [
                        # Link time optimisation
                        "-flto",
                    ],
                ),
            ],
        ),
    ],
    provides = ["compilation_mode"],
)

# Leaving for compatibility
_OUTPUT_FORMAT_FEATURE = feature(
    name = "output_format",
    enabled = False,
)

_MISC = feature(
    name = "misc",
    enabled = True,
    flag_sets = [
        flag_set(
            actions = _CPP_ALL_COMPILE_ACTIONS,
            flag_groups = [
                flag_group(
                    flags = [
                        "-x",
                        "c++",
                        "-std=c++17",
                    ],
                ),
            ],
        ),
        flag_set(
            actions = _LD_ALL_ACTIONS,
            flag_groups = [
                flag_group(
                    flags = [
                        "-l:libstdc++.a",
                        "-lm",
                    ],
                ),
            ],
        ),
    ],
)

def _kpns_toolchain_config_info_impl(ctx):
    tool_paths = [
        tool_path(
            name = "ar",
            path = "wrappers/ar",
        ),
        tool_path(
            name = "cpp",
            path = "wrappers/cpp",
        ),
        tool_path(
            name = "gcc",
            path = "wrappers/gcc",
        ),
        tool_path(
            name = "g++",
            path = "wrappers/g++",
        ),
        tool_path(
            name = "gcov",
            path = "wrappers/gcov",
        ),
        tool_path(
            name = "ld",
            path = "wrappers/ld",
        ),
        tool_path(
            name = "nm",
            path = "wrappers/nm",
        ),
        tool_path(
            name = "objdump",
            path = "wrappers/objdump",
        ),
        tool_path(
            name = "strip",
            path = "wrappers/strip",
        ),
    ]

    toolchain_config_info = cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = ctx.attr.toolchain_identifier,
        host_system_name = "x86_64-unknown-linux-gnu",
        target_system_name = "x86_64-unknown-linux-gnu",
        target_cpu = "k8",
        target_libc = "glibc",
        compiler = "gcc",
        abi_version = "11.2.0",
        abi_libc_version = "2.27",
        tool_paths = tool_paths,
        features = [
            _ALL_WARNINGS_FEATURE,
            _ALL_WARNINGS_AS_ERRORS_FEATURE,
            _REPRODUCIBLE_FEATURE,
            _INCLUDE_FEATURE,
            _SYMBOL_GARBAGE_COLLECTION,
            _DEBUG_FEATURE,
            _OPT_FEATURE,
            _FASTBUILD_FEATURE,
            _OUTPUT_FORMAT_FEATURE,
            _COVERAGE_FEATURE,
            _MISC,
        ]
    )

    return toolchain_config_info

kpns_toolchain_config = rule(
    implementation = _kpns_toolchain_config_info_impl,
    attrs = {
        "toolchain_identifier": attr.string(
            mandatory = True,
            doc = "Identifier used by the toolchain, this should be consistent with the cc_toolchain rule attribute",
        ),
    },
    provides = [CcToolchainConfigInfo],
)

def kpns_toolchain(name):
    toolchain_config = name + "_config"
    toolchain_identifier = "gcc"

    native.filegroup(
        name = "compiler_components",
        srcs = [
            ":wrappers",
            "@toolchain_x86_64//:contents",
        ],
    )
    compiler_components_target = ":compiler_components"

    kpns_toolchain_config(
        name = toolchain_config,
        toolchain_identifier = toolchain_identifier
    )

    cc_toolchain(
        name = name,
        all_files = compiler_components_target,
        compiler_files = compiler_components_target,
        dwp_files = compiler_components_target,
        linker_files = compiler_components_target,
        objcopy_files = compiler_components_target,
        strip_files = compiler_components_target,
        as_files = compiler_components_target,
        ar_files = compiler_components_target,
        supports_param_files = 1,
        toolchain_config = ":" + toolchain_config,
        toolchain_identifier = toolchain_identifier,
    )

    native.toolchain(
        name = name + "_cc_toolchain",
        exec_compatible_with = [
            "@platforms//cpu:x86_64",
            "@platforms//os:linux",
        ],
        target_compatible_with = [
            "@platforms//cpu:x86_64",
            "@platforms//os:linux",
        ],
        toolchain = ":" + name,
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    )
