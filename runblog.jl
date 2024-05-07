
using Downloads

root() = @__DIR__

records() = Dict("Burchardi" => "10887743")

function get_packages!()
    for (kr,vr) in records()
        @info "downloading record $kr"
        dest = mkpath(joinpath(@__DIR__,kr))
        Downloads.download("https://zenodo.org/api/records/$vr/files-archive", joinpath(dest,"archive.zip"))
        # unpack L1
        Base.run(`unzip -q $(joinpath(dest,"archive.zip")) -d $(dest)`)

        # unpack L2
        Base.run(`unzip -q $(joinpath(dest,"3-replication-package.zip")) -d $(dest)`)

        @info "content of $(joinpath(dest,"3-replication-package"))"
        println(readdir(joinpath(dest,"3-replication-package")))
    end
    @info "done downloading"
end


function edit_burchardi!()

    # delete contents of Output/Tables
    # and recreate an empty folder
    rm(joinpath(@__DIR__, "Burchardi", "3-replication-package", "Output","Tables"), recursive = true)
    mkpath(joinpath(@__DIR__, "Burchardi", "3-replication-package", "Output","Tables"))


    # path to code
    p = joinpath(@__DIR__, "Burchardi", "3-replication-package", "Code")

    # read Master do file and edit it
    # we read from here
    old = readlines(joinpath(p, "DEMED_Analysis_Master.do"), keep = true)

    # patterns to replace ...
    patterns = [
        "local Figure1andA1 = 1"		=> "local Figure1andA1 = 0"		,		
        "local Table1  = 1" 			=> "local Table1  = 0" 			,			
        "local Table2  = 1" 			=> "local Table2  = 0" 			,			
        "local AppendixTableB1  = 1"	=> "local AppendixTableB1  = 0"	,			
        "local AppendixSelection = 1" 	=> "local AppendixSelection = 0",		
        "local AppendixTableB4  = 1"	=> "local AppendixTableB4  = 0"	,			
        "local AppendixTableB5  = 1"	=> "local AppendixTableB5  = 0"	,			
        "local AppendixTableB6  = 1"	=> "local AppendixTableB6  = 0"	,			
        "local AppendixTableB7  = 1"	=> "local AppendixTableB7  = 0"	,			
        "local AppendixTableB8  = 0"	=> "local AppendixTableB8  = 1"	,			
        "local AppendixTableB9  = 1"	=> "local AppendixTableB9  = 0"	
    ]

    # ... and write to there
    open(joinpath(p, "DEMED_Analysis_Master.do"), "w") do outfile
        # insert the global in the first row
        println(outfile, "global researchpath = \".\"")   # pwd does not return in docker container, so use .

        # now go over each line of file and replace patterns above
        for line in old 
            print(outfile, replace(line, patterns..., count = 1))
        end
    end

    return nothing

end



function stata_docker(relpath,version, tag; license = "Dropbox/licenses/stata.lic")

    MYHUBID = "dataeditors"
    MYIMG = "stata$(version)"
    STATALIC = joinpath(ENV["HOME"],license)
    
    @info "STATA version $(version), docker IMG tag $(tag)"
    
    Base.run(`docker run -it --rm \
      -v "$(STATALIC)":/usr/local/stata/stata.lic \
      --name="dock_stata$(version)" \
      --mount type=bind,source="$(joinpath(root(),relpath))",target=/project \
      -w /project \
      $(MYHUBID)/$(MYIMG):$(tag)`)
end

function stata_docker_prog(relpath,progpath,version, tag; license = "Dropbox/licenses/stata.lic")

    MYHUBID = "dataeditors"
    MYIMG = "stata$(version)"
    STATALIC = joinpath(ENV["HOME"],license)
    
    @info "STATA version $(version), docker IMG tag $(tag)"
    
    Base.run(`docker run -it --rm \
      -v "$(STATALIC)":/usr/local/stata/stata.lic \
      --name="dock_stata$(version)" \
      --mount type=bind,source="$(joinpath(root(),relpath))",target=/project \
      -w /project \
      $(MYHUBID)/$(MYIMG):$(tag) -b $(progpath)`)
end


function run()
    get_packages!()
    edit_burchardi!()
    broot = joinpath(root(),"Burchardi","3-replication-package")
    
    @info "run with stata 16"
    stata_docker_prog(broot,"Code/DEMED_Analysis_Master.do","16","2023-06-13")

    # rename the output table 
    # for f in readdir(joinpath(broot,"Output","Tables"), join = true)
    #     (p,ext) = splitext(f)
    #     @info "renaming $f"
    #     mv(f, joinpath(p * "-v16" * ext))
    # end
    # println(readdir(joinpath(broot,"Output","Tables"), join = true))

    # @info "run with stata 18"
    # stata_docker_prog("Burchardi/3-replication-package","Code/DEMED_Analysis_Master.do","18","2024-04-30")

end