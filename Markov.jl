#! /usr/bin/julia

module Markov

function create_states(words::Array)::Dict
    states = Dict()
    for i in 1:length(words)
        if i + 2 < length(words)
            pfx = []
            for j in i:(i+1)
                push!(pfx, words[j])
            end
            if haskey(states, pfx)
                push!(states[pfx], words[i+2])
            else
                states[pfx] = [words[i+2]]
            end
        else
            return states
        end
    end
end

function generate_text(init::Tuple, states::Dict, maxgen::Int64)
    w1 = init[1]
    w2 = init[2]
    linelength = length(w1) + length(w2)
    print("$w1 $w2 ")
    for i in 1:maxgen
        w3 = "$(rand(states[[w1, w2]]))"
        linelength += length(w3)
        print("$w3 ")
        w1 = w2
        w2 = w3
        if linelength ≥ 60
            println()
            linelength = 0
        end
    end
    println()
end

function main()
    if length(ARGS) < 2
        @warn "Usage: julia markov.jl text.txt maxgen"
        return
    end

    words = try
        open(f->split(read(f, String)), ARGS[1])
    catch e
        @error "could not open file: $e"
        return
    end

    start = 1
    if length(ARGS) ≥ 3
        if ARGS[3] == "-r"
            start = rand(1:length(words)-1)
        end
    end
    
    states = create_states(words)
    generate_text((words[start], words[start+1]), states, parse(Int, ARGS[2]))
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

end # module