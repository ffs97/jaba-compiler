var parser = require('parser').parser;

var fs = require("fs");

var symtab = require("./symbol-table")

global.SymbolTable = symtab.SymbolTable
global.ScopeTable = symtab.ScopeTable
global.Variable = symtab.Variable
global.Method = symtab.Method
global.Class = symtab.Class
global.Type = symtab.Type

global.ir_sep = "\t"

global.ST = new SymbolTable()

var input_file = "in.java";
if (process.argv.length >= 3) {
    input_file = process.argv[2];
}
input = fs.readFileSync(input_file).toString();
console.log("Reading Input from file: " + input_file);

console.log("")
code = parser.parse(input)

console.log("")
// ST.print()

output = ""

code.forEach(function (line, index) {
    // console.log((index + 1) + ir_sep + line)
    output += (index + 1) + ir_sep + line + "\n"
})

if (process.argv.length >= 4) {
    out_file = process.argv[3]

    fs.writeFile(out_file, output, function (err) {
        if (err) {
            return console.log(err)
        }

        console.log("\nThe IR code was generated and saved to " + out_file + "\n")
    })
}