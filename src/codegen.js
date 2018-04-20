require("./prototype")
require("./descriptor")

global.TAC = require("./tac")

global.Registers = require("./registers").Registers

global.Variable = require("./components").Variable
global.Function = require("./components").Function

global.Assembly = require("./assembly").Assembly

global.codeGen = require("./translate").codeGen

global.registers = new Registers()

global.arrays
global.variables
global.functions
global.basic_blocks
global.line_block_mapping
global.symbol_table
global.symtab // Make local to translate.js

global.next_use_table

global.assembly = new Assembly()


function main() {
    if (process.argv.length < 3) {
        console.log("Filename not specified. Terminating lexer")
        return
    }

    var fs = require("fs")

    filename = process.argv[2]
    console.log("Reading from file:  " + filename)

    tac = fs.readFileSync(filename, "utf8").split("\n")
    tac.forEach(function (line, index) {
        tac[index] = line.trim().split("\t")
    })


    arrays = TAC.getArrays()
    variables = TAC.getVariables(Object.keys(arrays))
    basic_blocks = TAC.getBasicBlocks()
    functions = TAC.getFunctions()
    symtab = {}

    line_block_mapping = {}
    var block_nr = 0
    basic_blocks.forEach(function (block) {
        block.forEach(function (line) {
            line_block_mapping[parseInt(line[0]) - 1] = block_nr
        })
        block_nr += 1
    })

    next_use_table = TAC.getNextUseTable(basic_blocks, variables)

    assembly.setLabels(TAC.getLabels())

    basic_blocks.forEach(function (block) {
        block.forEach(function (line) {
            codeGen(line, next_use_table, line[0] - 1)
        })
    })

    // assembly.addModules("IO")

    if (process.argv.length == 4) {
        assembly.print(process.argv[3])
    }
    else {
        assembly.print()
    }
}

main()