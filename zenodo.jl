using SimpleArgParse
using Downloads
using ZipStreams

usage::String = raw"""
Usage: zenodo.jl --record <RECORD> [--dest <DIRECTORY>] [--verbose] [--help]

A Julia script to download zenodo records.

Options:
    -r, --record <RECORD> ID of the zenodo record
    -d, --dest <DIRECTORY> destination of package on disk.
    -v, --verbose         Enable verbose message output.
    -h, --help            Print this help message.

Examples:
    $ julia zenodo.jl --record 10887743 --verbose
    $ julia zenodo.jl --help
""";


function main()

    args = ArgumentParser(description="Zenodo Downloader.", add_help=true)
    args = add_argument(args, "-r", "--record", type=String, required=true, default="10887743", description="Zenodo Record ID.")
    args = add_argument(args, "-d", "--dest", type=String, required=true, default=".", description="Where to save record on disk.")
    args = add_argument(args, "-v", "--verbose", type=Bool, default=false, description="Verbose mode switch.")
    args = add_example(args, "julia zenodo.jl --record 10887743 --verbose")
    args = add_example(args, "julia zenodo.jl --help")
    args = parse_args(args)

    # print the autogenerated usage/help message in yellow
    # help(args, color="yellow")

    # overwrite the usage member with the `usage` string and print the help message in cyan
    args.usage::String = usage
    help(args, color="cyan")
    
    # check boolean flags passed via command-line
    # get_value(args, "verbose") && println("Verbose mode enabled")
    # get_value(args, "v")       && println("Verbose mode enabled")
    # get_value(args, "--help")  && println("Help mode enabled")

    # check values
    # has_key(args, "record")  && println("record: ", get_value(args, "record"))

    rec = get_value(args,"record")
    dest = mkpath(joinpath(@__DIR__,rec))
    println("writing to $(joinpath(dest,"archive.zip"))")

    
    # use `set_value` to override defaults or values passed in via command-line
    # has_key(args, "help") && set_value(args, "help", true)
    # has_key(args, "help") && help(args, color="green")

    # check if SHA-256 hash 2-byte key exists and print it if it does
    has_key(args, "help") && println("\nHash key: $(get_key(args, "help"))\n")
    
    # download package
    Downloads.download("https://zenodo.org/api/records/$(rec)/files-archive", joinpath(dest,"archive.zip"))

    # unpack
    run(`unzip $(joinpath(dest,"archive.zip")) -d $(dest)`);
    
    return 0
end

main()