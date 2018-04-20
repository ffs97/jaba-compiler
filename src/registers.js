global.registers_list = ["eax", "ebx", "esi", "edi"];


class Registers {
	constructor() {
		this.register_descriptor = {};
		for (var i = 0; i < registers_list.length; i += 1) {
			this.register_descriptor[registers_list[i]] = null;
		}

		this.address_descriptor = {
			// value is a hashmap of two elements: name(iden) and type("mem"/"reg")
		};

		this.counter = 0; // global offset counter from ebp downwards so that to set offset for local variables
		this.n_params = 0; // number of params to be passed to the function to be called
		this.arg_counter = 0; // global counter for number of args
		this.field_num = 0
	}

	// counter

	spillVariable(variable, line_nr, print = true) {
		var self = this;
		if (variables.indexOf(variable) > -1 && self.address_descriptor[variable] != null && self.address_descriptor[variable]["type"] == "reg") {
			var reg = self.address_descriptor[variable]["name"];

			if (print) {
				// print = false;

				// var block = basic_blocks[line_block_mapping[line_nr]];
				// block.some(function (instr) {
				// 	if (instr[2] == variable) {
				// 		print = true;
				// 		return true;
				// 	}
				// }); // MANISH WAS HERE`

				// if (print) assembly.add("mov dword [" + variable + "], " + reg);
				if (print) assembly.add("mov dword [ ebp - " + self.address_descriptor[variable]["offset"] + "], " + reg);
			}
			// self.address_descriptor[variable] = { "type": "mem", "name": variable};
			self.address_descriptor[variable]["type"] = "mem";
			self.address_descriptor[variable]["name"] = variable;
			self.register_descriptor[reg] = null;
		}
	}


	getEmptyReg(variable, line_nr, next_use_table, safe = [], safe_regs = []) {
		var self = this;

		var rep_reg = null;
		registers_list.some(function (register) {
			if (safe_regs.indexOf(register) == -1 && self.register_descriptor[register] == null) {
				self.register_descriptor[register] = variable;
				// self.address_descriptor[variable] = { "type": "reg", "name": register };
				self.address_descriptor[variable]["type"] = "reg";
				self.address_descriptor[variable]["name"] = register;



				rep_reg = register;
				return true;
			}
		});

		return rep_reg;
	}


	getNoUseReg(variable, line_nr, next_use_table, safe = [], safe_regs = []) {
		var self = this;

		var rep_var;
		var rep_reg = null;

		registers_list.some(function (register) {
			if (safe_regs.indexOf(register) == -1) {
				rep_var = self.register_descriptor[register];
				if (safe.indexOf(rep_var) == -1 && next_use_table[line_nr][rep_var][1] == Infinity) {	//no next use empty it
					self.spillVariable(rep_var, line_nr, print = true);

					// self.address_descriptor[variable] = { "type": "reg", "name": register };
					self.address_descriptor[variable]["type"] = "reg";
					self.address_descriptor[variable]["name"] = register;
					self.register_descriptor[register] = variable;

					rep_reg = register;
					return true;
				}
			}
		});

		return rep_reg;
	}


	getReg(variable, line_nr, next_use_table, safe = [], safe_regs = []) {
		var self = this;
		//TODO : imul x y z, y not in reg, y 2nd last next use after x.
		var rep_reg;
		var rep_var;
		var rep_use = 0;

		rep_reg = self.getEmptyReg(variable, line_nr, next_use_table, safe);
		if (rep_reg != null) {
			return rep_reg;
		}
		rep_reg = self.getNoUseReg(variable, line_nr, next_use_table, safe);
		if (rep_reg != null) {
			return rep_reg;
		}

		registers_list.forEach(function (register) {
			if (safe_regs.indexOf(register) == -1) {
				var curr_var = self.register_descriptor[register];
				if (safe.indexOf(curr_var) == -1 && next_use_table[line_nr][curr_var][1] > rep_use) {
					rep_reg = register;
					rep_var = curr_var;
					rep_use = next_use_table[line_nr][curr_var][1];
				}
			}
		});

		self.spillVariable(rep_var, line_nr, print = true);

		self.register_descriptor[rep_reg] = variable;
		// self.address_descriptor[variable] = { "type": "reg", "name": register };
		self.address_descriptor[variable]["type"] = "reg";
		self.address_descriptor[variable]["name"] = register;

		return rep_reg;
	}


	checkFarthestNextUse(variable, line_nr, next_use_table, safe = []) {
		var flag = true
		variables.some(function (check_var) {
			if (safe.indexOf(check_var) == -1 && next_use_table[line_nr][variable][2] < next_use_table[line_nr][check_var][2]) {
				flag = false;
				return true;
			}
		})

		return flag;
	}


	unloadRegisters(line_nr) {
		var self = this;
		variables.forEach(function (variable) {
			self.spillVariable(variable, line_nr, true);
		});
	}


	loadVariable(variable, line_nr, next_use_table, safe = [], safe_regs = [], print = true) {
		var self = this;

		var des_variable = self.address_descriptor[variable]["name"];
		if (des_variable == null) {
			// self.address_descriptor[variable] = { "type": "mem", "name": variable };
			self.address_descriptor[variable]["type"] = "mem";
			self.address_descriptor[variable]["name"] = variable;
			des_variable = variable;
		}

		if (self.address_descriptor[variable]["type"] == "reg" && safe_regs.indexOf(self.address_descriptor[variable]["name"]) == -1) {
			return des_variable;
		}
		else {
			des_variable = variable;
		}

		var reg;
		if (next_use_table[line_nr][variable][1] == Infinity) {			// variable has no next use
			// des_variable = "[" + des_variable + "]";
			des_variable = "[ ebp - " + self.address_descriptor[variable]["offset"] + "]";
		}
		else if (self.checkFarthestNextUse(variable, line_nr, next_use_table)) {	// variable has farthest use
			if ((reg = self.getEmptyReg(variable, line_nr, next_use_table, safe, safe_regs)) != null) {	// there is an empy register
				des_variable = reg;
				// if (print) assembly.add("mov dword " + des_variable + ", [" + variable + "]");
				if (print) assembly.add("mov dword " + des_variable + ", [ ebp - " + self.address_descriptor[variable]["offset"] + "]");
			}
			else if ((reg = self.getNoUseReg(variable, line_nr, next_use_table, safe, safe_regs)) != null) {				// there is a no use register
				des_variable = reg;
				if (print) assembly.add("mov dword " + des_variable + ", [ ebp - " + self.address_descriptor[variable]["offset"] + "]");
				// if (print) assembly.add("mov dword " + des_variable + ", [" + variable + "]");
			}
			else {
				// des_variable = "[" + des_variable + "]";
				des_variable = "[ ebp - " + self.address_descriptor[variable]["offset"] + "]";

			}
		}
		else {																						// variable has some use
			des_variable = self.getReg(variable, line_nr, next_use_table, safe, safe_regs);
			// if (print) assembly.add("mov dword " + des_variable + ", [" + variable + "]");
			if (print) assembly.add("mov dword " + des_variable + ", [ ebp - " + self.address_descriptor[variable]["offset"] + "]");
		}

		return des_variable;
	}
}


module.exports = {
	Registers: Registers,
	registers_list: registers_list
};