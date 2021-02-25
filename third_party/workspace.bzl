load(":riscv_compiler_configure.bzl", "riscv_compiler_configure")

def pre_process():
    pass

def post_process():
    pass

def init_dependencies():
    pre_process()
    post_process()

def init_env():
    riscv_compiler_configure(
        name = "toolchain",
        remote_config_repo = "../toolchain_riscv",
    )
