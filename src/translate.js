global.tac

const_count = 0

function codeGen(instr, next_use_table, line_nr) {
	if (assembly.labels.indexOf(line_nr + 1) > -1) {
		if (line_nr > 0) {
			registers.unloadRegisters(line_nr - 1);
		}

		assembly.shiftLeft();
		assembly.add("");
		assembly.add("label_" + (line_nr + 1) + ":");
		assembly.shiftRight();
	}
	var op = instr[1];
	//-------------------------------------------- new changes ------------------------------------------------
	// if (op == "decr") {
	// 	// print("TODO");
	// 	var x = instr[2]
	// 	if (instr[3] != "array") {
	// 		assembly.add("sub esp, 4")
	// 		registers.counter = registers.counter + 4
	// 		registers.address_descriptor[x] = { "type": "mem", "name": x, "offset": registers.counter }

	// 	}
	// else {
	// 		// size = instr[5] * 4
	// 		// assembly.add("sub esp, " +  size)
	// 		// registers.counter = registers.counter + size
	// 		// registers.address_descriptor[x] = {"type": "mem", "name": x, "offset":registers.counter}
	// 		size = instr[5] * 4
	// 		var variable
	// 		var flag = 0
	// 		if (registers.register_descriptor["eax"] != null) {
	// 			flag = 1
	// 			variable = registers.register_descriptor["eax"]
	// 			assembly.add("mov dword [ebp - " + registers.address_descriptor[variable]["offset"] + "]", eax)
	// 			registers.register_descriptor["eax"] = null
	// 			registers.address_descriptor[variable]["type"] = "mem"
	// 			registers.address_descriptor[variable]["name"] = variable
	// 		}
	// 		assembly.add("push " + size)
	// 		assembly.add("call malloc")
	// 		assembly.add("add esp, " + 4)
	// 		assembly.add("push eax")
	// 		registers.counter = registers.counter + 4
	// 		registers.address_descriptor[x] = { "type": "mem", "name": x, "offset": registers.counter }
	// 		if (flag) {
	// 			assembly.add("mov eax, [ebp - " + registers.address_descriptor[variable]["offset"] + "]")
	// 			registers.register_descriptor["eax"] = variable
	// 			registers.address_descriptor[variable]["type"] = "reg"
	// 			registers.address_descriptor[variable]["name"] = "eax"
	// 		}
	// 	}
	// }
	// console.log(tac[line_nr])
	if (op == "error") {
		var msg = instr[2];

		switch (msg) {
			case "function_return": {
				assembly.add("push function_return_error_msg")
				break
			}
			case "array_access_up": {
				assembly.add("push array_access_up_error_msg")
				break
			}
			case "array_access_low": {
				assembly.add("push array_access_low_error_msg")
				break
			}
		}
		assembly.add("call printf")
		assembly.add("mov dword eax, 1");
		assembly.add("int 0x80");
		assembly.shiftLeft()
	}



	//-------------------------------------------- changes finished ------------------------------------------------

	else if (op == "=") {
		var x = instr[2];
		if (registers.address_descriptor[x]["category"] != "float") {
			var y = instr[3];

			var des_x = registers.address_descriptor[x]["name"];
			// if (des_x == null) {			// x declared for first time
			// 	registers.address_descriptor[x] = { "type": "mem", "name": x };
			// 	des_x = registers.address_descriptor[x]["name"];
			// }

			var des_y = "";
			if (variables.indexOf(y) != -1) {
				des_y = registers.address_descriptor[y]["name"];
			}

			if (x == y) {
				return;
			}

			if (des_y == null) {
				throw Error("Using Uninitialised Values");
			}

			if (registers.address_descriptor[x]["type"] == "reg") {    // x is in a register
				if (variables.indexOf(y) == -1) {						// y is a constant
					des_y = y;
				}
				else {																						// y is a variable
					des_y = registers.loadVariable(y, line_nr, next_use_table, safe = [x], safe_regs = [], print = true);
				}
				assembly.add("mov dword " + des_x + ", " + des_y);
			}
			else {                             				// x is in memory
				if (variables.indexOf(y) == -1) {        // y is a constant
					des_y = y;
					des_x = registers.loadVariable(x, line_nr, next_use_table, safe = [], safe_regs = [], print = false);
					assembly.add("mov dword " + des_x + ", " + des_y);
				}
				else if (registers.address_descriptor[y]["type"] == "reg") {  // y is in a register
					if (next_use_table[line_nr][y][1] == Infinity) {	// y has no next use
						registers.spillVariable(y, line_nr, print = true);

						registers.register_descriptor[des_y] = x;
						// registers.address_descriptor[x] = { "type": "reg", "name": des_y };
						registers.address_descriptor[x]["type"] = "reg";
						registers.address_descriptor[x]["name"] = des_y;
					}
					else if ((reg = registers.getEmptyReg(x, line_nr, next_use_table, safe = [y], safe_regs = [], print = true)) != null) {	// empty reg exists
						des_x = reg;

						assembly.add("mov dword " + des_x + ", " + des_y);
					}
					else if ((reg = registers.getNoUseReg(x, line_nr, next_use_table, safe = [y], safe_regs = [], print = true)) != null) {	// reg has var with no next use
						des_x = reg;

						assembly.add("mov dword " + des_x + ", " + des_y);
					}
					else if (next_use_table[line_nr][x][1] <= next_use_table[line_nr][y][1] && registers.checkFarthestNextUse(y, line_nr, next_use_table)) {
						registers.spillVariable(y, line_nr, print = true);

						registers.register_descriptor[des_y] = x;
						// registers.address_descriptor[x] = { "type": "reg", "name": des_y };
						registers.address_descriptor[x]["type"] = "reg";
						registers.address_descriptor[x]["name"] = des_y;
					}
					else if (registers.checkFarthestNextUse(x, line_nr, next_use_table)) {
						// assembly.add("mov dword [" + x + "], " + des_x);
						assembly.add("mov dword [ebp - " + registers.address_descriptor[x]["offset"] + "], " + des_x);
					}
					else {
						des_x = registers.getReg(x, line_nr, next_use_table, safe = [y], safe_regs = []);

						assembly.add("mov dword " + des_x + ", " + des_y);
					}
				}
				else {								// y is in memory
					if (next_use_table[line_nr][x][1] > next_use_table[line_nr][y][1]) {// next use of x is after y
						des_y = registers.getReg(y, line_nr, next_use_table, safe = [], safe_regs = []);
						// assembly.add("mov dword " + des_y + ", [" + y + "]");
						assembly.add("mov dword " + des_y + ", [ebp - " + registers.address_descriptor[y]["offset"] + "]");
						des_x = registers.loadVariable(x, line_nr, next_use_table, safe = [y], safe_regs = [], print = true);
					}
					else {																						// next use of x is before y
						des_x = registers.getReg(x, line_nr, next_use_table, safe = [], safe_regs = []);
						// assembly.add("mov dword " + des_x + ", [" + x + "]");

						des_y = registers.loadVariable(y, line_nr, next_use_table, safe = [x], safe_regs = [], print = true);
					}

					assembly.add("mov dword " + des_x + ", " + des_y);
				}
			}
		}
		else {
			var y = instr[3]
			if (variables.indexOf(y) > -1) {	// y is variable
				var offset_y = registers.address_descriptor[y]["offset"]
				assembly.add("fld dword [ebp -" + offset_y + "]")
			}
			else {	// y is constant
				assembly.add_data("_" + line_nr + "	" + "DD " + y)
				assembly.add("fld dword [_" + line_nr + "]")

			}
			var offset_x = registers.address_descriptor[x]["offset"]
			assembly.add("fstp dword [ebp - " + offset_x + "]")
		}
	}
	else if (math_ops_binary.indexOf(op) > -1) {
		var x = instr[2];
		if (registers.address_descriptor[x]["category"] == "int") {
			var y = instr[3];

			var des_x = registers.address_descriptor[x]["name"];
			if (des_x == null) {
				// registers.address_descriptor[x] = { "type": "mem", "name": x };
				registers.address_descriptor[x]["type"] = "mem";
				registers.address_descriptor[x]["name"] = x;
				des_x = registers.address_descriptor[x]["name"];
			}

			var des_y = "";
			if (variables.indexOf(y) != -1) {
				des_y = registers.address_descriptor[y]["name"];
			}

			var z = instr[4];
			var des_z;

			if (des_y == null) {
				throw Error("Assigning Uninitialised Value");
			}
			if (registers.address_descriptor[y]["type"] == "mem") {
				des_y = registers.getReg(y, line_nr, next_use_table, safe = [x, z], safe_regs = []);
				// assembly.add("mov dword " + des_y + ", [" + y + "]");
				assembly.add("mov dword " + des_y + ", [ebp - " + registers.address_descriptor[y]["offset"] + "]");
			}

			if (variables.indexOf(z) == -1) {	//z is constant
				des_z = z;
			}
			else {	// z not constant
				des_z = registers.loadVariable(z, line_nr, next_use_table, safe = [x, y], safe_regs = [], print = true);
			}

			des_x = registers.address_descriptor[x]["name"];

			if (x == z) {
				if (op == "-") {
					if (registers.address_descriptor[x]["type"] == "mem") {
						des_x = registers.getReg(x, line_nr, next_use_table, safe = [y, z], safe_regs = []);
					}
					else {
						// assembly.add("mov dword [" + x + "], " + des_x);
						assembly.add("mov dword [ebp - " + registers.address_descriptor[x]["offset"] + "], " + des_x);
					}

					assembly.add("mov dword " + des_x + ", " + des_y);
					// assembly.add("sub dword " + des_x + ", [" + x + "]");
					assembly.add("sub dword " + des_x + ", [ebp - " + registers.address_descriptor[x]["offset"] + "]");
				}
				else {
					assembly.add(map_op[op] + " dword " + des_x + ", " + des_y);
				}
			}
			else if (registers.address_descriptor[x]["type"] == "reg") {	//x is in register
				if (x != y) {
					assembly.add("mov dword " + des_x + ", " + des_y);
				}
				assembly.add(map_op[op] + " dword " + des_x + ", " + des_z);
			}
			else if (next_use_table[line_nr][y][1] == Infinity) {	//No next use of y
				registers.spillVariable(y, line_nr, print = true);

				registers.register_descriptor[des_y] = x;
				// registers.address_descriptor[x] = { "type": "reg", "name": des_y };
				registers.address_descriptor[x]["type"] = "reg";
				registers.address_descriptor[x]["name"] = des_y;
				assembly.add(map_op[op] + " dword " + des_y + ", " + des_z);
			}
			else if ((reg = registers.getEmptyReg(x, line_nr, next_use_table, safe = [y, z], safe_regs = [], print = true)) != null) {	//got empty reg for x
				assembly.add("mov dword " + reg + ", " + des_y);
				assembly.add(map_op[op] + " dword " + reg + ", " + des_z);
			}
			else if ((reg = registers.getNoUseReg(x, line_nr, next_use_table, safe = [y, z], safe_regs = [], print = true)) != null) {	//got empty reg for x
				assembly.add("mov dword " + reg + ", " + des_y);
				assembly.add(map_op[op] + " dword " + reg + ", " + des_z);
			}
			else if (registers.checkFarthestNextUse(y, line_nr, next_use_table)) {	//y has farthest next use
				registers.spillVariable(y, line_nr, print = true);

				// registers.address_descriptor[x] = { "type": "reg", "name": des_y };
				registers.address_descriptor[x]["type"] = "reg";
				registers.address_descriptor[x]["name"] = des_y;
				registers.register_descriptor[des_y] = x;

				assembly.add(map_op[op] + " dword " + des_y + ", " + des_z);
			}
			else {	//some other reg has farthest next use
				var reg = registers.getReg(x, line_nr, next_use_table, safe = [y, z], safe_regs = []);
				assembly.add("mov dword " + reg + ", " + des_y);
				assembly.add(map_op[op] + " dword " + reg + ", " + des_z);
			}
		}
		else if (registers.address_descriptor[x]["category"] == "float") {
			var y = instr[3]
			var z = instr[4]

			if (variables.indexOf(z) != -1) {	// z is variable
				var offset_z = registers.address_descriptor[z]["offset"]
				assembly.add("fld dword [ebp -" + offset_z + "]")
			}
			else {	//z is constant
				if (z.indexOf(".") < 0) {
					z = z + ".0"
				}
				assembly.add_data("_" + line_nr + "	" + "DD " + z)
				assembly.add("fld dword [_" + line_nr + "]")
			}
			var offset_y = registers.address_descriptor[y]["offset"]
			assembly.add("fld dword [ebp -" + offset_y + "]")
			var offset_x = registers.address_descriptor[x]["offset"]
			assembly.add(map_op_float[op] + " st0, st1")
			assembly.add("fstp dword [ebp - " + offset_x + "]")
			assembly.add("fstp st0")
		}
	}
	else if (math_ops_unary.indexOf(op) > -1) {
		var x = instr[2];
		if (registers.address_descriptor[x]["category"] == "int") {
			var des_x = registers.address_descriptor[x]["name"];
			if (des_x == null) {
				throw Error("Line " + (line_nr + 1) + ": Operation on Unitialize Variable");
			}

			des_x = registers.loadVariable(x, line_nr, next_use_table, safe = [], safe_regs = [], print = true);

			assembly.add(map_op[op] + " dword " + des_x);
		}
		else if (registers.address_descriptor[x]["category"] == "float") {
			if (op != 'neg') {
				assembly.add("fld1")
				var offset_x = registers.address_descriptor[x]["offset"]
				assembly.add("fld dword [ebp -" + offset_x + "]")
				assembly.add(map_op_float[op] + " st0, st1")
				assembly.add("fstp dword [ebp - " + offset_x + "]")
				assembly.add("fstp st0")
			}
			else {
				var offset_x = registers.address_descriptor[x]["offset"]
				assembly.add("fld dword [ebp -" + offset_x + "]")
				assembly.add("fchs")
				assembly.add("fstp dword [ebp - " + offset_x + "]")
			}
		}
	}
	else if (op == "*") {
		var x = instr[2];
		if (registers.address_descriptor[x]["category"] == "int") {
			var y = instr[3];

			var des_x = registers.address_descriptor[x]["name"];
			if (des_x == null) {
				// registers.address_descriptor[x] = { "type": "mem", "name": x };
				registers.address_descriptor[x]["type"] = "mem";
				registers.address_descriptor[x]["name"] = x;
				des_x = registers.address_descriptor[x]["name"];
			}

			var des_y = "";
			if (variables.indexOf(y) != -1) {	// y is not constant
				des_y = registers.address_descriptor[y]["name"];
			}

			var z = instr[4];
			var des_z;

			if (registers.address_descriptor[y]["type"] == "mem") {
				des_y = registers.getReg(y, line_nr, next_use_table, safe = [x, z], safe_regs = [], print = true);
				// assembly.add("mov dword " + des_y + ", [" + y + "]");
				assembly.add("mov dword " + des_y + ", [ebp - " + registers.address_descriptor[y]["offset"] + "]");
			}

			des_x = registers.address_descriptor[x]["name"];

			if (variables.indexOf(z) == -1) {	// z is constant
				des_z = z;
				if (registers.address_descriptor[x]["type"] == "reg") {	// x in reg
					assembly.add("imul dword " + des_x + ", " + des_y + ", " + des_z);
				}
				else if (next_use_table[line_nr][y][1] == Infinity) {	//no next use y
					registers.spillVariable(y, line_nr, print = true);

					// registers.address_descriptor[x] = { "type": "reg", "name": des_y };
					registers.address_descriptor[x]["type"] = "reg";
					registers.address_descriptor[x]["name"] = des_y;
					registers.register_descriptor[des_y] = x;

					assembly.add("imul dword " + des_y + ", " + des_y + ", " + des_z);
				}
				else if ((reg = registers.getEmptyReg(x, line_nr, next_use_table, safe = [y, z], safe_regs = [], print = true)) != null) {		//empty for x
					assembly.add("imul dword " + reg + ", " + des_y + ", " + des_z);
				}
				else if ((reg = registers.getNoUseReg(x, line_nr, next_use_table, safe = [y, z], safe_regs = [], print = true)) != null) {
					assembly.add("imul dword " + reg + ", " + des_y + ", " + des_z);
				}
				else {	// get reg for spilling
					reg = registers.getReg(x, line_nr, next_use_table, safe = [y, z], safe_regs = [], print = true);
					assembly.add("imul dword " + reg + ", " + des_y + ", " + des_z);
				}
			}
			else {	// z in reg or mem
				des_z = registers.loadVariable(z, line_nr, next_use_table, safe = [x, y], safe_regs = [], print = true);
				des_x = registers.address_descriptor[x]["name"];
				if (registers.address_descriptor[x]["type"] == "reg") {	// x in reg
					if (x == z) { // x and z are same
						assembly.add("imul dword " + des_x + ", " + des_y);
					}
					else { // x and z are not same
						if (x != y) {
							assembly.add("mov dword " + des_x + ", " + des_y);
						}
						assembly.add("imul dword " + des_x + ", " + des_z);
					}
				}
				else if (next_use_table[line_nr][y][1] == Infinity) { 	// y has no next use
					registers.spillVariable(y, line_nr, print = true);

					// registers.address_descriptor[x] = { "type": "reg", "name": des_y };
					registers.address_descriptor[x]["type"] = "reg";
					registers.address_descriptor[x]["name"] = des_y;
					registers.register_descriptor[des_y] = x;

					assembly.add("imul dword " + des_y + ", " + des_z);
				}
				else if ((reg = registers.getEmptyReg(x, line_nr, next_use_table, safe = [y, z], safe_regs = [], print = true)) != null) {		//empty for x
					if (x != z) {
						assembly.add("mov dword " + reg + ", " + des_y);
						assembly.add("imul dword " + reg + ", " + des_z);
					}
					else {
						assembly.add("imul dword " + reg + ", " + des_y);
					}
				}
				else if ((reg = registers.getNoUseReg(x, line_nr, next_use_table, safe = [y, z], safe_regs = [], print = true)) != null) {
					if (x != z) {
						assembly.add("mov dword " + reg + ", " + des_y);
						assembly.add("imul dword " + reg + ", " + des_z);
					}
					else {
						assembly.add("imul dword " + reg + ", " + des_y);
					}
				}
				else if (registers.checkFarthestNextUse(y, line_nr, next_use_table, safe = [x, z])) {	// y has farthest next use
					registers.spillVariable(y, line_nr, print = true);

					// registers.address_descriptor[x] = { "type": "reg", "name": des_y };
					registers.address_descriptor[x]["type"] = "reg";
					registers.address_descriptor[x]["name"] = des_y;
					registers.register_descriptor[des_y] = x;

					assembly.add("imul dword " + des_y + ", " + des_z);
				}
				else {	// spill some register
					var reg = registers.getReg(x, line_nr, next_use_table, safe = [y, z], safe_regs = [], print = true);
					if (x != z) {
						assembly.add("mov dword " + reg + ", " + des_y);
						assembly.add("imul dword " + reg + ", " + des_z);
					}
					else {
						assembly.add("imul dword " + reg + ", " + des_y);
					}
				}
			}
		}
		else if (registers.address_descriptor[x]["category"] == "float") {
			var y = instr[3]
			var z = instr[4]

			if (variables.indexOf(z) != -1) {	// z is variable
				var offset_z = registers.address_descriptor[z]["offset"]
				assembly.add("fld dword [ebp -" + offset_z + "]")
			}
			else {	//z is constant
				assembly.add_data("_" + line_nr + "	" + "DD " + z)
				assembly.add("fld dword [_" + line_nr + "]")
			}
			var offset_y = registers.address_descriptor[y]["offset"]
			assembly.add("fld dword [ebp -" + offset_y + "]")
			var offset_x = registers.address_descriptor[x]["offset"]
			assembly.add(map_op_float[op] + " st0, st1")
			assembly.add("fstp dword [ebp - " + offset_x + "]")
			assembly.add("fstp st0")
		}
	}
	else if ((op == "/" || op == "%") && (instr[3] == instr[4])) {
		var x = instr[2];
		if (registers.address_descriptor[x]["category"] == "int") {
			des_x = registers.loadVariable(x, line_nr, next_use_table, safe = [], safe_regs = [], print = true);
			if (op == "/") {
				assembly.add("mov dword " + des_x + ", 1");
			}
			else if (op == "%") {
				assembly.add("mov dword " + des_x + ", 0");
			}
		}
		else if (registers.address_descriptor[x]["category"] == "float") {
			assembly.add("fld1")
			var offset_x = registers.address_descriptor[x]["offset"]
			assembly.add("fstp dword [ebp - " + offset_x + "]")
		}
	}
	else if (op == "/" || op == "%") {
		var x = instr[2];
		if (registers.address_descriptor[x]["category"] == "int") {
			var y = instr[3];
			var z = instr[4];

			var des_x = registers.address_descriptor[x]["name"];
			if (des_x == null) {
				// registers.address_descriptor[x] = { "type": "mem", "name": x };
				registers.address_descriptor[x]["type"] = "mem";
				registers.address_descriptor[x]["name"] = x;
				des_x = registers.address_descriptor[x]["name"];
			}

			var des_y = "";
			if (variables.indexOf(y) != -1) { // y is not constant
				des_y = registers.address_descriptor[y]["name"];
			}

			var rep_var = registers.register_descriptor["eax"];
			if (registers.address_descriptor[y]["type"] == "reg" && registers.address_descriptor[y]["name"] == "eax") {	// y in eax
				if (x != y) {
					// assembly.add("mov dword [" + y + "], " + "eax");
					assembly.add("mov dword [ebp - " + registers.address_descriptor[y]["offset"] + "], " + "eax");
					// registers.address_descriptor[y] = { "type": "mem", "name": y };
					registers.address_descriptor[y]["type"] = "mem";
					registers.address_descriptor[y]["name"] = y;
				}
			}
			else {
				if (rep_var != null) {	//something in eax
					// assembly.add("mov dword [" + rep_var + "], eax");
					assembly.add("mov dword [ebp - " + registers.address_descriptor[rep_var]["offset"] + "], eax");
					// registers.address_descriptor[rep_var] = { "type": "mem", "name": rep_var };
					registers.address_descriptor[rep_var]["type"] = "mem";
					registers.address_descriptor[rep_var]["name"] = rep_var;
				}
				if (registers.address_descriptor[y]["type"] == "mem") {
					// des_y = "[" + y + "]";
					des_y = "[ebp - " + registers.address_descriptor[y]["offset"] + "]";
				}
				assembly.add("mov dword eax, " + des_y);
				if (x == y && registers.address_descriptor[x]["type"] == "reg") {
					registers.register_descriptor[registers.address_descriptor[x]["name"]] = null;
					registers.address_descriptor[x]["name"] = "eax";
				}
			}
			rep_var = registers.register_descriptor["edx"];
			if (rep_var != null) {	// make edx empty
				// assembly.add("mov dword [" + rep_var + "], edx");
				assembly.add("mov dword [ebp - " + registers.address_descriptor[rep_var]["offset"] + "], edx");
				// registers.address_descriptor[rep_var] = { "type": "mem", "name": rep_var };
				registers.address_descriptor[rep_var]["type"] = "mem";
				registers.address_descriptor[rep_var]["name"] = rep_var;
				registers.register_descriptor["edx"] = null;
			}
			assembly.add("mov dword edx, 0");

			//-----------------------------------------------------------------------------------

			var des_z = "";
			var rep_reg;
			var flag = false;
			if (variables.indexOf(z) > -1 && registers.address_descriptor[z]["type"] == "reg") {	// z in reg
				des_z = registers.address_descriptor[z]["name"];
			}
			else if (variables.indexOf(z) == -1) {	// z is constant
				var safe_regs = ["eax", "edx"];
				var safe = [];
				var rep_var;
				var rep_reg;
				var rep_use = 0;
				registers_list.some(function (register) {
					if (safe_regs.indexOf(register) == -1 && registers.register_descriptor[register] == null) {
						registers.register_descriptor[register] = null;
						flag = true;
						rep_reg = register;
						return true;
					}
				});
				if (flag == true) {
					assembly.add("mov dword " + rep_reg + ", " + z);
					des_z = rep_reg;
				}
				else {
					registers_list.some(function (register) {
						if (safe_regs.indexOf(register) == -1) {
							rep_var = registers.register_descriptor[register];
							if (safe.indexOf(rep_var) == -1 && next_use_table[line_nr][rep_var][1] == Infinity) {	//no next use empty it
								// assembly.add("mov dword [" + rep_var + "], " + register);
								assembly.add("mov dword [ebp - " + registers.address_descriptor[rep_var]["offset"] + "], " + register);
								// registers.address_descriptor[rep_var] = { "type": "mem", "name": rep_var };
								registers.address_descriptor[rep_var]["type"] = "mem";
								registers.address_descriptor[rep_var]["name"] = rep_var;
								registers.register_descriptor[register] = null;
								flag = true;
								rep_reg = register;
								return true;
							}
						}
					});
					if (flag == true) {
						assembly.add("mov dword " + rep_reg + ", " + z);
						des_z = rep_reg;
					}
					else {
						registers_list.forEach(function (register) {
							if (safe_regs.indexOf(register) == -1) {
								var curr_var = registers.register_descriptor[register];
								if (safe.indexOf(curr_var) == -1 && next_use_table[line_nr][curr_var][1] > rep_use) {
									rep_reg = register;
									rep_var = curr_var;
									rep_use = next_use_table[line_nr][curr_var][1];
								}
							}
						});
						registers.register_descriptor[rep_reg] = null;
						// assembly.add("mov dword [" + rep_var + "], " + rep_reg);
						assembly.add("mov dword [ebp - " + registers.address_descriptor[rep_var]["offset"] + "], " + rep_reg);
						// registers.address_descriptor[rep_var] = { "type": "mem", "name": rep_var };
						registers.address_descriptor[rep_var]["type"] = "mem";
						registers.address_descriptor[rep_var]["name"] = rep_var;
						assembly.add("mov dword " + rep_reg + ", " + z);
						des_z = rep_reg;
					}
				}
			}
			else if (registers.address_descriptor[z]["type"] == "mem") {	// z in mem
				des_z = registers.loadVariable(z, line_nr, next_use_table, safe = [], safe_regs = ["eax", "edx"], print = true);
			}
			assembly.add("cdq");
			assembly.add("idiv dword " + des_z);
			if (x == z && registers.address_descriptor[z]["type"] == "reg" && registers.address_descriptor[z]["name"] != "eax") {
				reg = registers.address_descriptor[z]["name"];
				registers.register_descriptor[reg] = null;
			}
			if (op == "/") {
				registers.register_descriptor["eax"] = x;
				registers.register_descriptor["edx"] = null;
				// registers.address_descriptor[x] = { "type": "reg", "name": "eax" };
				registers.address_descriptor[x]["type"] = "reg";
				registers.address_descriptor[x]["name"] = "eax";
			}
			else {	// op is %
				registers.register_descriptor["eax"] = null;
				registers.register_descriptor["edx"] = x;
				// registers.address_descriptor[x] = { "type": "reg", "name": "edx" };
				registers.address_descriptor[x]["type"] = "reg";
				registers.address_descriptor[x]["name"] = "edx";
			}
		}
		else if (registers.address_descriptor[x]["category"] == "float") {
			var y = instr[3]
			var z = instr[4]

			if (variables.indexOf(z) != -1) {	// z is variable
				var offset_z = registers.address_descriptor[z]["offset"]
				assembly.add("fld dword [ebp -" + offset_z + "]")
			}
			else {	//z is constant
				assembly.add_data("_" + line_nr + "	" + "DD " + z)
				assembly.add("fld dword [_" + line_nr + "]")
			}
			var offset_y = registers.address_descriptor[y]["offset"]
			assembly.add("fld dword [ebp -" + offset_y + "]")
			var offset_x = registers.address_descriptor[x]["offset"]
			assembly.add(map_op_float[op] + " st0, st1")
			assembly.add("fstp dword [ebp - " + offset_x + "]")
			assembly.add("fstp st0")
		}
	}
	else if (op == "ifgoto") {			//x<y type
		var cond = instr[2]

		var x = instr[3];
		if (variables.indexOf(x) == -1) {
			var y = instr[4]
			if (x.indexOf(".") == -1) {
				x = x + ".0"
			}
			if (y.indexOf(".") == -1) {
				y = y + ".0"
			}
			registers.unloadRegisters(line_nr - 1);
			assembly.add_data("_" + line_nr + "_x DD " + x)
			assembly.add_data("_" + line_nr + "_y DD " + y)
			assembly.add("fld dword [_" + line_nr + "_y]")
			assembly.add("fld dword [_" + line_nr + "_x]")

			assembly.add("fcompp")
			assembly.add("fstsw ax")
			assembly.add("fwait")
			assembly.add("sahf")
			// assembly.add("fstp")
			// assembly.add("fstp")
			assembly.add(map_op_float[cond] + " label_" + instr[5])

		}
		else if (registers.address_descriptor[x]["category"] == "int") {
			var y = instr[4];

			var des_x = registers.address_descriptor[x]["name"];
			if (des_x == null) {
				// registers.address_descriptor[x] = { "type": "mem", "name": x };
				registers.address_descriptor[x]["type"] = "mem";
				registers.address_descriptor[x]["name"] = x;
				des_x = registers.address_descriptor[x]["name"];
			}

			var des_y = "";
			if (variables.indexOf(y) != -1) {
				des_y = registers.address_descriptor[y]["name"];
			}

			if (des_y == null || des_x == null) {
				throw Error("Comparing Uninitialised Values");
			}

			if (registers.address_descriptor[x]["type"] == "reg") {    									// x is in a register
				if (variables.indexOf(y) == -1) {															// y is a constant
					des_y = y;
				}
				else {																						// y is a variable
					des_y = registers.loadVariable(y, line_nr, next_use_table, safe = [x], safe_regs = [], print = true);
				}
			}
			else {                             															// x is in memory
				if (variables.indexOf(y) == -1) {         													// y is a constant
					des_y = y;

					des_x = registers.loadVariable(x, line_nr, next_use_table, safe = [], safe_regs = [], print = true);
				}
				else if (registers.address_descriptor[y]["type"] == "reg") {  								// y is in a register
					des_x = registers.loadVariable(x, line_nr, next_use_table, safe = [y], safe_regs = [], print = true);
				}
				else {																						// y is in memory
					des_x = registers.getReg(x, line_nr, next_use_table, safe = [], safe_regs = []);
					// assembly.add("mov dword " + des_x + ", [" + x + "]");
					assembly.add("mov dword " + des_x + ", [ebp - " + registers.address_descriptor[x]["offset"] + "]");

					des_y = registers.loadVariable(y, line_nr, next_use_table, safe = [x], safe_regs = [], print = true);
				}
			}

			assembly.add("cmp dword " + des_x + ", " + des_y);
			registers.unloadRegisters(line_nr - 1);
			assembly.add(map_op[cond] + " label_" + instr[5]);
		}

		else if (registers.address_descriptor[x]["category"] == "float") {
			var y = instr[4];

			var offset_x = registers.address_descriptor[x]["offset"];
			if (variables.indexOf(y) != -1) {	// z is variable
				var offset_y = registers.address_descriptor[y]["offset"]
				assembly.add("fld dword [ebp -" + offset_y + "]")
			}
			else {	//z is constant
				assembly.add_data("_" + line_nr + "	" + "DD " + y)
				assembly.add("fld dword [_" + line_nr + "]")
			}
			var variable
			var variable_offset

			registers.unloadRegisters(line_nr - 1);

			assembly.add("fld dword [ebp - " + offset_x + "]")
			assembly.add("fcompp")
			assembly.add("fstsw ax")
			assembly.add("fwait")
			assembly.add("sahf")
			// assembly.add("fstp")
			// assembly.add("fstp")
			assembly.add(map_op_float[cond] + " label_" + instr[5])
		}

	}
	else if (op == "jump") {

		registers.unloadRegisters(line_nr - 1);
		assembly.add("jmp label_" + instr[2]);
	}
	else if (op == "param") {
		var x = instr[2]
		var des_x = ""
		if (variables.indexOf(x) > -1) {
			if (registers.address_descriptor[x]["category"] != "float") {
				if (registers.address_descriptor[x]["type"] != "reg") {
					des_x = registers.getReg(x, line_nr, next_use_table, safe = [], safe_regs = []);
					assembly.add("mov dword " + des_x + ", [ebp - " + registers.address_descriptor[x]["offset"] + "]");
				}
				else {
					des_x = registers.address_descriptor[x]["name"]
				}
				assembly.add("push " + des_x)
				registers.n_params += 1
			} else {
				assembly.add("sub esp, 4")
				assembly.add("fld dword [ebp - " + registers.address_descriptor[x]["offset"] + "]")
				assembly.add("fstp dword [esp]")
			}
		} else {
			if (x.indexOf(".") == -1) {
				assembly.add("push " + x)
			} else {
				assembly.add_data("_" + line_nr + " DD " + x)
				assembly.add("sub esp, 4")
				assembly.add("fld dword [_" + line_nr + "]")
				assembly.add("fstp dword [esp]")
			}
		}
	}
	else if (op == "function") {//TODO
		var func = instr[2]

		registers.args_counter = -8;
		registers.counter = 0

		assembly.shiftLeft();
		if (func == "main") {
			assembly.add("main:");
		}
		else {
			assembly.add("func_" + func + ":");
		}
		assembly.shiftRight();

		assembly.add("push ebp");
		assembly.add("mov ebp, esp");
		var flag_function = false

		// var i_func = 0;
		// instr_local = tac[line_nr];
		var i_func = 1;
		instr_local = tac[line_nr + 1];
		// while(!(instr_local[1] == "return" || instr_local[1] == "exit") ){
		while ((instr_local != null) && (instr_local[1] != "function")) {
			if (instr_local[1] == "decr") {
				var x = instr_local[2]
				if (instr_local[3] == "basic") {
					assembly.add("sub esp, 4")
					registers.counter = registers.counter + 4
					if (instr_local[4] == "int") {
						registers.address_descriptor[x] = { "type": "mem", "name": x, "offset": registers.counter, "category": "int" }
					}
					else if (instr_local[4] == "float") {
						registers.address_descriptor[x] = { "type": "mem", "name": x, "offset": registers.counter, "category": "float" }
					}
				}
				else if (instr_local[3] == "array") {
					size = instr_local[5] * 4
					var variable
					var flag = 0
					if (registers.register_descriptor["eax"] != null) {
						flag = 1
						variable = registers.register_descriptor["eax"]
						assembly.add("mov dword [ebp - " + registers.address_descriptor[variable]["offset"] + "]", eax)
						registers.register_descriptor["eax"] = null
						registers.address_descriptor[variable]["type"] = "mem"
						registers.address_descriptor[variable]["name"] = variable
					}
					assembly.add("push " + size)
					assembly.add("call malloc")
					assembly.add("add esp, " + 4)
					assembly.add("push eax")
					registers.counter = registers.counter + 4
					if (flag) {
						assembly.add("mov eax, [ebp - " + registers.address_descriptor[variable]["offset"] + "]")
						registers.register_descriptor["eax"] = variable
						registers.address_descriptor[variable]["type"] = "reg"
						registers.address_descriptor[variable]["name"] = "eax"
					}
					if (instr_local[4] == "int") {
						registers.address_descriptor[x] = { "type": "mem", "name": x, "offset": registers.counter, "category": "arr_int" }
					}
					else if (instr_local[4] == "float") {
						registers.address_descriptor[x] = { "type": "mem", "name": x, "offset": registers.counter, "category": "arr_float" }
					}
					else {
						var class_name = instr_local[4]
						var category = "arr_" + class_name
						registers.address_descriptor[x] = { "type": "mem", "name": x, "offset": registers.counter, "category": category }
					}
				}


				// ------------------------------------- objects ------------------------------------------
				else if (instr_local[3] == "object") {
					var obj_name = instr_local[2]
					var class_name = instr_local[4]
					// var size = Object.keys(symtab[class_name]).length * 4 + 4
					assembly.add("sub esp, " + 4)
					registers.counter = registers.counter + 4
					registers.address_descriptor[obj_name] = { "type": "mem", "name": obj_name, "offset": registers.counter, "category": class_name }
				}
			}
			i_func = i_func + 1;
			instr_local = tac[line_nr + i_func];
		}
	}

	else if (op == "class") {
		var class_name = instr[2]
		symtab[class_name] = {}
		registers.field_num = 0
	}

	else if (op == "field_decr") {
		var class_name = instr[2]
		var field_name = instr[3]
		var category = instr[5]
		// console.log(category)
		if (instr[4] == "array") {
			symtab[class_name][field_name] = {}

			if (category == "int") {
				symtab[class_name][field_name]["category"] = "arr_int"
			}
			else if (category == "float") {
				symtab[class_name][field_name]["category"] = "arr_float"
			}
			else {
				var category_array = "arr_" + category
				symtab[class_name][field_name]["category"] = category_array
			}

			symtab[class_name][field_name]["length"] = instr[6]
		}
		else {
			symtab[class_name][field_name] = {
				category: category,
				length: null
			}
		}

		symtab[class_name][field_name]["position"] = registers.field_num
		registers.field_num += 1
	}

	else if (op == "new") {
		var var_obj = instr[2]
		var class_name = instr[3]



		if (registers.register_descriptor["eax"] != null) {
			var variable = registers.register_descriptor["eax"]
			var offset = registers.address_descriptor[variable]["offset"]
			assembly.add("mov [ebp - " + offset + "], eax")
			registers.address_descriptor[variable]["type"] = "mem"
			registers.address_descriptor[variable]["name"] = variable
			registers.register_descriptor["eax"] = null

		}

		var size = Object.keys(symtab[class_name]).length * 4
		assembly.add("push " + size)
		assembly.add("call malloc")
		var offset_obj = registers.address_descriptor[var_obj]["offset"]

		assembly.add("add esp, " + 4)
		assembly.add("mov [ebp -" + offset_obj + "], eax")

		Object.keys(symtab[class_name]).forEach(function (field) {
			// console.log(symtab)
			if (symtab[class_name][field]["category"].split("_")[0] == "arr") {
				var size = symtab[class_name][field]["length"] * 4
				// console.log(size)
				assembly.add("push " + size)
				assembly.add("call malloc")
				assembly.add("add esp, " + 4)
				if (registers.register_descriptor["ebx"] != null) {
					var variable = registers.register_descriptor["ebx"]
					var offset = registers.address_descriptor[variable]["offset"]
					assembly.add("mov [ebp - " + offset + "], ebx")
				}
				var position = symtab[class_name][field]["position"]
				assembly.add("mov ebx, [ebp - " + offset_obj + "]")
				assembly.add("mov [ebx + " + position + " * 4], eax")
			}
		})
	}

	else if (op == "fieldget") {	// z = object.field
		var z = instr[2];
		var object = instr[3];
		var class_name = registers.address_descriptor[object]["category"]
		var field = instr[4];
		if (registers.address_descriptor[z]["category"] != "float") {
			var des_z = "";
			var des_field = "";

			if (registers.address_descriptor[z]["type"] == "mem") {	// z in mem
				des_z = registers.getReg(z, line_nr, next_use_table, safe = [y], safe_regs = [], print = true);
				// assembly.add("mov dword " + des_z + ", [ebp - " + registers.address_descriptor[z]["offset"] + "]");
			}
			else if (registers.address_descriptor[z]["type"] == "reg") {	// z in reg
				des_z = registers.address_descriptor[z]["name"];
			}

			// if (field == "length_9" && object == "this") {
			// 	assembly.add("; THIS = " + des_z)
			// }

			des_object = registers.address_descriptor[object]["name"];
			if (registers.address_descriptor[object]["type"] == "mem") {
				des_object = registers.getReg(object, line_nr, next_use_table, safe = [z], safe_regs = [], print = true);
				assembly.add("mov dword " + des_object + ", [ebp - " + registers.address_descriptor[object]["offset"] + "]");
			}

			field_offset = symtab[class_name][field]["position"] * 4
			assembly.add("mov " + des_z + ", [" + des_object + "+" + field_offset + "]")
		}

		else {
			des_object = registers.address_descriptor[object]["name"];
			if (registers.address_descriptor[object]["type"] == "mem") {
				des_object = registers.getReg(object, line_nr, next_use_table, safe = [], safe_regs = [], print = true);
				assembly.add("mov dword " + des_object + ", [ebp - " + registers.address_descriptor[object]["offset"] + "]");
			}

			field_offset = symtab[class_name][field]["position"] * 4

			assembly.add("fld dword [" + des_object + "+" + field_offset + "]")
			assembly.add("fstp dword [ebp - " + registers.address_descriptor[z]["offset"] + "]")
		}
	}

	else if (op == "fieldset") {	//object.field = z
		var object = instr[2]
		var field = instr[3]

		var class_name = registers.address_descriptor[object]["category"]
		// console.log(";" + instr[4])		
		var z = instr[4];
		var field_type = symtab[class_name][field]["category"]
		if (field_type != "float") {
			var des_z = "";
			var des_field = "";

			if (variables.indexOf(z) <= -1) {
				des_z = z
			}
			else if (registers.address_descriptor[z]["type"] == "mem") {	// z in mem
				des_z = registers.getReg(z, line_nr, next_use_table, safe = [y], safe_regs = [], print = true);
				assembly.add("mov dword " + des_z + ", [ebp - " + registers.address_descriptor[z]["offset"] + "]");
			}
			else if (registers.address_descriptor[z]["type"] == "reg") {	// z in reg
				// assembly.add(";" + registers.address_descriptor[instr[4]]["type"])
				// assembly.add(";" + registers.address_descriptor[instr[4]]["name"])
				des_z = registers.address_descriptor[z]["name"];
			}

			des_object = registers.address_descriptor[object]["name"];
			if (registers.address_descriptor[object]["type"] == "mem") {
				des_object = registers.getReg(object, line_nr, next_use_table, safe = [z], safe_regs = [], print = true);
				assembly.add("mov dword " + des_object + ", [ebp - " + registers.address_descriptor[object]["offset"] + "]");
			}

			field_offset = symtab[class_name][field]["position"] * 4
			assembly.add("mov dword [" + des_object + "+" + field_offset + "], " + des_z)
		}
		else {
			des_object = registers.address_descriptor[object]["name"];
			if (registers.address_descriptor[object]["type"] == "mem") {
				des_object = registers.getReg(object, line_nr, next_use_table, safe = [], safe_regs = [], print = true);
				assembly.add("mov dword " + des_object + ", [ebp - " + registers.address_descriptor[object]["offset"] + "]");
			}

			if (variables.indexOf(z) > -1) {
				assembly.add("fld dword [ebp - " + registers.address_descriptor[z]["offset"] + "]")
			}
			else {
				assembly.add_data("_" + line_nr + " DD " + z)
				assembly.add("fld dword [_" + line_nr + "]")
			}

			field_offset = symtab[class_name][field]["position"] * 4

			assembly.add("fstp dword [" + des_object + "+" + field_offset + "]")
		}
	}

	// else if (op == "constructor") {
	// 	var constr_name = instr[2]

	// 	registers.args_counter = -8;
	// 	registers.counter = 0

	// 	assembly.shiftLeft();
	// 	if (func == "main") {
	// 		assembly.add("main:");
	// 	}
	// 	else {
	// 		assembly.add("func_" + func + ":");
	// 	}
	// 	assembly.shiftRight();

	// 	assembly.add("push ebp");
	// 	assembly.add("mov ebp, esp");

	// 	var class_name = constr_name.split("_")[1]
	// 	var size = Object.keys(symtab[class_name]).length * 4
	// 	assembly.add("push " + size)
	// 	assembly.add("call malloc")
	// 	assembly.add("add esp, " + 4)
	// 	assembly.add("mov [ebp + 8], eax")
	// }

	else if (op == "arg") {
		var x = instr[2]
		// assembly.add("sub esp, 4")
		// registers.counter = registers.counter + 4
		// registers.address_descriptor[x] = {"type": "mem", "name": x, "offset":registers.counter}
		if (instr[3] == "basic") {
			if (instr[4] == "int") {
				registers.address_descriptor[x] = { "type": "mem", "name": x, "offset": registers.args_counter, "category": "int" };
			}
			else if (instr[4] == "float") {
				registers.address_descriptor[x] = { "type": "mem", "name": x, "offset": registers.args_counter, "category": "float" };
			}
		}
		else if (instr[3] == "array") {
			if (instr[4] == "int") {
				registers.address_descriptor[x] = { "type": "mem", "name": x, "offset": registers.args_counter, "category": "arr_int" };
			}
			else if (instr[4] == "float") {
				registers.address_descriptor[x] = { "type": "mem", "name": x, "offset": registers.args_counter, "category": "arr_float" };
			}
			else {
				var class_name = instr[4]
				var category = "arr_" + class_name
				registers.address_descriptor[x] = { "type": "mem", "name": x, "offset": registers.counter, "category": category }
			}
		}
		else if (instr[3] == "object") {
			var class_name = instr[4]
			registers.address_descriptor[x] = { "type": "mem", "name": x, "offset": registers.args_counter, "category": class_name };
		}
		registers.args_counter -= 4;
	}
	else if (op == "call") {
		registers.unloadRegisters(line_nr - 1);

		assembly.add("call func_" + instr[2]);
		assembly.add("add esp, " + registers.n_params + "* 4")
		if (instr[4] != null) {
			var variable = instr[4]
			if (registers.address_descriptor[variable]["category"] != "float") {
				// assembly.add("; TEST")
				assembly.add("mov dword [ebp - " + registers.address_descriptor[variable]["offset"] + "], eax")
			}
			else {
				assembly.add("fstp dword [ebp - " + registers.address_descriptor[variable]["offset"] + "]")
			}
		}
		registers.n_params = 0;


	}
	else if (op == "return") {
		registers.unloadRegisters(line_nr - 1);
		// var variable = registers.register_descriptor['eax']
		// assembly.add("mov	[ebp - " + registers.address_descriptor[variable]["offset"] + "], eax")
		var x;
		if (instr[2] != null) {
			x = instr[2]
			if (variables.indexOf(x) == -1) {	// x is constant
				if (x.indexOf(".") != -1) {
					assembly.add_data("_" + line_nr + " DD" + " " + x)
					assembly.add("fld dword _" + line_nr)
				}
				else {
					assembly.add("mov dword eax, " + x)
				}

			}
			else if (registers.address_descriptor[x]["category"] != "float") {
				assembly.add("mov dword eax, [ebp - " + registers.address_descriptor[x]["offset"] + "]")
			}
			else {
				assembly.add("fld dword [ebp - " + registers.address_descriptor[x]["offset"] + "]")
			}
		}
		assembly.add("mov dword esp, ebp");
		assembly.add("pop ebp");
		assembly.add("ret");
		assembly.shiftLeft();
	}
	else if (op == "print") {
		// var rep_variable = registers.register_descriptor["eax"];
		// var variable = instr[2];

		// if (rep_variable == variable) {
		// 	// registers.address_descriptor[variable] = { "type": "mem", "name": variable };
		// 	registers.address_descriptor[variable]["type"] = "mem";
		// 	registers.address_descriptor[variable]["name"] = variable;

		// 	// var des_variable = "[" + variable + "]";
		// 	var des_variable = "[ebp - " + registers.address_descriptor[variable]["offset"] + "]";
		// 	if (next_use_table[line_nr][variable][1] != Infinity) {
		// 		des_variable = registers.loadVariable(variable, line_nr, next_use_table, safe = [], safe_regs = ["eax"], print = false);
		// 	}

		// 	assembly.add("mov dword " + des_variable + ", eax");
		// 	registers.register_descriptor["eax"] = null;
		// }
		// else {
		// 	if (rep_variable != null) {																			// eax is not empty
		// 		var des_rep_variable = registers.loadVariable(rep_variable, line_nr, next_use_table, safe = [], safe_regs = ["eax"]);
		// 		// if (des_rep_variable == "[" + rep_variable + "]") {
		// 		if (des_rep_variable == "[ebp - " + registers.address_descriptor[rep_variable]["offset"] + "]") {
		// 			// registers.address_descriptor[rep_variable] = { "type": "mem", "name": rep_variable };
		// 			registers.address_descriptor[rep_variable]["type"] = "mem";
		// 			registers.address_descriptor[rep_variable]["name"] = rep_variable;
		// 		}
		// 		assembly.add("mov dword " + des_rep_variable + ", eax");
		// 	}

		// 	var des_variable;
		// 	if (registers.address_descriptor[variable]["type"] == "reg") {
		// 		des_variable = registers.address_descriptor[variable]["name"];
		// 	}
		// 	else {
		// 		des_variable = registers.loadVariable(variable, line_nr, next_use_table, safe = [], safe_regs = ["eax"], print = true);
		// 	}
		// 	assembly.add("mov dword eax, " + des_variable);
		// }

		// registers.register_descriptor["eax"] = null;

		// assembly.add("call syscall_print_int");
		// assembly.add("");

	}
	// else if (op == "=arr") {	// z = a[10]
	else if (op == "import") {
		var lib_name = instr[2]
		assembly.addModules(lib_name)
		symtab[lib_name] = {}
	}

	else if (op == "arrget") {	// z = a[10]
		var z = instr[2];
		if (registers.address_descriptor[z]["category"] != "float") {
			var arr = instr[3];
			var y = instr[4];
			var des_z = "";
			var des_y = "";

			// if (registers.address_descriptor[z]["type"] == null) {	// z = a[10]; z declared for first time
			// 	// registers.address_descriptor[z] = { "type": "mem", "name": z };
			// 	registers.address_descriptor[z]["type"] = "mem";
			// 	registers.address_descriptor[z]["name"] = z;
			// }

			if (registers.address_descriptor[z]["type"] == "mem") {	// z in mem
				des_z = registers.getReg(z, line_nr, next_use_table, safe = [y], safe_regs = [], print = true);
				// assembly.add("mov dword " + des_z + ", [ebp - " + registers.address_descriptor[z]["offset"] + "]");
			}
			else if (registers.address_descriptor[z]["type"] == "reg") {	// z in reg
				des_z = registers.address_descriptor[z]["name"];
			}
			if (variables.indexOf(y) == -1) {	// y is constant
				// var place = "(" + registers.address_descriptor[arr]["offset"] + "- (" + y + " * 4))";
				// assembly.add("mov dword " + des_z + ", [ebp - " + place + "]");
				des_y = y;
			}
			else {	//	y not constant
				des_y = registers.address_descriptor[y]["name"];
				if (registers.address_descriptor[y]["type"] == "mem") {
					des_y = registers.getReg(y, line_nr, next_use_table, safe = [z], safe_regs = [], print = true);
					// assembly.add("mov dword " + des_y + ", [" + y + "]");
					assembly.add("mov dword " + des_y + ", [ebp - " + registers.address_descriptor[y]["offset"] + "]");
				}
				// var place = "(" + registers.address_descriptor[arr]["offset"] + "- (" + des_y + " * 4))";			
				// assembly.add("mov dword " + des_z + ", [ebp - " + place + "]");
			}
			var des_pointer;
			if (registers.address_descriptor[arr]["type"] == "reg") {
				des_pointer = registers.address_descriptor[arr]["name"];
			}
			else {
				des_pointer = registers.getReg(arr, line_nr, next_use_table, safe = [y, z], safe_regs = [], print = true);
				assembly.add("mov dword " + des_pointer + ", [ebp - " + registers.address_descriptor[arr]["offset"] + "]")
			}
			assembly.add("mov dword " + des_z + ", [" + des_pointer + " + " + des_y + " * 4]");
		}

		else if (registers.address_descriptor[z]["category"] == "float") {	//z = arr[y]
			var arr = instr[3];
			var y = instr[4];
			var des_z = "";
			var des_y = "";
			if (variables.indexOf(y) == -1) {	// y is constant
				des_y = y;
			}
			else {	//	y not constant
				des_y = registers.address_descriptor[y]["name"];
				if (registers.address_descriptor[y]["type"] == "mem") {
					des_y = registers.getReg(y, line_nr, next_use_table, safe = [z], safe_regs = [], print = true);
					// assembly.add("mov dword " + des_y + ", [" + y + "]");
					assembly.add("mov dword " + des_y + ", [ebp - " + registers.address_descriptor[y]["offset"] + "]");
				}
			}
			var des_pointer;
			if (registers.address_descriptor[arr]["type"] == "reg") {
				des_pointer = registers.address_descriptor[arr]["name"];
			}
			else {
				des_pointer = registers.getReg(arr, line_nr, next_use_table, safe = [y, z], safe_regs = [], print = true);
				assembly.add("mov dword " + des_pointer + ", [ebp - " + registers.address_descriptor[arr]["offset"] + "]")
			}
			assembly.add("fld dword [" + des_pointer + " + " + des_y + " * 4]");
			assembly.add("fstp dword [ebp - " + registers.address_descriptor[z]["offset"] + "]")
		}
	}
	// else if (op == "arr=") {	// a[10] = z
	else if (op == "arrset") {	// a[10] = z
		var arr = instr[2];
		if (registers.address_descriptor[arr]["category"] != "arr_float") {
			var y = instr[3];
			var z = instr[4];
			var des_y = "";
			var des_z = "";
			if (variables.indexOf(y) == -1) { // y is constant
				des_y = y;
			}
			else if (registers.address_descriptor[y]["type"] == "mem") {	//y in mem
				des_y = registers.getReg(y, line_nr, next_use_table, safe = [z], safe_regs = [], print = true);
				// assembly.add("mov dword " + des_y + ", [" + y + "]");
				assembly.add("mov dword " + des_y + ", [ebp - " + registers.address_descriptor[y]["offset"] + "]");
			}
			else {	//y in reg
				des_y = registers.address_descriptor[y]["name"];
			}

			if (variables.indexOf(z) == -1) { // z is constant
				des_z = z;
			}
			else if (registers.address_descriptor[z]["type"] == "mem") {	//z in mem
				des_z = registers.getReg(z, line_nr, next_use_table, safe = [y], safe_regs = [], print = true);
				// assembly.add("mov dword " + des_z + ", [" + z + "]");
				assembly.add("mov dword " + des_z + ", [ebp - " + registers.address_descriptor[z]["offset"] + "]");
			}
			else {	//z in reg
				des_z = registers.address_descriptor[z]["name"];
			}
			// var place = "(" + registers.address_descriptor[arr]["offset"] + "- (" + y + " * 4))";		
			// assembly.add("mov dword [ebp - " + place + "], " + des_z);
			var des_pointer;
			if (registers.address_descriptor[arr]["type"] == "reg") {
				des_pointer = registers.address_descriptor[arr]["name"];
			}
			else {
				des_pointer = registers.getReg(arr, line_nr, next_use_table, safe = [y, z], safe_regs = [], print = true);
				assembly.add("mov dword " + des_pointer + ", [ebp - " + registers.address_descriptor[arr]["offset"] + "]")
			}
			assembly.add("mov dword [" + des_pointer + " + " + des_y + " * 4], " + des_z);
		}
		else if (registers.address_descriptor[arr]["category"] == "arr_float") {	//a[y] = z
			var y = instr[3];
			var z = instr[4];
			var des_y = "";
			var des_z = "";
			if (variables.indexOf(z) > -1) {	// z is variable
				var offset_z = registers.address_descriptor[z]["offset"]
				assembly.add("fld dword [ebp -" + offset_z + "]")
			}
			else {	// z is constant
				assembly.add_data("_" + line_nr + "	" + "DD " + z)
				assembly.add("fld dword [_" + line_nr + "]")
			}


			if (variables.indexOf(y) == -1) { // y is constant
				des_y = y;
			}
			else if (registers.address_descriptor[y]["type"] == "mem") {	//y in mem
				des_y = registers.getReg(y, line_nr, next_use_table, safe = [z], safe_regs = [], print = true);
				// assembly.add("mov dword " + des_y + ", [" + y + "]");
				assembly.add("mov dword " + des_y + ", [ebp - " + registers.address_descriptor[y]["offset"] + "]");
			}
			else {	//y in reg
				des_y = registers.address_descriptor[y]["name"];
			}

			var des_pointer;
			if (registers.address_descriptor[arr]["type"] == "reg") {
				des_pointer = registers.address_descriptor[arr]["name"];
			}
			else {
				des_pointer = registers.getReg(arr, line_nr, next_use_table, safe = [y, z], safe_regs = [], print = true);
				assembly.add("mov dword " + des_pointer + ", [ebp - " + registers.address_descriptor[arr]["offset"] + "]")
			}
			assembly.add("fstp dword [" + des_pointer + " + " + des_y + " * 4]");
		}
	}
	else if (op == "scan") {
		var x = instr[2];
		var des_x = "";
		assembly.add("");
		assembly.add("push eax");
		assembly.add("push ebx");
		assembly.add("push ecx");
		assembly.add("push edx");
		assembly.add("push esi")
		assembly.add("push edi")
		assembly.add("push ebp");
		assembly.add("mov ebp, esp");
		assembly.add("push " + x);
		assembly.add("push _int_scan");
		assembly.add("call scanf");
		assembly.add("mov esp, ebp");
		assembly.add("pop ebp");
		assembly.add("pop edi")
		assembly.add("pop esi")
		assembly.add("pop edx");
		assembly.add("pop ecx");
		assembly.add("pop ebx");
		assembly.add("pop eax");
		if (registers.address_descriptor[x]["type"] == null) {
			// registers.address_descriptor[x] = { "type": "mem", "name": x };
			registers.address_descriptor[x]["type"] = "mem";
			registers.address_descriptor[x]["name"] = x;
		}
		else if (registers.address_descriptor[x]["type"] == "reg") {
			des_x = registers.address_descriptor[x]["name"];
			// assembly.add("mov dword " + des_x + ", [" + x + "]");
			assembly.add("mov dword " + des_x + ", [ebp - " + registers.register_descriptor[x]["offset"] + "]");
		}
		assembly.add("");
	}
	else if (op == "exit") {
		registers.unloadRegisters(line_nr - 1);

		assembly.add("");
		assembly.add("mov dword esp, ebp");
		assembly.add("pop ebp");

		assembly.add("mov dword eax, 1");
		assembly.add("int 0x80");
		assembly.shiftLeft()
	}

	//	--------------------------------- float starts here -----------------------------------------------

	// else if (op == "f=") {	//x = y
	// 	var x = instr[2]
	// 	var y = instr[3]
	// 	if (variables.indexOf(y) > -1 ){	// y is variable
	// 		var offset_y = registers.address_descriptor[y]["offset"]
	// 		assembly.add("fld dword [ebp -" + offset_y + "]")
	// 	}
	// else {	// y is constant
	// 		assembly.add_data("_" + line_nr + "	" + "DD " + y)
	// 		assembly.add("fld dword [_" + line_nr + "]")

	// 	}
	// 	var offset_x = registers.address_descriptor[x]["offset"]
	// 	assembly.add("fstp dword [ebp - " + offset_x + "]")
	// }

	// else if (float_math_ops_binary.indexOf(op) > -1){
	// 	var x = instr[2]
	// 	var y = instr[3]
	// 	var z = instr[4]

	// 	if (variables.indexOf(z) != -1){	// z is variable
	// 		var offset_z = registers.address_descriptor[z]["offset"]
	// 		assembly.add("fld dword [ebp -" + offset_z + "]")			
	// 	}
	// else {	//z is constant
	// 		assembly.add_data("_" + line_nr + "	" + "DD " + z)
	// 		assembly.add("fld dword [_" + line_nr + "]")
	// 	}
	// 	var offset_y = registers.address_descriptor[y]["offset"]
	// 	assembly.add("fld dword [ebp -" + offset_y + "]")
	// 	var offset_x = registers.address_descriptor[x]["offset"]
	// 	assembly.add(map_op[op] + " st0, st1")
	// 	assembly.add("fstp dword [ebp - " + offset_x + "]")
	// 	assembly.add("fstp st0")
	// }

	// else if (float_math_ops_unary.indexOf(op) > -1){
	// 	var x = instr[2]
	// 	assembly.add("fld1")
	// 	var offset_x = registers.address_descriptor[x]["offset"]
	// 	assembly.add("fld dword [ebp -" + offset_x + "]")
	// 	assembly.add(map_op[op] + " st0, st1")
	// 	assembly.add("fstp dword [ebp - " + offset_x + "]")
	// 	assembly.add("fstp st0")
	// }

	else if (op == "cast") {	//x = y
		var from = instr[3]
		var to = instr[4]
		var x = instr[2]
		var y = instr[5]
		var offset_x = registers.address_descriptor[x]["offset"]
		if (from == "int" && to == "float") { //	x = y
			if (variables.indexOf(y) > -1) {
				var offset_y = registers.address_descriptor[y]["offset"]
				if (registers.address_descriptor[y]["type"] == "reg") {
					var des_y = registers.address_descriptor[y]["name"]
					assembly.add("mov dword [ebp - " + offset_y + "], " + des_y)
				}
				assembly.add("fild dword [ebp - " + offset_y + "]")
				assembly.add("fstp dword [ebp - " + offset_x + "]")
			}

			else {	// y is constant
				assembly.add_data("_" + line_nr + " DD " + y)
				assembly.add("fild dword [_" + line_nr + "]")
				assembly.add("fstp dword [ebp - " + offset_x + "]")
			}
		}

		else if (from == "float" && to == "int") {
			if (variables.indexOf(y) > -1) {
				var offset_y = registers.address_descriptor[y]["offset"]
				assembly.add("fld dword [ebp - " + offset_y + "]")
				assembly.add("fistp dword [ebp - " + offset_x + "]")
				if (registers.address_descriptor[x]["type"] == "reg") {
					var des_x = registers.address_descriptor[x]["name"]
					assembly.add("mov dword " + des_x + ", [ebp - " + offset_x + "]")
				}
			}

			else {
				assembly.add_data("_" + line_nr + " DD " + y)
				assembly.add("fld dword [_" + line_nr + "]")
				assembly.add("fistp dword [ebp - " + offset_x + "]")
			}
		}

		else if (from == "int" && to == "int") {
			if (variables.indexOf(y) > -1) {
				var offset_y = registers.address_descriptor[y]["offset"]
				if (registers.address_descriptor[y]["type"] == "reg") {
					var des_y = registers.address_descriptor[y]["name"]
					if (registers.address_descriptor[x]["type"] == "reg") {
						var des_x = registers.address_descriptor[x]["name"]
						assembly.add("mov dword " + des_x + ", " + des_y)
					}
					else {
						assembly.add("mov dword [ebp - " + registers.address_descriptor[x]["offset"] + "], " + des_y)
					}
				}
				else {
					if (registers.address_descriptor[x]["type"] == "reg") {
						var des_x = registers.address_descriptor[x]["name"]
						assembly.add("mov dword " + des_x + ", [ebp - " + registers.address_descriptor[y]["offset"] + "]")
					}
					else {
						var des_x = registers.getReg(x, line_nr, next_use_table, safe = [], safe_regs = [])
						assembly.add("mov dword " + des_x + ", [ebp - " + registers.address_descriptor[y]["offset"] + "]")
					}
				}
			}

			else {	// y is constant
				des_y = y;
				if (registers.address_descriptor[x]["type"] == "reg") {
					var des_x = registers.address_descriptor[x]["name"]
					assembly.add("mov dword " + des_x + ", " + des_y)
				} else {
					// des_x = registers.getReg(x, line_nr, next_use_table, safe = [], safe_regs = [])

					assembly.add("mov dword [ebp - " + registers.address_descriptor[x]["offset"] + "], " + des_y)
				}
			}
		}
		else if (from == "float" && to == "float") {
			if (variables.indexOf(y) > -1) {
				var offset_y = registers.address_descriptor[y]["offset"]
				assembly.add("fld dword [ebp - " + offset_y + "]")
				assembly.add("fstp dword [ebp - " + offset_x + "]")
			}

			else {
				assembly.add_data("_" + line_nr + " DD " + y)
				assembly.add("fld dword [_" + line_nr + "]")
				assembly.add("fstp dword [ebp - " + offset_x + "]")
			}
		}
	}





}


module.exports = {
	codeGen: codeGen
}