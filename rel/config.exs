# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
~w(rel plugins *.exs)
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
  # This sets the default release built by `mix release`
  default_release: :default,
  # This sets the default environment used by `mix release`
  default_environment: :prod

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/config/distillery.html

# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :prod do
  set(vm_args: "rel/prod.vm.args")
  set(include_erts: true)
  set(include_src: false)
  set(cookie: :"*G55CQJU,@,eg_[0bS%,:hx~t*ArIv:(s[4QhPNgWz!n)AjD{^}B,3/~DzsPNR<X")

  set(
    config_providers: [
      {Mix.Releases.Config.Providers.Elixir, ["${RELEASE_ROOT_DIR}/etc/runtime.exs"]}
    ]
  )

  set(pre_configure_hooks: "rel/hooks/pre_configure.d")

  set(
    overlays: [
      {:copy, "rel/runtime.exs", "etc/runtime.exs"}
    ]
  )
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :egon do
  set(version: current_version(:egon))

  set(
    applications: [
      :runtime_tools
    ]
  )
end
