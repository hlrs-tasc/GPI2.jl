module GPI2

using GPI2_jll
using Preferences: load_preference, @set_preferences!
using Reexport: @reexport

# Export public API
export gaspi_logger, gaspi_run

# Set defaults
const default_bindings_file = "../bindings/LibGPI2_jll.jl"
const default_libGPI2 = GPI2_jll.libGPI2

# Use preferences for library paths
const libGPI2 = load_preference(GPI2, "libGPI2", default_libGPI2)
const bindings_file = load_preference(GPI2, "bindings_file", default_bindings_file)
const gaspi_logger_executable = load_preference(GPI2, "gaspi_logger_executable", GPI2_jll.gaspi_logger_path)
const gaspi_run_executable = load_preference(GPI2, "gaspi_run_executable", GPI2_jll.gaspi_run_path)


# If the bindings file is not referring to the package-provided file, check for its existence
@static if isabspath(bindings_file) && !isfile(bindings_file)
  @error "Bindings file '$bindings_file' is missing. Please reset using `GPI2.use_jll_bindings()` and restart Julia.\nUntil then, GPI2.jl remains inoperable."
else
  # Load bindings file and reexport `gaspi_` and `GASPI_` symbols
  include(bindings_file)
  @reexport using .LibGPI2
end


"""
    use_jll_library()

Configure GPI2.jl to use `libGPI2.so` binary provided by the JLL package.
"""
function use_jll_library()
  @set_preferences!("libGPI2" => default_libGPI2)
  @info "Using JLL-provided GPI-2 library. Please restart Julia for the change to take effect."
end


"""
    use_system_library(path)

Configure GPI2.jl to use `libGPI2.so` binary provided on the local system at `path`.

!!! warning "Experimental implementation"
    This is an experimental feature and may change in future releases.
"""
function use_system_library(path)
  if !isfile(path)
    error("'$path' is not a valid file")
  end
  @set_preferences!("libGPI2" => abspath(path))
  @info "Using user-provided GPI-2 library. Please restart Julia for the change to take effect."
end


"""
    use_jll_bindings()

Configure GPI2.jl to use the C bindings file provided by the JLL package.
"""
function use_jll_bindings()
  @set_preferences!("bindings_file" => default_bindings_file)
  @info "Using JLL-compatible C bindings. Please restart Julia for the change to take effect."
end


"""
    use_system_bindings(path)

Configure GPI2.jl to use the C bindings file provided on the local system at `path`.

!!! warning "Experimental implementation"
    This is an experimental feature and may change in future releases.
"""
function use_system_bindings(path)
  if !isfile(path)
    error("'$path' is not a valid file")
  end
  @set_preferences!("bindings_file" => abspath(path))
  @info "Using user-provided C bindings. Please restart Julia for the change to take effect."
end


"""
    gaspi_logger()

Run the `gaspi_logger` tool of the GPI-2 library.

!!! warning "Experimental implementation"
    This is an experimental feature and may change in future releases.
"""
function gaspi_logger()
  try
    run(`$gaspi_logger_executable`)
  catch InterruptException
    if !isinteractive()
      exit()
    end
  end
end


"""
    gaspi_run()

Run the `gaspi_run` tool of the GPI-2 library.

!!! warning "Experimental implementation"
    This is an experimental feature and may change in future releases.
"""
function gaspi_run()
  try
    run(`$gaspi_run_executable $ARGS`)
  catch InterruptException
    if !isinteractive()
      exit()
    end
  end
end


end # module
