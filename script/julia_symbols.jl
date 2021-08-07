#!/bin/env julia

# adapted from https://github.com/JuliaEditorSupport/julia-vim/blob/master/autoload/generate_latex_symbols_table.jl

# needs postprocessing due to composing chars (removing whitespace around symbols)

using REPL

open("julia.json","w") do f
    println(f, "[")
    println(f, join([string("  [ \" ", unicode, " \", \"\\", latex, "\"],\n") for (latex,unicode) in sort!(vcat(collect(REPL.REPLCompletions.latex_symbols),collect(REPL.REPLCompletions.emoji_symbols)), by=x->x[2])]))
    println(f, "]")
end
