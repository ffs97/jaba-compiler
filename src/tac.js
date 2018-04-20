global.tac;

function getLabels() {
	var labels = [];

	tac.forEach(function (instr) {
		if (instr[1] == "ifgoto" || instr[1] == "jump") {
			labels.push(parseInt(instr[instr.length - 1]));
		}
	});

	labels = labels.unique();
	labels.sort(function (a, b) { return a - b });

	return labels;
}


function getArrays() {
	var arrays = {};
	tac.forEach(function (instr) {
		if (instr[1] == "array") {
			arrays[instr[2]] = instr[3];
		}
	});

	return arrays;
}


function getVariables(arrays) {
	var variables = [];

	tac.forEach(function (instr) {
		// if (math_ops.indexOf(instr[1]) > -1 && keywords.indexOf(instr[2]) == -1 && arrays.indexOf(instr[1]) == -1) {
		// 	variables.push(instr[2]);
		// }
		if (instr[1] == "decr" || instr[1] == "arg") { //|| instr[1] == "byte" || instr[1] == "char" || instr[1] == "float" || instr[1] == "short" || instr[1] == "param") {
			variables.push(instr[2]);
		}
		// if (instr[1] == 'int') {
		// 	variable = {id:instr[2], type:'int'};
		// 	variables.push(variable);
		// }
		// if (instr[1] == 'float') {
		// 	variable = {id:instr[2], type:'float'};
		// 	variables.push(variable);
		// }
	});

	return variables.unique();
}


function getFunctions() {
	var functions = [];

	tac.forEach(function (instr) {
		if (instr[1] == "function") {
			functions.push(instr[2]);
		}
	});

	return functions.unique();
}


function getBasicBlocks() {
	var splits = [];

	tac.forEach(function (instr, index) {
		switch (instr[1]) {
			case "ifgoto": {
				splits.push(parseInt(index + 1))
				splits.push(instr[instr.length - 1] - 1)
				break;
			}
			case "jump": {
				splits.push(index + 1)
				splits.push(instr[instr.length - 1] - 1)
				break;
			}
			case "function": {
				splits.push(index);
				break;
			}
			case "call": {
				splits.push(index);
				break;
			}
		}
	});

	splits = splits.unique();
	splits.sort(function (a, b) { return a - b });
	splits.push(-1);

	var basic_blocks = [[]];
	var curr = 0;
	tac.forEach(function (instr, index) {
		if (splits[curr] == index) {
			basic_blocks.push([]);
			curr += 1;
		}
		basic_blocks[basic_blocks.length - 1].push(instr);
	});

	return basic_blocks;
}


function getNextUseTable(basic_blocks, variables) {
	var next_use_table = new Array(tac.length).fill({});

	var variable_status = {};

	basic_blocks.forEach(function (block) {
		variables.forEach(function (variable) { variable_status[variable] = ["dead", Infinity]; });
		for (var i = block.length - 1; i >= 0; i--) {
			var instr = block[i];

			next_use_table[parseInt(instr[0]) - 1] = JSON.parse(JSON.stringify(variable_status));
			variables.forEach(function (variable) {
				if (next_use_table[parseInt(instr[0]) - 1][variable][1] == null) {
					next_use_table[parseInt(instr[0]) - 1][variable][1] = Infinity;
				}
			});

			if (math_ops_binary.indexOf(instr[1]) > -1 || math_ops_involved.indexOf(instr[1]) > -1) {
				var dt = instr[2];
				var s1 = instr[3];
				var s2 = instr[4];

				variable_status[dt] = ["dead", Infinity];

				variable_status[s1] = ["live", parseInt(instr[0])];
				if (variables.indexOf(s2) > -1) {
					variable_status[s2] = ["live", parseInt(instr[0])];
				}
			}
			else if (math_ops_unary.indexOf(instr[1]) > -1) {
				var v1 = instr[2];

				if (variables.indexOf(v1) > -1) {
					variable_status[v1] = ["live", parseInt(instr[0])];
				}
			}
			switch (instr[1]) {
				case "ifgoto": {
					var c1 = instr[3];
					var c2 = instr[4];

					variable_status[c1] = ["live", parseInt(instr[0])];

					if (variables.indexOf(c2) > -1) {
						variable_status[c2] = ["live", parseInt(instr[0])];
					}
					break;
				}
				case "print": {
					var v1 = instr[2];

					if (variables.indexOf(v1) > -1) {
						variable_status[v1] = ["live", parseInt(instr[0])];
					}
					break;
				}
				case "scan": {
					var v1 = instr[2];

					variable_status[v1] = ["dead", Infinity];
					break;
				}
				case "=": {
					var v1 = instr[2];
					var v2 = instr[3];

					variable_status[v1] = ["dead", Infinity];

					if (variables.indexOf(v2) > -1) {
						variable_status[v2] = ["live", parseInt(instr[0])];
					}
					break;
				}
				case "arrget": {
					var index = instr[3];
					var value = instr[4];

					if (variables.indexOf(index) > -1) {
						variable_status[index] = ["live", parseInt(instr[0])];
					}
					if (variables.indexOf(value) > -1) {
						variable_status[value] = ["live", parseInt(instr[0])];
					}
					break;
				}
				case "arrset": {
					var destn = instr[2];
					var offst = instr[3];
					var value = instr[4];

					variable_status[destn] = ["dead", Infinity];

					if (variables.indexOf(offst) > -1) {
						variable_status[offst] = ["live", parseInt(instr[0])];
					}
					if (variables.indexOf(value) > -1) {
						variable_status[value] = ["live", parseInt(instr[0])];
					}
					break;
				}
				case "fieldget": {
					var destn = instr[2];
					var offst = instr[3];
					var value = instr[4];

					variable_status[destn] = ["dead", Infinity];

					if (variables.indexOf(offst) > -1) {
						variable_status[offst] = ["live", parseInt(instr[0])];
					}
					if (variables.indexOf(value) > -1) {
						variable_status[value] = ["live", parseInt(instr[0])];
					}
					break;
				}
				case "fieldset": {
					var destn = instr[2];
					var field = instr[3];
					var value = instr[4];

					variable_status[destn] = ["live", parseInt(instr[0])];

					if (variables.indexOf(field) > -1) {
						variable_status[field] = ["dead", parseInt(instr[0])];
					}
					if (variables.indexOf(value) > -1) {
						variable_status[value] = ["live", parseInt(instr[0])];
					}
					break;
				}
				case "return": {
					if (instr.length > 2) {
						var value = instr[2];

						if (variables.indexOf(value) > -1) {
							variable_status[value] = ["live", parseInt(instr[0])];
						}
					}
					break
				}
			}
		}
	});

	return next_use_table;
}

class Type {
	constructor(type, category, width, length, dimension = 0) {
		this.type = type
		this.category = category

		this.width = width
		this.length = length
		this.dimension = dimension
	}
}

class Variable {
	constructor(name, type, index, isparam = false) {
		this.name = name
		this.type = type
		this.display_name = name + "_" + index

		this.isparam = isparam
	}
}

class Class {
	constructor(name, parent = null) {
		this.name = name

		this.methods = {}
		this.variables = {}

		this.parent = parent
	}
}

class SymbolTable {
	constructor() {
		var test = new Class("test")
		var type1 = new Type("int", "basic", 4, null)
		var type2 = new Type("float", "basic", 4, null)
		var type3 = new Type("int", "array", 4, 20, 1)
		var a = new Variable("a", type1, 1)
		var b = new Variable("b", type2, 2)
		var c = new Variable("c", type3, 3)
		test.variables = {
			"a": a,
			"b": b,
			"c": c
		}
		this.classes = { "test": test }


	}
}

function get_classDict() {
	var ST = new SymbolTable()
	classes = Object.keys(ST.classes)
	var symtab = {}
	classes.forEach(function (_class) {
		// symtab[_class] = {}
		dict_class = {}
		position = 0
		var variables = Object.keys(ST.classes[_class].variables)
		variables.forEach(function (var_name) {
			var variable = ST.classes[_class].variables[var_name]
			dict_class[variable.display_name] = {
				"category": variable.type.category,
				"type": variable.type.type,
				"length": variable.type.length,
				"position": position
			}
			position += 1
		})
		symtab[_class] = dict_class
	});

	return symtab;

}

module.exports = {
	getArrays: getArrays,
	getVariables: getVariables,
	getLabels: getLabels,
	getBasicBlocks: getBasicBlocks,
	getNextUseTable: getNextUseTable,
	getFunctions: getFunctions,
	get_classDict: get_classDict
}