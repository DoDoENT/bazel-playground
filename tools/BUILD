load("@bazelrc-preset.bzl", "bazelrc_preset")
load("@rules_java//java:java_binary.bzl", "java_binary")

bazelrc_preset(
    name = "preset",
    # Specify the path to the bazelrc file.
    strict = True,
)

java_binary(
   name = "copybara",
   main_class = "com.google.copybara.Main",
   runtime_deps = ["@com_github_google_copybara//jar"],
)
