# -*- Python -*-
"""Repository rule for arm compiler autoconfiguration."""

def _tpl(repository_ctx, tpl, substitutions = {}, out = None):
    if not out:
        out = tpl

    repository_ctx.template(
        out,
        Label("//third_party/toolchain:%s.tpl" % tpl),
        substitutions,
    )

def directory_path(repository_ctx, label):
    """Return the absolute path to a directory referred to by an absolute label"""
    label = str(label)

    # Get the prefix (before the "//", if any)
    split = label.split("/", 1)
    prefix = split[0]

    # Get the path (after the "//")
    split = split[1].split(":", 1)
    dir_path = split[0]
    dir_name = split[1]
    if dir_path == "/":
        path = "/" + dir_name
    else:
        path = dir_path + "/" + dir_name

    return repository_ctx.path(
        str(repository_ctx.path(Label(prefix + "//:WORKSPACE"))).rsplit("/", 1)[0] +
        path,
    )

def _riscv_compiler_configure_impl(repository_ctx):
    # We need to find a cross-compilation include directory for Python, so look
    # for an environment variable. Be warned, this crosstool template is only
    # regenerated on the first run of Bazel, so if you change the variable after
    # it may not be reflected in later builds. Doing a shutdown and clean of Bazel
    # doesn't fix this, you'll need to delete the generated file at something like:
    # external/local_config_arm_compiler/CROSSTOOL in your Bazel install.
    _tpl(repository_ctx, "cc_config.bzl", {
        "%{RISCV_COMPILER_PATH}%": str(repository_ctx.path(
            repository_ctx.attr.remote_config_repo,
        )),
    })

    result = repository_ctx.execute(["cp", "-r", directory_path(repository_ctx, Label("//third_party/toolchain:wrapper")), "."])
    print(result.stdout, result.stderr)
    repository_ctx.symlink(Label("//third_party/toolchain:BUILD.bazel"), "BUILD.bazel")

riscv_compiler_configure = repository_rule(
    implementation = _riscv_compiler_configure_impl,
    attrs = {
        "remote_config_repo": attr.string(mandatory = False, default = ""),
    },
)
