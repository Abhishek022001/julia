cmd = Base.julia_cmd()
cmd = `$cmd --startup-file=no --history-file=no`
output_type = nothing  # exe, sharedlib, sysimage
static_call_graph = false
strict = false
verbose = false
outname = nothing
file = nothing

help = findfirst(x->x == "--help", ARGS)
if help !== nothing
    println(
        """
        Usage: julia juliac.jl [--output-exe | --output-lib | --output-sysimage] <name> [options] <file.jl>
        --static-call-graph  Only output code statically determined to be reachable
        --strict             Error if call graph cannot be fully statically determined
        --verbose            Request verbose output
        """)
    exit(0)
end

let i = 1
    while i <= length(ARGS)
        arg = ARGS[i]
        if arg == "--output-exe" || arg == "--output-lib" || arg == "--output-sysimage"
            isnothing(output_type) || error("Multiple output types specified")
            global output_type = arg
            i == length(ARGS) && error("Output specifier requires an argument")
            global outname = ARGS[i+1]
            i += 1
        elseif arg == "--strict"
            global strict = true
        elseif arg == "--static-call-graph"
            global static_call_graph = true
        elseif arg == "--verbose"
            global verbose = true
        else
            if arg[1] == '-' || !isnothing(file)
                println("Unexpected argument `$arg`")
                exit(1)
            end
            global file = arg
        end
        i += 1
    end
end

isnothing(outname) && error("No output file specified")
isnothing(file) && error("No input file specified")

absfile = abspath(file)
cflags = readchomp(`$(cmd) $(joinpath(Sys.BINDIR, Base.DATAROOTDIR,"julia", "julia-config.jl")) --cflags `)
cflags = Base.shell_split(cflags)
allflags = readchomp(`$(cmd) $(joinpath(Sys.BINDIR, Base.DATAROOTDIR,"julia", "julia-config.jl")) --allflags`)
allflags = Base.shell_split(allflags)
tmpdir = mktempdir(cleanup=false)
init_path = joinpath(tmpdir, "init.a")
img_path = joinpath(tmpdir, "img.a")
bc_path = joinpath(tmpdir, "img-bc.a")

is_small_image() = static_call_graph ? `--small-image=yes` : ``
is_strict() = strict ? `--no-dispatch-precompile=yes` : ``
is_verbose() = verbose ? `--verbose-compilation=yes` : ``
cmd = addenv(`$cmd --project=$(Base.active_project()) --output-o $img_path --output-incremental=no --strip-ir --strip-metadata $(is_small_image()) $(is_strict()) $(is_verbose()) $(joinpath(@__DIR__,"buildscript.jl")) $absfile $output_type`, "OPENBLAS_NUM_THREADS" => 1, "JULIA_NUM_THREADS" => 1)

if !success(pipeline(cmd; stdout, stderr))
    println(stderr, "\nFailed to compile $file")
    exit(1)
end

run(`cc $(cflags) -g -c -o $init_path $(joinpath(@__DIR__, "init.c"))`)

if output_type == "--output-lib" || output_type == "--output-sysimage"
    of, ext = splitext(outname)
    soext = "." * Base.BinaryPlatforms.platform_dlext()
    if ext == ""
        outname = of * soext
    end
end

julia_libs = Base.shell_split(Base.isdebugbuild() ? "-ljulia-debug -ljulia-internal-debug" : "-ljulia -ljulia-internal")
try
    if output_type == "--output-lib"
        run(`cc $(allflags) -o $outname -shared -Wl,$(Base.Linking.WHOLE_ARCHIVE) $img_path  -Wl,$(Base.Linking.NO_WHOLE_ARCHIVE) $init_path  $(julia_libs)`)
    elseif output_type == "--output-sysimage"
        run(`cc $(allflags) -o $outname -shared -Wl,$(Base.Linking.WHOLE_ARCHIVE) $img_path  -Wl,$(Base.Linking.NO_WHOLE_ARCHIVE)             $(julia_libs)`)
    else
        run(`cc $(allflags) -o $outname -Wl,$(Base.Linking.WHOLE_ARCHIVE) $img_path -Wl,$(Base.Linking.NO_WHOLE_ARCHIVE) $init_path $(julia_libs)`)
    end
catch
    println("\nCompilation failed.")
    exit(1)
end