load("@rules_cc//cc/common:cc_common.bzl", "cc_common")

RELEASE_CFLAGS = [
    "-Os",
    "-flto=thin",
]

DEV_CFLAGS = [
    "-g",
    "-fsanitize=address",
    "-fsanitize=undefined",
]

RELEASE_LINKFLAGS = [
    "-flto=thin",
]

DEV_LINKFLAGS = [
    "-g",
    "-fsanitize=address",
    "-fsanitize=undefined",
]

def _my_transition_impl(settings, attr):
    _ignore = (settings, attr)

    copt = list(settings["//command_line_option:copt"])
    linkopt = list(settings["//command_line_option:linkopt"])

    mode = settings["//command_line_option:compilation_mode"]

    if mode == "opt":
        print("Applying release flags")
        copt.extend(RELEASE_CFLAGS)
        linkopt.extend(RELEASE_LINKFLAGS)
    else:
        print("Applying development flags")
        copt.extend(DEV_CFLAGS)
        linkopt.extend(DEV_LINKFLAGS)

    return {
        "//command_line_option:copt": copt,
        "//command_line_option:linkopt": linkopt,
    }

_my_transition = transition(
    implementation = _my_transition_impl,
    inputs = [
        "//command_line_option:compilation_mode",
        "//command_line_option:copt",
        "//command_line_option:linkopt",
    ],
    outputs = [
        "//command_line_option:copt",
        "//command_line_option:linkopt",
    ],
)

def _apply_flags_impl(ctx):
    return [DefaultInfo(files = ctx.attr.cc_target[0][DefaultInfo].files)]


apply_flags = rule(
    implementation = _apply_flags_impl,
    attrs = {
        "cc_target": attr.label(cfg = _my_transition),
    },
)
