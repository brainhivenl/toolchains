load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "feature",
    "flag_group",
    "flag_set",
    "tool_path",
)

all_link_actions = [
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
]

def _create_config_impl(ctx):
    default_linker_flags = feature(
        name = "default_linker_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = ([
                    flag_group(
                        flags = ["-lstdc++"],
                    ),
                ]),
            ),
        ],
    )

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        features = [default_linker_flags],
        toolchain_identifier = "{}-toolchain".format(ctx.attr.cpu),
        host_system_name = "local",
        target_system_name = ctx.attr.target,
        target_cpu = ctx.attr.cpu,
        target_libc = ctx.attr.libc,
        compiler = "gcc",
        abi_version = "unknown",
        abi_libc_version = "unknown",
        cxx_builtin_include_directories = [
            "/opt/homebrew/Cellar/{}/11.2.0_1/toolchain/{}/include/".format(ctx.attr.target, ctx.attr.target),
            "/opt/homebrew/Cellar/{}/11.2.0_1/toolchain/{}/sysroot/".format(ctx.attr.target, ctx.attr.target),
            "/opt/homebrew/Cellar/{}/11.2.0_1/toolchain/lib/gcc/{}/11.2.0/include/".format(ctx.attr.target, ctx.attr.target),
        ],
        tool_paths = [
            tool_path(
                name = "ld",
                path = "/opt/homebrew/bin/{}-ld".format(ctx.attr.target),
            ),
            tool_path(
                name = "ar",
                path = "/opt/homebrew/bin/{}-ar".format(ctx.attr.target),
            ),
            tool_path(
                name = "cpp",
                path = "/opt/homebrew/bin/{}-cpp".format(ctx.attr.target),
            ),
            tool_path(
                name = "gcc",
                path = "/opt/homebrew/bin/{}-gcc".format(ctx.attr.target),
            ),
            tool_path(
                name = "gcov",
                path = "/opt/homebrew/bin/{}-gcov".format(ctx.attr.target),
            ),
            tool_path(
                name = "nm",
                path = "/opt/homebrew/bin/{}-nm".format(ctx.attr.target),
            ),
            tool_path(
                name = "objdump",
                path = "/opt/homebrew/bin/{}-objdump".format(ctx.attr.target),
            ),
            tool_path(
                name = "strip",
                path = "/opt/homebrew/bin/{}-strip".format(ctx.attr.target),
            ),
        ],
    )

def macos_cross_toolchain(name, cpu, libc):
    _create_config(
        name = "{}_config".format(name),
        libc = libc,
        cpu = cpu,
        target = name,
    )

    native.cc_toolchain(
        name = "cc_{}".format(name),
        all_files = ":empty",
        compiler_files = ":empty",
        dwp_files = ":empty",
        linker_files = ":empty",
        objcopy_files = ":empty",
        strip_files = ":empty",
        supports_param_files = 0,
        toolchain_config = ":{}_config".format(name),
        toolchain_identifier = "{}-toolchain".format(name),
    )

    native.toolchain(
        name = name,
        exec_compatible_with = [
            "@platforms//os:macos",
        ],
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:{}".format(cpu),
        ],
        toolchain = ":cc_{}".format(name),
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
        visibility = ["//visibility:public"],
    )

_create_config = rule(
    implementation = _create_config_impl,
    attrs = {
        "cpu": attr.string(mandatory = True),
        "libc": attr.string(mandatory = True),
        "target": attr.string(mandatory = True),
    },
    provides = [CcToolchainConfigInfo],
)
