def _repos_are_siblings():
    return Label("@foo//bar").workspace_root.startswith("../")

def _is_windows(ctx):
    return ctx.os.name.lower().find("windows") != -1

def _wrap_bash_cmd(ctx, cmd):
    if _is_windows(ctx):
        bazel_sh = _get_env_var(ctx, "BAZEL_SH")
        if not bazel_sh:
            fail("BAZEL_SH environment variable is not set")
        cmd = [bazel_sh, "-l", "-c", " ".join(["\"%s\"" % s for s in cmd])]
    return cmd

# Executes specified command with arguments and calls 'fail' if it exited with
# non-zero code
def _execute_and_check_ret_code(repo_ctx, cmd_and_args):
    result = repo_ctx.execute(cmd_and_args, timeout = 60)
    if result.return_code != 0:
        fail(("Non-zero return code({1}) when executing '{0}':\n" + "Stdout: {2}\n" +
              "Stderr: {3}").format(
            " ".join(cmd_and_args),
            result.return_code,
            result.stdout,
            result.stderr,
        ))

def _get_env_var(ctx, name):
    if name in ctx.os.environ:
        return ctx.os.environ[name]
    else:
        return None

# Apply a patch_file to the repository root directory
# Runs 'git apply' on Unix, 'patch -p1' on Windows.
def _apply_patch(ctx, patch_file):
    if _is_windows(ctx):
        patch_command = ["patch", "-p1", "-d", ctx.path("."), "-i", ctx.path(patch_file)]
    else:
        patch_command = ["git", "apply", "-v", ctx.path(patch_file)]

    cmd = _wrap_bash_cmd(ctx, patch_command)
    _execute_and_check_ret_code(ctx, cmd)

def _apply_delete(ctx, paths):
    for path in paths:
        if path.startswith("/"):
            fail("refusing to rm -rf path starting with '/': " + path)
        if ".." in path:
            fail("refusing to rm -rf path containing '..': " + path)
    cmd = _wrap_bash_cmd(ctx, ["rm", "-rf"] + [ctx.path(path) for path in paths])
    _execute_and_check_ret_code(ctx, cmd)

def _use_system_lib(ctx, name):
    syslibenv = _get_env_var(ctx, "custom_SYSTEM_LIBS")
    if syslibenv:
        for n in syslibenv.strip().split(","):
            if n.strip() == name:
                return True
    return False

def _third_party_http_archive(ctx):
    use_syslib = _use_system_lib(ctx, ctx.attr.name)

    # Use "BUILD.bazel" to avoid conflict with third party projects that contain a
    # file or directory called "BUILD"
    buildfile_path = ctx.path("BUILD.bazel")

    if use_syslib:
        if ctx.attr.system_build_file == None:
            fail("Bazel was configured with custom_SYSTEM_LIBS to use a system " +
                 "library for %s, but no system build file for %s was configured. " +
                 "Please add a system_build_file attribute to the repository rule" +
                 "for %s." % (ctx.attr.name, ctx.attr.name, ctx.attr.name))
        ctx.symlink(Label(ctx.attr.system_build_file), buildfile_path)

    else:
        ctx.download_and_extract(
            ctx.attr.urls,
            "",
            ctx.attr.sha256,
            ctx.attr.type,
            ctx.attr.strip_prefix,
        )
        if ctx.attr.delete:
            _apply_delete(ctx, ctx.attr.delete)
        if ctx.attr.patch_file != None:
            _apply_patch(ctx, ctx.attr.patch_file)
        ctx.symlink(Label(ctx.attr.build_file), buildfile_path)

    link_dict = {}
    if use_syslib:
        link_dict.update(ctx.attr.system_link_files)

    for internal_src, external_dest in ctx.attr.link_files.items():
        # if syslib and link exists in both, use the system one
        if external_dest not in link_dict.values():
            link_dict[internal_src] = external_dest

    for internal_src, external_dest in link_dict.items():
        ctx.symlink(Label(internal_src), ctx.path(external_dest))

def _custom_http_archive(ctx):
    use_syslib = _use_system_lib(ctx, ctx.attr.name)
    if not use_syslib:
        ctx.download_and_extract(
            ctx.attr.urls,
            "",
            ctx.attr.sha256,
            ctx.attr.type,
            ctx.attr.strip_prefix,
        )
        if ctx.attr.delete:
            _apply_delete(ctx, ctx.attr.delete)
        if ctx.attr.patch_file != None:
            _apply_patch(ctx, ctx.attr.patch_file)

    if use_syslib and ctx.attr.system_build_file != None:
        # Use BUILD.bazel to avoid conflict with third party projects with
        # BUILD or build (directory) underneath.
        ctx.template("BUILD.bazel", ctx.attr.system_build_file, {
            "%prefix%": ".." if _repos_are_siblings() else "external",
        }, False)

    elif ctx.attr.build_file != None:
        # Use BUILD.bazel to avoid conflict with third party projects with
        # BUILD or build (directory) underneath.
        ctx.template("BUILD.bazel", ctx.attr.build_file, {
            "%prefix%": ".." if _repos_are_siblings() else "external",
        }, False)

    if use_syslib:
        for internal_src, external_dest in ctx.attr.system_link_files.items():
            ctx.symlink(Label(internal_src), ctx.path(external_dest))

def is_windows(ctx):
    return _is_windows(ctx)

# Downloads and creates Bazel repos for dependencies.
#
# This is an upgrade for tf_http_archive that works with go/tfbr-thirdparty.
#
# For link_files, specify each dict entry as:
# "//path/to/source:file": "localfile"
third_party_http_archive = repository_rule(
    implementation = _third_party_http_archive,
    attrs = {
        "sha256": attr.string(mandatory = True),
        "urls": attr.string_list(mandatory = True, allow_empty = False),
        "strip_prefix": attr.string(),
        "type": attr.string(),
        "delete": attr.string_list(),
        "build_file": attr.string(mandatory = True),
        "system_build_file": attr.string(mandatory = False),
        "patch_file": attr.label(),
        "link_files": attr.string_dict(),
        "system_link_files": attr.string_dict(),
    },
    environ = [
        "custom_SYSTEM_LIBS",
    ],
)

custom_http_archive = repository_rule(
    implementation = _custom_http_archive,
    attrs = {
        "sha256": attr.string(mandatory = True),
        "urls": attr.string_list(mandatory = True, allow_empty = False),
        "strip_prefix": attr.string(),
        "type": attr.string(),
        "delete": attr.string_list(),
        "build_file": attr.label(),
        "system_build_file": attr.string(mandatory = False),
        "patch_file": attr.label(),
        "link_files": attr.string_dict(),
        "system_link_files": attr.string_dict(),
    },
    environ = [
        "custom_SYSTEM_LIBS",
    ],
)
