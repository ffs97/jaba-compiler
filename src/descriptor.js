global.math_ops = ["+", "-", "^", "|","||", "&&", "&", "*", "/", "%", "=", "=arr"]
global.math_ops_binary = ["+", "-", "^", "|", "&", "||", "&&"]
global.math_ops_unary = ["not", "inc", "dec", "neg"]
global.math_ops_involved = ["*", "/", "%"]
global.array_ops = ["arrset", "arrget"]

global.float_math_ops_binary = ["f+", "f-", "f*", "f/", "f="]
global.float_math_ops_unary = ["finc", "fdec"]


global.keywords = ["if", "return", "function", "call", "block", "jump", "le", "ge", "lt", "gt", "eq", "ne", "print", "scan", "array", "param", "int", "float", "char", "byte", "bool", "short"]

global.map_op = {
	"+": "add",
	"-": "sub",
	"&": "and",
	"&&": "and",
	"|": "or",
	"||": "or",
	"^": "xor",
	"/": "idiv",
	"*": "imul",
	"not": "not",
	"inc": "inc",
	"dec": "dec",
	"eq": "je",
	"ne": "jne",
	"lt": "jl",
	"le": "jle",
	"gt": "jg",
	"ge": "jge",
	"f+": "fadd",
	"f-": "fsub",
	"f*": "fmul",
	"f/": "fdiv",
	"finc": "fadd",
	"fdec": "fsub",
	"neg": "neg"
}

global.map_op_float = {
	"+": "fadd",
	"-": "fsub",
	"*": "fmul",
	"/": "fdiv",
	"inc": "fadd",
	"dec": "fsub",
	"eq": "je",
	"ne": "jne",
	"lt": "jb",
	"le": "jbe",
	"gt": "ja",
	"ge": "jae",
}


module.exports = {
	math_ops: math_ops,
	math_ops_binary: math_ops_binary,
	math_ops_unary: math_ops_unary,
	math_ops_involved: math_ops_involved,
	keywords: keywords,
	map_op: map_op,
	map_op_float: map_op_float
}