package(default_visibility = ["//visibility:public"])

load("@bazel_tools//tools/cpp:unix_cc_toolchain_config.bzl", "cc_toolchain_config")
#load(":cc_toolchain_config.bzl", "cc_toolchain_config")

#load(":kpns_toolchain.bzl", "kpns_toolchain")
#kpns_toolchain(name="centos7_gcc_11")

TOOLCHAIN_ROOT = "external/toolchain_x86_64"
TARGET_TUPLE = "x86_64-unknown-linux-gnu"
SYSROOT = "{}/{}/sysroot".format(TOOLCHAIN_ROOT, TARGET_TUPLE)

SYSTEM_INCLUDE_PATHS = [
    "-isystem", "{}/lib/gcc/{}/11.2.0/include".format(TOOLCHAIN_ROOT, TARGET_TUPLE),
    "-isystem", "{}/lib/gcc/{}/11.2.0/include-fixed".format(TOOLCHAIN_ROOT, TARGET_TUPLE),
    "-isystem", "{}/include".format(TOOLCHAIN_ROOT),
    "-isystem", "{}/usr/include".format(SYSROOT),
]

SYSTEM_CPP_INCLUDE_PATHS = [
    "-isystem", "{}/{}/include/c++/11.2.0".format(TOOLCHAIN_ROOT, TARGET_TUPLE),
    "-isystem", "{}/{}/include/c++/11.2.0/{}".format(TOOLCHAIN_ROOT, TARGET_TUPLE, TARGET_TUPLE),
    "-isystem", "{}/{}/include/c++/11.2.0/backward".format(TOOLCHAIN_ROOT, TARGET_TUPLE),
]

filegroup(
    name="empty",
    srcs=[],
)

filegroup(
    name = "toolchain_components",
    srcs = [
        "@toolchain_x86_64//:contents",
    ] + glob(["wrappers/*"]),
)

toolchain(
    name = "kpns_x86_64_cc_toolchain",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    toolchain = ":kpns_gcc_x86_64",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

cc_toolchain(
    name = "kpns_gcc_x86_64",
    toolchain_identifier = "gcc_x86_64",
    toolchain_config = ":toolchain_config",
    all_files = ":toolchain_components",
    ar_files = ":toolchain_components",
    as_files = ":toolchain_components",
    compiler_files = ":toolchain_components",
    dwp_files = ":empty",
    linker_files = ":toolchain_components",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 1,
    module_map = None,
)

cc_toolchain_config(
    name = "toolchain_config",
    cpu = "k8",
    compiler = "gcc",
    toolchain_identifier = "kpnsdev",
    host_system_name = "linux",
    target_system_name = "linux",
    target_libc = "2.27",
    abi_version = "local",
    abi_libc_version = "2.27",
    # Using this causes a lot of errors with the strict header checks
    #cxx_builtin_include_directories = SYSTEM_INCLUDE_PATHS + SYSTEM_CPP_INCLUDE_PATHS,
    builtin_sysroot = SYSROOT,
    tool_paths = {
        "ar": "wrappers/ar",
        "ld": "wrappers/ld",
        "llvm-cov": "None",
        "cpp": "wrapper/cpp",
        "gcc": "wrappers/gcc",
        "dwp": "None",
        "gcov": "wrapper/gcov",
        "nm": "wrapper/nm",
        "objcopy": "wrapper/objcopy",
        "objdump": "wrapper/objdump",
        "strip": "wrapper/strip"
    },
    compile_flags = [
        "-U_FORTIFY_SOURCE",
        "-fstack-protector",
        "-Wall",
        "-Wunused-but-set-parameter",
        "-Wno-free-nonheap-object",
        "-fno-omit-frame-pointer",
    ],
    opt_compile_flags = [
        "-g0",
        "-O2",
        "-D_FORTIFY_SOURCE=1",
        "-DNDEBUG",
        "-ffunction-sections",
        "-fdata-sections"
    ],
    dbg_compile_flags = ["-g"],
    cxx_flags = ["-std=c++17"],
    link_flags = [
        # Do we want to setup a toolchain with gold linker?
        "-fuse-ld=bfd",
        "-Wl,-no-as-needed",
        "-Wl,-z,relro,-z,now",
        "-pass-exit-codes",
    ],
    link_libs = [
        "-Bstatic",
        "-lstdc++",
        "-Bdynamic",
        "-lm"
    ],
    opt_link_flags = ["-Wl,--gc-sections"],
    unfiltered_compile_flags = [
        "-fno-canonical-system-headers",
        "-Wno-builtin-macro-redefined",
        "-D__DATE__=\"redacted\"",
        "-D__TIMESTAMP__=\"redacted\"",
        "-D__TIME__=\"redacted\"",
    ] + SYSTEM_INCLUDE_PATHS + SYSTEM_CPP_INCLUDE_PATHS,
    coverage_compile_flags = ["--coverage"],
    coverage_link_flags = ["--coverage"],
    supports_start_end_lib = False,
)

