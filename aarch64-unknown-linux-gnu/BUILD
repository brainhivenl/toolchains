load("//:macos.bzl", "macos_cross_toolchain")

filegroup(name = "empty")

macos_cross_toolchain(
    name = "toolchain",
    bin_prefix = "aarch64-linux-gnu",
    cpu = "aarch64",
    target = "aarch64-unknown-linux-gnu",
)
