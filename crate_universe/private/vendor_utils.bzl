"""Utility functions for use with the `crates_vendor` rule"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

_BUILDIFIER_VERSION = "8.2.0"
_BUILDIFIER_URL_TEMPLATE = "https://github.com/bazelbuild/buildtools/releases/download/v{version}/{bin}"
_BUILDIFIER_INTEGRITY = {
    "buildifier-darwin-amd64": "sha256-MJs8O/zEsVM9X395atvSZiNc+28BRQ8+N0I1J9IJowk=",
    "buildifier-darwin-arm64": "sha256-4IOBo+0dWcChfRzuHU52hMbOH8O1z6G9kqX+l4s4tH0=",
    "buildifier-linux-amd64": "sha256-PnnmwEAbXzb43038aGEnJV0lx+3clZm4d5uXt+9M3ac=",
    "buildifier-linux-arm64": "sha256-xiSoM7+mTTpFfvAjXu8NvaA2lHaKqzP3F6f/0/gD0nI=",
    "buildifier-linux-riscv64": "sha256-ST3IMasxi3f/cASYK2KAtcYMegh+Vv3Ut2EIGAYhfeM=",
    "buildifier-linux-s390x": "sha256-65R3xLzMC++yeFqPkTKY36lUHhq1Du5nFa0zTbOaMKY=",
    "buildifier-windows-amd64.exe": "sha256-on/PdSFBT4IUeHmJ3Psqx9P3wotW5EOE5foGEJlTwvE=",
}

def crates_vendor_deps():
    """Define dependencies of the `crates_vendor` rule

    Returns:
        list[struct(repo=str, is_dev_dep=bool)]: List of the dependency repositories.
    """
    direct_deps = []

    for bin, integrity in _BUILDIFIER_INTEGRITY.items():
        repo = "cargo_bazel.{}".format(bin)
        maybe(
            http_file,
            name = repo,
            urls = [_BUILDIFIER_URL_TEMPLATE.format(
                bin = bin,
                version = _BUILDIFIER_VERSION,
            )],
            integrity = integrity,
            downloaded_file_path = "buildifier.exe" if bin.endswith(".exe") else "buildifier",
            executable = True,
        )
        direct_deps.append(struct(repo = repo, is_dev_dep = False))

    return direct_deps

# buildifier: disable=unnamed-macro
def crates_vendor_deps_targets():
    """Define dependencies of the `crates_vendor` rule"""

    native.config_setting(
        name = "linux_amd64",
        constraint_values = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        visibility = ["//visibility:public"],
    )

    native.config_setting(
        name = "linux_arm64",
        constraint_values = ["@platforms//os:linux", "@platforms//cpu:arm64"],
        visibility = ["//visibility:public"],
    )

    native.config_setting(
        name = "linux_riscv64",
        constraint_values = ["@platforms//os:linux", "@platforms//cpu:riscv64"],
        visibility = ["//visibility:public"],
    )

    native.config_setting(
        name = "linux_s390x",
        constraint_values = ["@platforms//os:linux", "@platforms//cpu:s390x"],
        visibility = ["//visibility:public"],
    )

    native.config_setting(
        name = "macos_amd64",
        constraint_values = ["@platforms//os:macos", "@platforms//cpu:x86_64"],
        visibility = ["//visibility:public"],
    )

    native.config_setting(
        name = "macos_arm64",
        constraint_values = ["@platforms//os:macos", "@platforms//cpu:arm64"],
        visibility = ["//visibility:public"],
    )

    native.config_setting(
        name = "windows",
        constraint_values = ["@platforms//os:windows"],
        visibility = ["//visibility:public"],
    )

    native.alias(
        name = "buildifier",
        actual = select({
            ":linux_amd64": "@cargo_bazel.buildifier-linux-amd64//file",
            ":linux_arm64": "@cargo_bazel.buildifier-linux-arm64//file",
            ":linux_riscv64": "@cargo_bazel.buildifier-linux-riscv64//file",
            ":linux_s390x": "@cargo_bazel.buildifier-linux-s390x//file",
            ":macos_amd64": "@cargo_bazel.buildifier-darwin-amd64//file",
            ":macos_arm64": "@cargo_bazel.buildifier-darwin-arm64//file",
            ":windows": "@cargo_bazel.buildifier-windows-amd64.exe//file",
        }),
        visibility = ["//visibility:public"],
    )
