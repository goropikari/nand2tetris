module CodeGenerator

using ..Parser: Parser

export gen_code


# ref: textbook p.69
const SymbolTable = Dict(
    "R0"     => 0,
    "R1"     => 1,
    "R2"     => 2,
    "R3"     => 3,
    "R4"     => 4,
    "R5"     => 5,
    "R6"     => 6,
    "R7"     => 7,
    "R8"     => 8,
    "R9"     => 9,
    "R10"    => 10,
    "R11"    => 11,
    "R12"    => 12,
    "R13"    => 13,
    "R14"    => 14,
    "R15"    => 15,
    "SP"     => 0,
    "LCL"    => 1,
    "ARG"    => 2,
    "THIS"   => 3,
    "THAT"   => 4,
    "SCREEN" => 16384,
    "KBD"    => "24576"
)

function _update_symbol_table(insts::Vector{T}) where T <: Parser.AbstractInstruction
    # resolve label address
    line_number = 0
    base_address = 16
    for inst in insts
        if inst isa Parser.Label
            SymbolTable[inst.symbol] = line_number
        else
            line_number += 1
        end

    end

    for inst in insts
        if inst isa Parser.AInstruction
            if inst.type == "symbol"
                if !haskey(SymbolTable, inst.value)
                    SymbolTable[inst.value] = base_address
                    base_address += 1
                end
            else
                address = parse(Int, inst.value)
                SymbolTable[inst.value] = address
            end
        end
    end
end

function gen_code(io::IO, insts::Vector{T}) where T <: Parser.AbstractInstruction
    _update_symbol_table(insts)

    for inst in insts
        _gen_code(io, inst)
    end
end
_gen_code(io::IO, inst::Parser.AbstractInstruction) = nothing

function _gen_code(io::IO, inst::Parser.AInstruction)
    binary_rep = string(SymbolTable[inst.value], base=2, pad=16)
    println(io, binary_rep)
end

const Destiation = Dict(
    ""    => "000",
    "M"   => "001",
    "D"   => "010",
    "MD"  => "011",
    "A"   => "100",
    "AM"  => "101",
    "AD"  => "110",
    "ADM" => "111"
)

const Compute = Dict(
    "0"   => "0101010",
    "1"   => "0111111",
    "-1"  => "0111010",
    "D"   => "0001100",
    "A"   => "0110000",
    "!D"  => "0001101",
    "!A"  => "0110001",
    "-D"  => "0001111",
    "-A"  => "0110011",
    "D+1" => "0011111",
    "A+1" => "0110111",
    "D-1" => "0001110",
    "A-1" => "0110010",
    "D+A" => "0000010",
    "D-A" => "0010011",
    "A-D" => "0000111",
    "D&A" => "0000000",
    "D|A" => "0010101",
    "M"   => "1110000",
    "!M"  => "1110001",
    "-M"  => "1110011",
    "M+1" => "1110111",
    "M-1" => "1110010",
    "D+M" => "1000010",
    "D-M" => "1010011",
    "M-D" => "1000111",
    "D&M" => "1000000",
    "D|M" => "1010101"
)

const JUMP = Dict(
    ""    => "000",
    "JGT" => "001",
    "JEQ" => "010",
    "JGE" => "011",
    "JLT" => "100",
    "JNE" => "101",
    "JLE" => "110",
    "JMP" => "111"
)

function _gen_code(io::IO, inst::Parser.CInstruction)
    dest = inst.dest
    comp = inst.comp
    jump = inst.jump

    println(io, "111" * Compute[comp] * Destiation[dest] * JUMP[jump])
end

end #module
