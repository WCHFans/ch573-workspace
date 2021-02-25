# Config Settings
config_setting(
    name = "framework_shared_object",
    define_values = {
        "framework_shared_object": "true",
    },
    visibility = ["//visibility:public"],
)

config_setting(
    name = "macos_with_framework_shared_object",
    define_values = {
        "framework_shared_object": "true",
    },
    values = {
        "apple_platform_type": "macos",
        "cpu": "darwin",
    },
    visibility = ["//visibility:public"],
)

config_setting(
    name = "windows",
    define_values = {
        "windows": "false",
    },
    visibility = ["//visibility:public"],
)
