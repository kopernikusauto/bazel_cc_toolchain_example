workspace(name = "avp")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")


###############################################################################
# Skylib provides useful utilities

http_archive(
    name = "bazel_skylib",
    urls = [
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.3/bazel-skylib-1.0.3.tar.gz",
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.0.3/bazel-skylib-1.0.3.tar.gz",
    ],
    sha256 = "1c531376ac7e5a180e0237938a2536de0c54d93f5c278634818e0efc952dd56c",
)
load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
bazel_skylib_workspace()

###############################################################################
# Rust

git_repository(
    name = "rules_rust",
    commit = "696a4e7367c8ac954d2015626b1c5d9b52d7de73",
    remote = "https://github.com/bazelbuild/rules_rust",
    shallow_since = "1631639614 -0700"
)

load("@rules_rust//rust:repositories.bzl", "rust_repositories")
load("@rules_rust//tools/rust_analyzer:deps.bzl", "rust_analyzer_deps")

rust_repositories(version="1.55.0", edition="2018", include_rustc_srcs=True)
rust_analyzer_deps()

###############################################################################

# Our native toolchains

http_archive(
    name = "toolchain_x86_64",
    url = "https://kpnsdev-third-party-software.s3.eu-central-1.amazonaws.com/native_toolchain_x86_64-unknown-linux-gnu.tar.xz",
    sha256 = "9e779803f998129165c451f0b5e56301f8ebc302a51460986f29adae4d9e5e7d",
    strip_prefix = "x86_64-unknown-linux-gnu",
    build_file = "//build/toolchains:kpnsdev-toolchain.BUILD",
)

load("//build:toolchains.bzl", "register_all_toolchains")
register_all_toolchains()
