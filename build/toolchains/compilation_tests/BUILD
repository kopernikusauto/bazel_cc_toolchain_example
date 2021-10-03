package(default_visibility=["//visibility:public"])

load("@rules_rust//rust:rust.bzl", "rust_binary")


cc_binary(
    name="hello",
    srcs=["hello_main.cc"],
    deps=[":hello_lib"]
)

rust_binary(
    name="hello_rs",
    srcs=["hello_main.rs"],
    deps=[":hello_lib"],
)

cc_binary(
    name="hello_c",
    srcs=["hello.c"]
)

cc_library(
    name="hello_lib",
    hdrs=["hello_lib.hpp"],
    srcs=["hello_lib.cc"],
)
