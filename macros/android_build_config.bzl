load(":android_utils.bzl", "package_to_path", "sanitize_name")

def _values_to_const(k, vs):
    return "public final static %s %s = %s;" % (vs[0], k, vs[1])

# Implementation based on https://github.com/bazelbuild/bazel/issues/563#issuecomment-391779761

def _build_config_impl(ctx, **kwargs):
    # needed to disambiguate multiple rules in the same package
    sanitized_name = sanitize_name(ctx.label.name)
    o = ctx.actions.declare_file(package_to_path(ctx.attr.package) + "/" + sanitized_name + "/BuildConfig.java")
    head = [
        "package %s;" % ctx.attr.package,
        "public class BuildConfig {",
    ]
    last = ["}"]
    debug = "false" if ctx.var['COMPILATION_MODE'] == "opt" else "true"
    values = ctx.attr.build_config_fields | {
        "DEBUG": ["boolean", 'Boolean.parseBoolean("%s")' % debug],
        "APPLICATION_ID": ["String", '"%s"' % ctx.attr.application_id],
    }
    xs = [_values_to_const(x, values[x]) for x in values]
    ctx.actions.write(o, "\n".join(
        head + xs + last
    ))
    return [DefaultInfo(files = depset([o])), OutputGroupInfo(all_files = depset([o]))]

android_build_config = rule(
    implementation = _build_config_impl,
    attrs = {
        "package": attr.string(mandatory = True, doc = "package for generated class"),
        "application_id": attr.string(mandatory=True, doc="Application ID for the android binary"),
        "build_config_fields": attr.string_list_dict(doc = "BuildConfig values, KEY -> [TYPE, VALUE]"),
    },
)
