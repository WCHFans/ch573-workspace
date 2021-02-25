workspace(name = "ch573")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")
load("//systemlib:build_config.bzl", "clean_dep")
load("//third_party:workspace.bzl", "init_dependencies", "init_env")

init_env()

http_archive(
    name = "bazel_skylib",
    sha256 = "97e70364e9249702246c0e9444bccdc4b847bed1eb03c5a3ece4f83dfe6abc44",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
    ],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

# rules_foreign_cc
http_archive(
    name = "rules_foreign_cc",
    strip_prefix = "rules_foreign_cc-master",
    url = "https://github.com/bazelbuild/rules_foreign_cc/archive/master.zip",
)

load("@rules_foreign_cc//:workspace_definitions.bzl", "rules_foreign_cc_dependencies")

rules_foreign_cc_dependencies()

http_archive(
    name = "rules_python",
    sha256 = "aa96a691d3a8177f3215b14b0edc9641787abaaa30363a080165d06ab65e1161",
    url = "https://github.com/bazelbuild/rules_python/releases/download/0.0.1/rules_python-0.0.1.tar.gz",
)

# rules_py
load("@rules_python//python:repositories.bzl", "py_repositories")

py_repositories()

# Only needed if using the packaging rules.
load("@rules_python//python:pip.bzl", "pip_repositories")

pip_repositories()

init_dependencies()

# RISCV toolchain
http_archive(
    name = "toolchain_riscv",
    build_file = "//third_party/toolchain:toolchain_riscv.BUILD",
    sha256 = "15f5419083fd1a1f3077e78387c09de83937a0e42fe4b9174445fc502834e29f",
    strip_prefix = "rv32imac-toolchain",
    urls = [
        "https://github.com/WCHFans/ch573-workspace/releases/download/toolchain/rv32imac-gcc.tar.gz",
    ],
)
