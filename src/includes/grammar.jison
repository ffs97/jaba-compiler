%{
	var utils = {
		assign: function(obj) {
			var self = { code: [], place: null }

			if (obj.field) {
				self.consr_code = []
			}


			for (var var_index in obj.var_declarators) {
				variable = obj.var_declarators[var_index]
				
				variable.identifier = ST.add_variable(variable.identifier, obj.type, isparam = false, isfield = obj.field).display_name

				if (obj.field) {
					var t = ST.create_temporary()

					self.consr_code = self.consr_code.concat([
						"decr" + ir_sep + t + ir_sep + obj.type.category + ir_sep + obj.type.get_basic_type() + ir_sep + obj.type.get_size(),
						"fieldget" + ir_sep + t + ir_sep + "this" + ir_sep + variable.identifier
					])
					variable.place = t
				}

				if (obj.type.category == "array") {
					
					if (variable.init != null) {
						var inits = variable.init
						var type = obj.type

						var length = 1

						if (parseInt(type.length).toString() != type.length) {
							throw Error("Dimension cannot be a variable for array declaration")
						}
						if (parseInt(type.length) <= 0) {
							throw Error("Array size must be positive")
						}

						if (type.dimension == 0 || type.length != inits.length) {
							throw Error("Array dimensions do not match")
						}

						while (type.dimension != 0) {
							length *= parseInt(type.length)

							type = type.type

							if (type.length != null) {
								if (parseInt(type.length).toString() != type.length || parseInt(type.length) <= 0) {
									throw Error("Invalid array size, must be a positive integer")
								}
							}
							
							var inits_serial = []
							for (var index in inits) {
								if (type.length != inits[index].length) {
									throw Error("Array dimensions do not match")
								}

								inits_serial = inits_serial.concat(inits[index])
							}
							inits = inits_serial
						}

						if (inits[0].length) {
							throw Error("Array dimensions do not match")
						}

						if (obj.field) {
							self.code.push(
								"field_decr" + ir_sep + ST.current_class.name + ir_sep + variable.identifier + ir_sep + "array" + ir_sep + type.type + ir_sep + length
							)
						}
						else {
							self.code.push(
								"decr" + ir_sep + variable.identifier + ir_sep + "array" + ir_sep + type.type + ir_sep + length
							)
						}

						for (var index in inits) {
							if (!(inits[index].type.type == type.type || (inits[index].type.numeric() && type.numeric()))) {
								throw Error("Cannot convert '" + inits[index].type.type + "' to '" + type.type + "'")
							}

							if (obj.field) {
								self.consr_code = self.consr_code.concat(inits[index].code)
							}
							else {
								self.code = self.code.concat(inits[index].code)
							}

							if (inits[index].type.type != type.type) {
								var temp = ST.create_temporary()

								if (obj.field) {
									self.consr_code = self.consr_code.concat([
										"decr" + ir_sep + temp + ir_sep + type.category + ir_sep + type.type + ir_sep + "1",
										"cast" + ir_sep + temp + ir_sep + inits[index].type.type + ir_sep + type.type + ir_sep + inits[index].place,
										"arrset" + ir_sep + variable.place + ir_sep + index + ir_sep + temp
									])
								}
								else {
									self.code = self.code.concat([
										"decr" + ir_sep + temp + ir_sep + type.category + ir_sep + type.type + ir_sep + "1",
										"cast" + ir_sep + temp + ir_sep + inits[index].type.type + ir_sep + type.type + ir_sep + inits[index].place,
										"arrset" + ir_sep + variable.identifier + ir_sep + index + ir_sep + temp
									])
								}
							}
							else {
								if (obj.field) {
									self.consr_code.push(
										"arrset" + ir_sep + variable.place + ir_sep + index + ir_sep + inits[index].place
									)
								}
								else {
									self.code.push(
										"arrset" + ir_sep + variable.identifier + ir_sep + index + ir_sep + inits[index].place
									)
								}
							}
						}
					}
					else {
						var length = 1
						var type = obj.type

						while (type.dimension != 0) {
							length *= type.length

							type = type.type
						}

						if (obj.field) {
							self.code.push(
								"field_decr" + ir_sep + ST.current_class.name + ir_sep + variable.identifier + ir_sep + "array" + ir_sep + type.get_basic_type() + ir_sep + length
							)
						}
						else {
							self.code.push(
								"decr" + ir_sep + variable.identifier + ir_sep + "array" + ir_sep + type.get_basic_type() + ir_sep + length + ir_sep
							)
						}
					}
				}
				else {
					if (obj.field) {
						self.code.push(
							"field_decr" + ir_sep + ST.current_class.name + ir_sep + variable.identifier + ir_sep + obj.type.category + ir_sep + obj.type.get_basic_type() + ir_sep + obj.type.get_size()
						)
					}
					else {
						self.code.push(
							"decr" + ir_sep + variable.identifier + ir_sep + obj.type.category + ir_sep + obj.type.type + ir_sep + "1"
						)
					}

					if (variable.init != null) {
						if (!(variable.init.type.type == obj.type.type || (variable.init.type.numeric() && obj.type.numeric()))) {
							throw Error("Cannot convert '" + variable.init.type.type + "' to '" + obj.type.type + "'")
						}

						if (obj.field) {
							self.consr_code = self.consr_code.concat(variable.init.code)
						}
						else {
							self.code = self.code.concat(variable.init.code)
						}

						if (variable.init.type.type != obj.type.type) {
							var temp = ST.create_temporary()

							if (obj.field) {
								self.consr_code = self.consr_code.concat([
									"decr" + ir_sep + temp + ir_sep + obj.type.category + ir_sep + obj.type.type + ir_sep + "1",
									"cast" + ir_sep + temp + ir_sep + variable.init.type.type + ir_sep + obj.type.type + ir_sep + variable.init.place,
									"fieldset" + ir_sep + "this" + ir_sep + variable.identifier + ir_sep + temp
								])
							}
							else {
								self.code = self.code.concat([
									"decr" + ir_sep + temp + ir_sep + obj.type.category + ir_sep + obj.type.type + ir_sep + "1",
									"cast" + ir_sep + temp + ir_sep + variable.init.type.type + ir_sep + obj.type.type + ir_sep + variable.init.place,
									"=" + ir_sep + variable.identifier + ir_sep + temp
								])
							}
						}
						else {
							if (obj.field) {
								self.consr_code.push(
									"fieldset" + ir_sep + "this" + ir_sep + variable.identifier + ir_sep + variable.init.place
								)
							}
							else {
								self.code.push(
									"=" + ir_sep + variable.identifier + ir_sep + variable.init.place
								)
							}
						}
					}
				}
			}

			return self
		},

		binary: function (obj) {

			var self = {
				code: obj.op1.code.concat(obj.op2.code),
				place: null,
				type: null,
				literal: false
			}

			if (obj.op1.type.type == "float" || obj.op2.type.type == "float") {
				self.type = new Type("float", "basic", 4, 0, 0)
			}
			else if (obj.op1.type.type == "long" || obj.op2.type.type == "long") {
				self.type = new Type("long", "basic", 8, 0, 0)
			}
			else if (obj.op1.type.type == "int" || obj.op2.type.type == "int") {
				self.type = new Type("int", "basic", 4, 0, 0)
			}
			else if (obj.op1.type.type == "short" || obj.op2.type.type == "short") {
				self.type = new Type("short", "basic", 2, 0, 0)
			}
			else if (obj.op1.type.type == "byte" || obj.op2.type.type == "byte") {
				self.type = new Type("byte", "basic", 1, 0, 0)
			}
			else if (obj.op1.type.type == "boolean" || obj.op2.type.type == "boolean") {
				self.type = new Type("boolean", "basic", 1, 0, 0)
			}

			if (!(obj.op1.literal && !isNaN(obj.op1.place))) {
				var temp = ST.create_temporary()
				self.code.push(
					"decr" + ir_sep + temp + ir_sep + self.type.category + ir_sep + self.type.type + ir_sep + "1"
				)

				var t1 = obj.op1.place
				if (obj.op1.type.type != self.type.type) {
					t1 = ST.create_temporary()
					self.code = self.code.concat([
						"decr" + ir_sep + t1 + ir_sep + self.type.category + ir_sep + self.type.type + ir_sep + "1",
						"cast" + ir_sep + t1 + ir_sep + obj.op1.type.type + ir_sep + self.type.type + ir_sep + obj.op1.place
					])
				}

				var t2 = obj.op2.place
				if (obj.op2.type.type != self.type.type) {
					t2 = ST.create_temporary()
					self.code = self.code.concat([
						"decr" + ir_sep + t2 + ir_sep + self.type.category + ir_sep + self.type.type + ir_sep + "1",
						"cast" + ir_sep + t2 + ir_sep + obj.op2.type.type + ir_sep + self.type.type + ir_sep + obj.op2.place
					])
				}

				self.code.push(
					obj.operator + ir_sep + temp + ir_sep + t1 + ir_sep + t2
				)

				self.place = temp
			}
			else if (!(obj.op2.literal && !isNaN(obj.op2.place))) {
				var temp = ST.create_temporary()
				self.code.push(
					"decr" + ir_sep + temp + ir_sep + self.type.category + ir_sep + self.type.type + ir_sep + "1"
				)

				var t1 = obj.op1.place
				if (obj.op1.type.type != self.type.type) {
					t1 = ST.create_temporary()
					self.code = self.code.concat([
						"decr" + ir_sep + t1 + ir_sep + self.type.category + ir_sep + self.type.type + ir_sep + "1",
						"cast" + ir_sep + t1 + ir_sep + obj.op1.type.type + ir_sep + self.type.type + ir_sep + obj.op1.place
					])
				}

				var t2 = obj.op2.place
				if (obj.op2.type.type != self.type.type) {
					t2 = ST.create_temporary()
					self.code = self.code.concat([
						"decr" + ir_sep + t2 + ir_sep + self.type.category + ir_sep + self.type.type + ir_sep + "1",
						"cast" + ir_sep + t2 + ir_sep + obj.op2.type.type + ir_sep + self.type.type + ir_sep + obj.op2.place
					])
				}

				self.code.push(
					obj.operator + ir_sep + temp + ir_sep + t2 + ir_sep + t1
				)

				self.place = temp
			}
			else {
				self.place = eval(obj.op1.place + " " + obj.operator + " " + obj.op2.place)
				self.literal = true
			}

			return self
		},

		relational: function (obj) {

			var self = { code: [], place: null, type: null, literal: false }
			
			if (obj.op1.type.type == "float" || obj.op2.type.type == "float") {
				self.type = new Type("float", "basic", 4, 0, 0)
			}
			else if (obj.op1.type.type == "long" || obj.op2.type.type == "long") {
				self.type = new Type("long", "basic", 8, 0, 0)
			}
			else if (obj.op1.type.type == "int" || obj.op2.type.type == "int") {
				self.type = new Type("int", "basic", 4, 0, 0)
			}
			else if (obj.op1.type.type == "short" || obj.op2.type.type == "short") {
				self.type = new Type("short", "basic", 2, 0, 0)
			}
			else if (obj.op1.type.type == "byte" || obj.op2.type.type == "byte") {
				self.type = new Type("byte", "basic", 1, 0, 0)
			}
			else if (obj.op1.type.type == "boolean" || obj.op2.type.type == "boolean") {
				self.type = new Type("boolean", "basic", 1, 0, 0)
			}

			self.code = obj.op1.code.concat(obj.op2.code)

			if (obj.op1.literal && !isNaN(obj.op1.place)) {
				var tt = ST.create_temporary()
				self.code = self.code.concat(
					"decr" + ir_sep + tt + ir_sep + obj.op1.type.category + ir_sep + obj.op1.type.type + ir_sep + "1",
					"=" + ir_sep + tt + ir_sep + obj.op1.place
				)
				obj.op1.place = tt
			}

			var temp = ST.create_temporary()
			self.code.push(
				"decr" + ir_sep + temp + ir_sep + "basic" + ir_sep + "int" + ir_sep + "1"
			)

			var t1 = obj.op1.place
			if (obj.op1.type.type != self.type.type) {
				t1 = ST.create_temporary()
				self.code = self.code.concat([
					"decr" + ir_sep + t1 + ir_sep + self.type.category + ir_sep + self.type.type + ir_sep + "1",
					"cast" + ir_sep + t1 + ir_sep + obj.op1.type.type + ir_sep + self.type.type + ir_sep + obj.op1.place
				])
			}

			var t2 = obj.op2.place
			if (obj.op2.type.type != self.type.type) {
				t2 = ST.create_temporary()
				self.code = self.code.concat([
					"decr" + ir_sep + t2 + ir_sep + self.type.category + ir_sep + self.type.type + ir_sep + "1",
					"cast" + ir_sep + t2 + ir_sep + obj.op2.type.type + ir_sep + self.type.type + ir_sep + obj.op2.place
				])
			}

			var label = ST.create_label()
		
			self.code = self.code.concat([
				"=" + ir_sep + temp + ir_sep + "1",
				"ifgoto" + ir_sep + obj.operator + ir_sep + t1 + ir_sep + t2 + ir_sep + label,
				"=" + ir_sep + temp + ir_sep + "0",
				"label" + ir_sep + label
			])
			self.place = temp

			self.type = new Type("boolean", "basic", 1, 0, 0)

			return self
		},

		boolean_type_array: ["boolean"],
		numeric_type_array: ["int", "char", "short", "long", "byte", "float"],

		compare_types: function(type1, type2) {
		}
	}
%}

%lex

%s BLOCKCOMMENT
%s COMMENT

%%

\/\*								{
										var top = this.conditionStack[this.conditionStack.length - 1]
										if (top != 'BLOCKCOMMENT') {
											this.pushState('BLOCKCOMMENT');
										}
									}

<BLOCKCOMMENT>\*\/					this.popState();

<BLOCKCOMMENT>(\n|\r|.)				/* SKIP BLOCKCOMMENTS */

\/\/								{
										var top = this.conditionStack[this.conditionStack.length - 1]
										if (top != 'COMMENT') {
											this.pushState('COMMENT');
										}
									}

<COMMENT>(.)						/* SKIP COMMENTS */

<COMMENT>(\n|\r)					this.popState();

<COMMENT><<EOF>>					this.popState();

\s+									/* SKIP WHITESPACES */

"boolean"							return 'boolean';

"break"								return 'break';

"byte"								return 'byte';

"char"								return 'char';

"class" 							return 'class';

"continue"							return 'continue';

"double"							return 'double';

"else"								return 'else';

"float"								return 'float';

"for"								return 'for';

"if"								return 'if';

"import"							return 'import';

"instanceof"						return 'instanceof';

"int"								return 'int';

"long"								return 'long';

"new"								return 'new';

"public"							return 'public';

"return"							return 'return';

"short" 							return 'short';

"void"								return 'void';

"while" 							return 'while';

[+][+]								return 'op_increment';

[-][-]								return 'op_decrement';

[+][=]								return 'op_addAssign';

[-][=]								return 'op_subAssign';

[*][=]								return 'op_mulAssign';

[/][=]								return 'op_divAssign';

[%][=]								return 'op_modAssign';

[&][=]								return 'op_andAssign';

[|][=]								return 'op_orAssign';

[\^][=]								return 'op_xorAssign';

[!][=]								return 'op_notequalCompare';

[=][=]								return 'op_equalCompare';

[<][<][=]							return 'op_LshiftEqual';

[>][>][=]							return 'op_RshiftEqual';

[>][=]								return 'op_greaterEqual';

[<][=]								return 'op_lessEqual';

[<][<]								return 'op_Lshift';

[>][>]								return 'op_Rshift';

[+]									return 'op_add';

[-]									return 'op_sub';

[*]									return 'op_mul';

[/]									return 'op_div';

[%]									return 'op_mod';

[>]									return 'op_greater';

[<]									return 'op_less';

[=]									return 'op_assign';

[&][&]								return 'op_andand';

[|][|]								return 'op_oror';

[&]									return 'op_and';

[|]									return 'op_or';

[!]									return 'op_not';

[\^]								return 'op_xor';

[:] 								return 'colon';

[0-9]+\.[0-9]*						return 'float_literal';

[0-9]+								return 'integer_literal';

"true"								return 'boolean_literal';

"false"								return 'boolean_literal';

"null"								return 'null_literal';

\'(\\[^\n\r]|[^\\\'\n\r])\'			return 'character_literal';

([a-z]|[A-Z]|[$]|[_])(\w)*			return 'identifier';

[;]									return 'terminator';

[.]									return 'field_invoker';

[,]									return 'separator';

[(]									return 'paranthesis_start';

[)]									return 'paranthesis_end';

[\[]								return 'brackets_start';

[\]]								return 'brackets_end';

[{]									return 'set_start';

[}]									return 'set_end';

<<EOF>>								return 'EOF';

/lex


%start program
%% /* language grammar */


program :
		import_decrs type_decrs 'EOF' 
		{
			var labels = {}
			var line_number = 0
			var code = $1.code.concat($2.code)
			var filtered_code = []

			for (var index in code) {
				var line = code[index].split(ir_sep)

				if (line[0] == "label") {
					labels[line[1]] = line_number + 1
				}
				else {
					line_number += 1
					filtered_code.push(code[index])
				}
			}

			for (var index in filtered_code) {
				var line = filtered_code[index].split(ir_sep)

				if (line[0] == "jump") {
					line[1] = labels[line[1]]
				}
				else if (line[0] == "ifgoto") {
					line[4] = labels[line[4]]
				}

				filtered_code[index] = line.join("	").replace(/\bboolean\b|\bchar\b|\bshort\b|\blong\b/g, "int")
			}

			if (ST.main_method == null) {
				filtered_code = filtered_code.concat([
					"function" + ir_sep + "main",
					"return"
				])
			}

			return filtered_code
		}
	|
		import_decrs 'EOF' 
		{
			return $1.code.concat([
				"function" + ir_sep + "main",
				"return"
			])
		}
	|
		type_decrs 'EOF' 
		{
			var labels = {}
			var line_number = 0
			var code = $1.code
			var filtered_code = []

			for (var index in code) {
				var line = code[index].split(ir_sep)

				if (line[0] == "label") {
					labels[line[1]] = line_number + 1
				}
				else {
					line_number += 1
					filtered_code.push(code[index])
				}
			}

			for (var index in filtered_code) {
				var line = filtered_code[index].split(ir_sep)

				if (line[0] == "jump") {
					line[1] = labels[line[1]]
				}
				else if (line[0] == "ifgoto") {
					line[4] = labels[line[4]]
				}

				filtered_code[index] = line.join("	").replace(/\bboolean\b|\bchar\b|\bshort\b|\blong\b/g, "int")
			}

			if (ST.main_method == null) {
				filtered_code = filtered_code.concat([
					"function" + ir_sep + "main",
					"return"
				])
			}

			return filtered_code
		}
	|
		'EOF' 
		{
			return [
				"function" + ir_sep + "main",
				"return"
			]
		}
	;


import_decrs :
		import_decr 
		{
			$$ = { code: [$1.code], place: null }
		}
	|
		import_decrs import_decr 
		{
			$$ = $1
			$$.code.push($2.code)
		}
	;


import_decr :
		'import' 'identifier' 'terminator' 
		{
			$$ = { code: "import" + ir_sep + $identifier, place: null }
			ST.import($identifier)
		}
	;


type_decrs :
		type_decrs type_decr 
		{
			$$ = $1
			$$.code = $$.code.concat($2.code)
		}
	|
		type_decr 
		{
			$$ = $1
		}
	;


type_decr :
		class_decr 
		{
			$$ = $1
		}
	|
		'terminator' 
		{
			$$ = { code: [], place: null }
		}
	;


class_decr :
		class_header class_body 
		{
			$$ = $1
			$$.code = $$.code.concat($2.code)
		}
	;


class_header :
		'public' 'class' 'identifier' 
		{
			$$ = {
				code: ["class" + ir_sep + $identifier],
				place: null
			}
			
			var class_instance = ST.add_class($identifier, "")

			var parameters = []

			ST.variables_count += 1
			class_type = new Type(ST.current_class.name, "object", null, null, 0)
			var parameters = [new Variable("this", class_type, ST.variables_count, isparam = true)]

			class_instance.constructor = new Method($identifier, new Type("null", "basic", null, null, 0), parameters, null)
		}
	|
		'class' 'identifier' 
		{
			$$ = {
				code: ["class" + ir_sep + $identifier],
				place: null
			}
			
			var class_instance = ST.add_class($identifier, "")

			var parameters = []

			ST.variables_count += 1
			class_type = new Type(ST.current_class.name, "object", null, null, 0)
			var parameters = [new Variable("this", class_type, ST.variables_count, isparam = true)]

			class_instance.constructor = new Method($identifier, new Type("null", "basic", null, null, 0), parameters, null)
		}
	;


class_body :
		'set_start' class_body_decrs 'set_end' 
		{
			$$ = $2

			var curr_class = ST.current_class

			if ($$.consr.length == 0) {
				var self = curr_class.constructor.parameters[0]

				$$.consr = $$.consr.concat([
					"function" + ir_sep + curr_class.name + "_" + curr_class.name,
					"arg" + ir_sep + self.display_name + ir_sep + self.type.category + ir_sep + self.type.get_basic_type() + ir_sep + self.type.get_size()
				])

				$$.consr_body = "return"
			}

			$$.code = $$.code.concat($$.consr)
			$$.code = $$.code.concat($$.consr_code)
			$$.code = $$.code.concat($$.consr_body)
		}
	;


class_body_decrs :
		class_body_decrs class_body_decr 
		{
			$$ = $1
			$$.code = $$.code.concat($2.code)
			$$.consr = $$.consr.concat($2.consr)
			$$.consr_code = $$.consr_code.concat($2.consr_code)
			$$.consr_body = $$.consr_body.concat($2.consr_body)
		}
	|
		class_body_decr 
		{
			$$ = $1
		}
	;


class_body_decr :
		class_member_decr 
		{
			$$ = { code: $1.code, place: null, consr: [], consr_code: $1.consr_code, consr_body: [] }
		}
	|
		consr_declarator consr_body 
		{
			var scope = ST.scope_end()

			var method = $1.method

			if (scope.return_types.length != 0) {
				throw Error("A constructor has a null return type")
			}

			$$ = { code: [], place: null, consr: [], consr_code: [], consr_body: [] }

			$$.consr.push(
				"function" + ir_sep + ST.current_class.name + "_" + ST.current_class.name
			)

			for (var index = method.parameters.length - 1; index >= 0; index--) {
				$$.consr.push(
					"arg" + ir_sep + method.parameters[index].display_name + ir_sep + method.parameters[index].type.category + ir_sep + method.parameters[index].type.get_basic_type() + ir_sep + method.parameters[index].type.get_size()
				)
			}

			$$.consr_body = $$.consr_body.concat($2.code)
			$$.consr_body.push("return")
		}
	;


class_member_decr :
		field_decr 
		{
			$$ = $1
		}
	|
		method_decr 
		{
			$$ = $1
			$$.consr_code = []
		}
	;


consr_declarator :
		'identifier' 'paranthesis_start' formal_parameter_list 'paranthesis_end' 
		{
			$$ = {
				scope: null,
				method: null
			}

			if ($identifier != ST.current_class.name) {
				throw Error("Function must have a return type")
			}
			
			if (ST.current_class.constructor_init) {
				throw Error("The class constructor has already been defined")
			}

			var scope = ST.scope_start(category = "function")
			var parameters = []

			ST.variables_count += 1
			class_type = new Type(ST.current_class.name, "object", null, null, 0)
			scope.parameters["this"] = scope.add_variable("this", class_type, ST.variables_count, isparam = true)
			parameters.push(scope.parameters["this"])

			for (var index in $3) {
				ST.variables_count += 1
				var variable = scope.add_variable($3[index].name, $3[index].type, ST.variables_count, isparam = true)
				scope.parameters[variable.name] = variable
				parameters.push(variable)
			}

			$$.method = new Method($identifier, new Type("null", "basic", null, null, 0), parameters, scope)

			ST.current_class.constructor = $$.method
			ST.current_class.constructor_init = true

			$$.scope = scope
		}
	|
		'public' 'identifier' 'paranthesis_start' formal_parameter_list 'paranthesis_end' 
		{
			$$ = {
				scope: null,
				method: null
			}

			if ($identifier != ST.current_class.name) {
				throw Error("Function must have a return type")
			}
			
			if (ST.current_class.constructor != null) {
				throw Error("The class constructor has already been defined")
			}

			var scope = ST.scope_start(category = "function")
			var parameters = []

			ST.variables_count += 1
			class_type = new Type(ST.current_class.name, "object", null, null, 0)
			scope.parameters["this"] = scope.add_variable("this", class_type, ST.variables_count, isparam = true)
			parameters.push(scope.parameters["this"])

			for (var index in $4) {
				ST.variables_count += 1
				var variable = scope.add_variable($4[index].name, $4[index].type, ST.variables_count, isparam = true)
				scope.parameters[variable.name] = variable
				parameters.push(variable)
			}

			$$.method = new Method($identifier, new Type("null", "basic", null, null, 0), parameters, scope)

			ST.current_class.constructor = $$.method

			$$.scope = scope
		}
	;


consr_body :
		'set_start' explicit_consr_invocation block_stmts 'set_end' 
		{
			var code = []
			for (var index in $2) {
				code = code.concat($2[index].code)
			}

			$$ = { code: $2.code.concat(code), place: null }
		}
	|
		'set_start' block_stmts 'set_end' 
		{
			var code = []
			for (var index in $2) {
				code = code.concat($2[index].code)
			}

			$$ = { code: code, place: null }
		}
	|
		'set_start' explicit_consr_invocation 'set_end' 
		{
			$$ = { code: $2.code, place: null }
		}
	|
		'set_start' 'set_end' 
		{
			$$ = { code: [], place: null }
		}
	;



formal_parameter_list :
		formal_parameter_list 'separator' formal_parameter 
		{
			$$ = $1
			$$.push($3)
		}
	|
		formal_parameter 
		{
			$$ = [$1]
		}
	|
		
		{
			$$ = []
		}
	;


formal_parameter :
		type var_declarator_id 
		{
			$$ = { name: $2, type: $1 }
		}
	;


field_decr :
		'public' type var_declarators 'terminator' 
		{
			$$ = utils.assign({
				type: $2,
				var_declarators: $3,
				field: true
			})
		}
	|
		type var_declarators 'terminator' 
		{
			$$ = utils.assign({
				type: $1,
				var_declarators: $2,
				field: true
			})
		}
	;


var_declarators :
		var_declarators 'separator' var_declarator 
		{
			$$ = $1
			$$.push($3)
		}
	|
		var_declarator 
		{
			$$ = [$1]
		}
	;


var_declarator :
		var_declarator_id 
		{
			$$ = { identifier: $1, init: null }
		}
	|
		var_declarator_id 'op_assign' var_init 
		{
			$$ = { identifier: $1, init: $3 }
		}
	;


var_declarator_id :
		'identifier' 
		{
			$$ = $identifier
		}
	;


var_init :
		expr
		{
			$$ = $1
		}
	|
		array_init 
		{
			$$ = $1
		}
	;


array_init :
		'set_start' var_inits 'separator' 'set_end' 
		{
			$$ = $2
		}
	|
		'set_start' var_inits 'set_end' 
		{
			$$ = $2
		}
	;


var_inits :
		var_inits 'separator' var_init 
		{
			$$ = $1
			$$.push($3)
		}
	|
		var_init 
		{
			$$ = [$1]
		}
	;


type :
		primitive_type 
		{
			$$ = new Type($1.type, $1.category, $1.width, $1.length, $1.dimension)
		}
	|
		reference_type 
		{
			$$ = $1
		}
	;


primitive_type :
		integral_type 
		{
			$$ = $1
		}
	|
		floating_type 
		{
			$$ = $1
		}
	|
		'boolean' 
		{
			$$ = {
				type: "boolean",
				category: "basic",
				width: 1,
				length: null,
				dimension: 0
			}
		}
	;


integral_type :
		'byte' 
		{
			$$ = {
				type: "byte",
				category: "basic",
				width: 1,
				length: null,
				dimension: 0
			}
		}
	|
		'short' 
		{
			$$ = {
				type: "short",
				category: "basic",
				width: 2,
				length: null,
				dimension: 0
			}
		}
	|
		'int' 
		{
			$$ = {
				type: "int",
				category: "basic",
				width: 4,
				length: null,
				dimension: 0
			}
		}
	|
		'long' 
		{
			$$ = {
				type: "long",
				category: "basic",
				width: 8,
				length: null,
				dimension: 0
			}
		}
	|
		'char' 
		{
			$$ = {
				type: "int",
				category: "basic",
				width: 4,
				length: null,
				dimension: 0
			}
		}
	;


floating_type :
		'float' 
		{
			$$ = {
				type: "float",
				category: "basic",
				width: 4,
				length: null,
				dimension: 0
			}
		}
	|
		'double' 
		{
			$$ = {
				type: "float",
				category: "basic",
				width: 4,
				length: null,
				dimension: 0
			}
		}
	;


reference_type :
		'identifier' 
		{
			$$ = new Type(ST.lookup_class($identifier).name, "object", null, null, 0)
		}
	|
		'identifier' dim_exprs 
		{
			var type = new Type(ST.lookup_class($identifier).name, "object", null, null, 0)

			var l = $2.length - 1
			while (l >= 0) {
				type = new Type(type, "array", 4, $2[l].place, $2.length - l)

				l -= 1
			}

			$$ = type
		}
	|
		primitive_type dim_exprs 
		{
			var type = new Type($1.type, $1.category, $1.width, $1.length, $1.dimension)

			var l = $2.length - 1
			while (l >= 0) {
				type = new Type(type, "array", 4, $2[l].place, $2.length - l)

				l -= 1
			}

			$$ = type
		}
	;


method_decr :
		method_declarator method_body 
		{
			var scope = ST.scope_end()

			var method = $1.method

			if (method.name == ST.current_class.name) {
				throw Error("A method cannot have the same name as the class")
			}

			if (scope.return_types.length == 0 && method.return_type.type != "null") {
				throw Error("A method with a defined return type must have a return statement")
			}
			else {
				for (var index in scope.return_types) {
					var return_type = scope.return_types[index]
					if (!(return_type.get_serial_type() == method.return_type.get_serial_type() || (method.return_type.numeric() && return_type.numeric()))) {
						throw Error("The return type '" + return_type.get_serial_type() + "' does not match with the method's return type '" + method.return_type.get_serial_type() + "'")
					}
					else if (return_type.category == "array" && return_type.get_size() != method.return_type.get_size()) {
						throw Error("Array dimensions do not match")
					}
				}
			}

			$$ = { code: [], place: null }

			if (method.name == "main") {
				$$.code.push(
					"function" + ir_sep + method.name
				)
			}
			else {
				$$.code.push(
					"function" + ir_sep + ST.current_class.name + "_" + method.name
				)
			}

			for (var index = method.parameters.length - 1; index >= 0; index--) {
				$$.code.push(
					"arg" + ir_sep + method.parameters[index].display_name + ir_sep + method.parameters[index].type.category + ir_sep + method.parameters[index].type.get_basic_type() + ir_sep + method.parameters[index].type.get_size()
				)
			}
			$$.code = $$.code.concat($2.code)

			if (method.return_type.type == "null") {
				$$.code.push("return")
			}
			else {
				$$.code.push(
					"error" + ir_sep + "function_return"
				)
			}
		}
	;


method_declarator :
		'public' 'void' 'identifier' 'paranthesis_start' formal_parameter_list 'paranthesis_end' 
		{
			$$ = {
				name: $identifier,
				scope: null,
				method: null
			}

			var scope = ST.scope_start(category = "function")
			var parameters = []

			if ($identifier != "main") {
				ST.variables_count += 1
				class_type = new Type(ST.current_class.name, "object", null, null, 0)
				scope.parameters["this"] = scope.add_variable("this", class_type, ST.variables_count, isparam = true)
				parameters.push(scope.parameters["this"])
			}

			for (var index in $5) {
				ST.variables_count += 1
				var variable = scope.add_variable($5[index].name, $5[index].type, ST.variables_count, isparam = true)
				scope.parameters[variable.name] = variable
				parameters.push(variable)
			}

			$$.method = ST.add_method($identifier, new Type("null", "basic", null, null, 0), parameters, scope)

			$$.scope = scope
		}
	|
		'public' type 'identifier' 'paranthesis_start' formal_parameter_list 'paranthesis_end' 
		{
			$$ = {
				name: $identifier,
				scope: null,
				method: null
			}

			var scope = ST.scope_start(category = "function")
			var parameters = []

			if ($identifier != "main") {
				ST.variables_count += 1
				class_type = new Type(ST.current_class.name, "object", null, null, 0)
				scope.parameters["this"] = scope.add_variable("this", class_type, ST.variables_count, isparam = true)
				parameters.push(scope.parameters["this"])
			}

			for (var index in $5) {
				ST.variables_count += 1
				var variable = scope.add_variable($5[index].name, $5[index].type, ST.variables_count, isparam = true)
				scope.parameters[variable.name] = variable
				parameters.push(variable)
			}

			$$.method = ST.add_method($identifier, $2, parameters, scope)

			$$.scope = scope
		}
	|
		'void' 'identifier' 'paranthesis_start' formal_parameter_list 'paranthesis_end' 
		{
			$$ = {
				name: $identifier,
				scope: null,
				method: null
			}

			var scope = ST.scope_start(category = "function")
			var parameters = []

			if ($identifier != "main") {
				ST.variables_count += 1
				class_type = new Type(ST.current_class.name, "object", null, null, 0)
				scope.parameters["this"] = scope.add_variable("this", class_type, ST.variables_count, isparam = true)
				parameters.push(scope.parameters["this"])
			}

			for (var index in $4) {
				ST.variables_count += 1
				var variable = scope.add_variable($4[index].name, $4[index].type, ST.variables_count, isparam = true)
				scope.parameters[variable.name] = variable
				parameters.push(variable)
			}

			$$.method = ST.add_method($identifier, new Type("null", "basic", null, null, 0), parameters, scope)
			
			$$.scope = scope
		}
	|
		type 'identifier' 'paranthesis_start' formal_parameter_list 'paranthesis_end' 
		{
			$$ = {
				name: $identifier,
				scope: null,
				method: null
			}

			var scope = ST.scope_start(category = "function")
			var parameters = []

			if ($identifier != "main") {
				ST.variables_count += 1
				class_type = new Type(ST.current_class.name, "object", null, null, 0)
				scope.parameters["this"] = scope.add_variable("this", class_type, ST.variables_count, isparam = true)
				parameters.push(scope.parameters["this"])
			}

			for (var index in $4) {
				ST.variables_count += 1
				var variable = scope.add_variable($4[index].name, $4[index].type, ST.variables_count, isparam = true)
				scope.parameters[variable.name] = variable
				parameters.push(variable)
			}

			$$.method = ST.add_method($identifier, $1, parameters, scope)

			$$.scope = scope
		}
	;


method_body :
		block 
		{
			$$ = $1
		}
	;


block :
		'set_start' block_scope_start block_stmts 'set_end' 
		{
			$$ = {
				code: [],
				scope: ST.scope_end()
			}

			$$.code.push(
				"label" + ir_sep + $$.scope.label_start
			)

			for (var index in $3) {
				$$.code = $$.code.concat($3[index].code)
			}

			$$.code.push(
				"label" + ir_sep + $$.scope.label_end
			)
		}
	|
		'set_start' block_scope_start 'set_end' 
		{
			$$ = {
				code: [],
				scope: ST.scope_end()
			}

			$$.code = $$.code.concat([
				"label" + ir_sep + $$.scope.label_start,
				"label" + ir_sep + $$.scope.label_end
			])
		}
	;

block_scope_start :

		{
			$$ = ST.scope_start()
		}
	;


block_stmts :
		block_stmts block_stmt 
		{
			$$ = $1
			$$.push($2)
		}
	|
		block_stmt 
		{
			$$ = [$1]
		}
	;


block_stmt :
		type var_declarators 'terminator' 
		{
			$$ = utils.assign({
				type: $1,
				var_declarators: $2
			})
		}
	|
		stmt 
		{
			$$ = $1
		}
	;


stmt :
		stmt_wots 
		{
			$$ = $1
		}
	|
		if_then_stmt 
		{
			$$ = $1
		}
	|
		if_then_else_stmt 
		{
			$$ = $1
		}
	|
		while_stmt 
		{
			$$ = $1
		}
	|
		for_stmt 
		{
			$$ = $1
		}
	;


stmt_nsi :
		stmt_wots 
		{
			$$ = $1
		}
	|
		if_then_else_stmt_nsi 
		{
			$$ = $1
		}
	|
		while_stmt_nsi 
		{
			$$ = $1
		}
	|
		for_stmt_nsi 
		{
			$$ = $1
		}
	;


stmt_wots :
		block 
		{
			$$ = $1
		}
	|
		break_stmt 
		{
			$$ = $1
		}
	|
		continue_stmt 
		{
			$$ = $1
		}
	|
		return_stmt 
		{
			$$ = $1
		}
	|
		stmt_expr 'terminator' 
		{
			$$ = $1
		}
	|
		'terminator' 
		{
			$$ = { code: [], place: null }
		}
	;


stmt_expr_list :
		stmt_expr_list 'separator' stmt_expr 
		{
			$$ = $1
			$$.push($3)
		}
	|
		stmt_expr 
		{
			$$ = [$1]
		}
	;


break_stmt :
		'break' 'terminator' 
		{
			$$ = { code: [], place: null }

			var scope = ST.current_scope

			while (scope instanceof ScopeTable) {
				if (scope.category == "while") {
					$$.code.push(
						"jump" + ir_sep + scope.label_end
					)
					break
				}
				else if (scope.category == "for_inner") {
					$$.code.push(
						"jump" + ir_sep + scope.parent.label_end
					)
					break
				}

				scope = scope.parent
			}
	
			if ($$.code.length == 0) {
				throw Error("Continue statement not inside a loop")
			}
		}
	;


continue_stmt :
		'continue' 'terminator' 
		{
			$$ = { code: [], place: null }

			var scope = ST.current_scope

			while (scope instanceof ScopeTable) {
				if (scope.category == "while") {
					$$.code.push(
						"jump" + ir_sep + scope.label_start
					)
					break
				}
				else if (scope.category == "for_inner") {
					$$.code.push(
						"jump" + ir_sep + scope.label_end
					)
					break
				}

				scope = scope.parent
			}
	
			if ($$.code.length == 0) {
				throw Error("Continue statement not inside a loop")
			}
		}
	;


return_stmt :
		'return' expr 'terminator' 
		{
			$$ = { code: $2.code, place: null }

			var scope = ST.current_scope
			while (!(scope.parent instanceof Class)) {
				scope = scope.parent
			}

			scope.return_types.push($2.type)

			$$.code.push(
				"return" + ir_sep + $2.place
			)
		}
	|
		'return' 'terminator' 
		{
			$$ = { code: ["return"], place: null }

			var scope = ST.current_scope
			while (!(scope.parent instanceof Class)) {
				scope = scope.parent
			}

			scope.return_type = new Type("null", "basic", null, null, 0)
		}
	;


if_then_stmt :
		'if' 'paranthesis_start' expr 'paranthesis_end' stmt 
		{
			$$ = { code: $3.code, place: null }

			var label_start;
			var label_end;
			if ($5.scope == null) {
				label_start = ST.create_label()
				label_end = ST.create_label()
			}
			else {
				label_start = $5.scope.label_start
				label_end = $5.scope.label_end
			}

			$$.code.push(
				"ifgoto" + ir_sep + "eq" + ir_sep + $3.place + ir_sep + "1" + ir_sep + label_start
			)

			$$.code.push(
				"jump" + ir_sep + label_end
			)

			if ($5.scope == null) {
				$$.code.push(
					"label" + ir_sep + label_start
				)
			}

			$$.code = $$.code.concat($5.code)

			if ($5.scope == null) {
				$$.code.push(
					"label" + ir_sep + label_end
				)
			}
		}
	;


if_then_else_stmt :
		'if' 'paranthesis_start' expr 'paranthesis_end' stmt_nsi 'else' stmt 
		{
			$$ = { code: $3.code, place: null }

			var label_start;
			var label_end;
			if ($5.scope == null) {
				label_start = ST.create_label()
				label_end = ST.create_label()
			}
			else {
				label_start = $5.scope.label_start
				label_end = $5.scope.label_end
			}

			$$.code.push(
				"ifgoto" + ir_sep + "eq" + ir_sep + $3.place + ir_sep + "1" + ir_sep + label_start
			)

			$$.code = $$.code.concat($7.code)

			$$.code.push(
				"jump" + ir_sep + label_end
			)

			if ($5.scope == null) {
				$$.code.push(
					"label" + ir_sep + label_start
				)
			}

			$$.code = $$.code.concat($5.code)

			if ($5.scope == null) {
				$$.code.push(
					"label" + ir_sep + label_end
				)
			}
		}
	;


if_then_else_stmt_nsi :
		'if' 'paranthesis_start' expr 'paranthesis_end' stmt_nsi 'else' stmt_nsi 
		{
			$$ = { code: $3.code, place: null }

			var label_start;
			var label_end;
			if ($5.scope == null) {
				label_start = ST.create_label()
				label_end = ST.create_label()
			}
			else {
				label_start = $5.scope.label_start
				label_end = $5.scope.label_end
			}

			$$.code.push(
				"ifgoto" + ir_sep + "eq" + ir_sep + $3.place + ir_sep + "1" + ir_sep + label_start
			)

			$$.code = $$.code.concat($7.code)

			$$.code.push(
				"jump" + ir_sep + label_end
			)

			if ($5.scope == null) {
				$$.code.push(
					"label" + ir_sep + label_start
				)
			}

			$$.code = $$.code.concat($5.code)

			if ($5.scope == null) {
				$$.code.push(
					"label" + ir_sep + label_end
				)
			}
		}
	;

while_stmt :
		while_scope_start 'while' 'paranthesis_start' expr 'paranthesis_end' stmt 
		{
			$$ = { code: [], place: null, scope: ST.scope_end() }
			
			$$.code.push(
				"label" + ir_sep + $$.scope.label_start
			)

			$$.code = $$.code.concat($4.code)

			$$.code.push(
				"ifgoto" + ir_sep + "eq" + ir_sep + $4.place + ir_sep + "0" + ir_sep + $$.scope.label_end
			)
			
			$$.code = $$.code.concat($6.code)

			$$.code = $$.code.concat([
				"jump" + ir_sep + $$.scope.label_start,
				"label" + ir_sep + $$.scope.label_end
			])
		}
	;


while_stmt_nsi :
		while_scope_start 'while' 'paranthesis_start' expr 'paranthesis_end' stmt_nsi 
		{
			$$ = { code: [], place: null, scope: ST.scope_end() }
			
			$$.code.push(
				"label" + ir_sep + $$.scope.label_start
			)

			$$.code = $$.code.concat($4.code)

			$$.code.push(
				"ifgoto" + ir_sep + "eq" + ir_sep + $4.place + ir_sep + "0" + ir_sep + $$.scope.label_end
			)
			
			$$.code = $$.code.concat($6.code)

			$$.code = $$.code.concat([
				"jump" + ir_sep + $$.scope.label_start,
				"label" + ir_sep + $$.scope.label_end
			])
		}
	;

while_scope_start :

		{
			$$ = ST.scope_start(category = "while")
		}
	;

for_stmt :
		for_scope_start 'for' 'paranthesis_start' for_init 'terminator' expr 'terminator' stmt_expr_list 'paranthesis_end' for_inner_scope_start stmt 
		{
			var inner_scope = ST.scope_end()

			$$ = { code: [], place: null, scope: ST.scope_end() }

			$$.code.push(
				"label" + ir_sep + $$.scope.label_start
			)

			$$.code = $$.code.concat($4.code)
			
			$$.code.push(
				"label" + ir_sep + inner_scope.label_start
			)

			$$.code = $$.code.concat($6.code)

			$$.code.push(
				"ifgoto" + ir_sep + "eq" + ir_sep + $6.place + ir_sep + "0" + ir_sep + $$.scope.label_end
			)
			
			$$.code = $$.code.concat($11.code)

			$$.code.push(
				"label" + ir_sep + inner_scope.label_end
			)

			for (var index in $8) {
				$$.code = $$.code.concat($8[index].code)
			}

			$$.code = $$.code.concat([
				"jump" + ir_sep + inner_scope.label_start,
				"label" + ir_sep + $$.scope.label_end
			])
		}
	|
		for_scope_start 'for' 'paranthesis_start' for_init 'terminator' expr 'terminator' 'paranthesis_end' for_inner_scope_start stmt 
		{
			var inner_scope = ST.scope_end()

			$$ = { code: [], place: null, scope: ST.scope_end() }

			$$.code.push(
				"label" + ir_sep + $$.scope.label_start
			)

			$$.code = $$.code.concat($4.code)
			
			$$.code.push(
				"label" + ir_sep + inner_scope.label_start
			)

			$$.code = $$.code.concat($6.code)

			$$.code.push(
				"ifgoto" + ir_sep + "eq" + ir_sep + $6.place + ir_sep + "0" + ir_sep + $$.scope.label_end
			)
			
			$$.code = $$.code.concat($10.code)

			$$.code.push(
				"label" + ir_sep + inner_scope.label_end
			)

			$$.code = $$.code.concat([
				"jump" + ir_sep + inner_scope.label_start,
				"label" + ir_sep + $$.scope.label_end
			])
		}
	|
		for_scope_start 'for' 'paranthesis_start' for_init 'terminator' 'terminator' stmt_expr_list 'paranthesis_end' for_inner_scope_start stmt 
		{
			var inner_scope = ST.scope_end()

			$$ = { code: [], place: null, scope: ST.scope_end() }

			$$.code.push(
				"label" + ir_sep + $$.scope.label_start
			)

			$$.code = $$.code.concat($4.code)
			
			$$.code.push(
				"label" + ir_sep + inner_scope.label_start
			)
			
			$$.code = $$.code.concat($10.code)

			$$.code.push(
				"label" + ir_sep + inner_scope.label_end
			)

			for (var index in $7) {
				$$.code = $$.code.concat($7[index].code)
			}

			$$.code = $$.code.concat([
				"jump" + ir_sep + inner_scope.label_start,
				"label" + ir_sep + $$.scope.label_end
			])
		}
	|
		for_scope_start 'for' 'paranthesis_start' for_init 'terminator' 'terminator' 'paranthesis_end' for_inner_scope_start stmt 
		{
			var inner_scope = ST.scope_end()

			$$ = { code: [], place: null, scope: ST.scope_end() }

			$$.code.push(
				"label" + ir_sep + $$.scope.label_start
			)

			$$.code = $$.code.concat($4.code)
			
			$$.code.push(
				"label" + ir_sep + inner_scope.label_start
			)

			$$.code = $$.code.concat($9.code)

			$$.code.push(
				"label" + ir_sep + inner_scope.label_end
			)

			$$.code = $$.code.concat([
				"jump" + ir_sep + inner_scope.label_start,
				"label" + ir_sep + $$.scope.label_end
			])
		}
	|
		for_scope_start 'for' 'paranthesis_start' 'terminator' expr 'terminator' stmt_expr_list 'paranthesis_end' for_inner_scope_start stmt 
		{
			var inner_scope = ST.scope_end()

			$$ = { code: [], place: null, scope: ST.scope_end() }

			$$.code.push(
				"label" + ir_sep + $$.scope.label_start
			)
			
			$$.code.push(
				"label" + ir_sep + inner_scope.label_start
			)

			$$.code = $$.code.concat($5.code)

			$$.code.push(
				"ifgoto" + ir_sep + "eq" + ir_sep + $5.place + ir_sep + "0" + ir_sep + $$.scope.label_end
			)
			
			$$.code = $$.code.concat($10.code)

			$$.code.push(
				"label" + ir_sep + inner_scope.label_end
			)

			for (var index in $7) {
				$$.code = $$.code.concat($7[index].code)
			}

			$$.code = $$.code.concat([
				"jump" + ir_sep + inner_scope.label_start,
				"label" + ir_sep + $$.scope.label_end
			])
		}
	|
		for_scope_start 'for' 'paranthesis_start' 'terminator' expr 'terminator' 'paranthesis_end' for_inner_scope_start stmt 
		{
			var inner_scope = ST.scope_end()

			$$ = { code: [], place: null, scope: ST.scope_end() }

			$$.code.push(
				"label" + ir_sep + $$.scope.label_start
			)
			
			$$.code.push(
				"label" + ir_sep + inner_scope.label_start
			)

			$$.code = $$.code.concat($5.code)

			$$.code.push(
				"ifgoto" + ir_sep + "eq" + ir_sep + $5.place + ir_sep + "0" + ir_sep + $$.scope.label_end
			)
			
			$$.code = $$.code.concat($9.code)

			$$.code.push(
				"label" + ir_sep + inner_scope.label_end
			)

			$$.code = $$.code.concat([
				"jump" + ir_sep + inner_scope.label_start,
				"label" + ir_sep + $$.scope.label_end
			])
		}
	|
		for_scope_start 'for' 'paranthesis_start' 'terminator' 'terminator' stmt_expr_list 'paranthesis_end' for_inner_scope_start stmt 
		{
			var inner_scope = ST.scope_end()

			$$ = { code: [], place: null, scope: ST.scope_end() }

			$$.code.push(
				"label" + ir_sep + $$.scope.label_start
			)
			
			$$.code.push(
				"label" + ir_sep + inner_scope.label_start
			)

			$$.code = $$.code.concat($9.code)

			$$.code.push(
				"label" + ir_sep + inner_scope.label_end
			)

			for (var index in $6) {
				$$.code = $$.code.concat($6[index].code)
			}

			$$.code = $$.code.concat([
				"jump" + ir_sep + inner_scope.label_start,
				"label" + ir_sep + $$.scope.label_end
			])
		}
	|
		for_scope_start 'for' 'paranthesis_start' 'terminator' 'terminator' 'paranthesis_end' for_inner_scope_start stmt 
		{
			var inner_scope = ST.scope_end()

			$$ = { code: [], place: null, scope: ST.scope_end() }

			$$.code.push(
				"label" + ir_sep + $$.scope.label_start
			)
			
			$$.code.push(
				"label" + ir_sep + inner_scope.label_start
			)

			$$.code = $$.code.concat($8.code)

			$$.code.push(
				"label" + ir_sep + inner_scope.label_end
			)

			$$.code = $$.code.concat([
				"jump" + ir_sep + inner_scope.label_start,
				"label" + ir_sep + $$.scope.label_end
			])
		}
	;


for_stmt_nsi :
		for_scope_start 'for' 'paranthesis_start' for_init 'terminator' expr 'terminator' stmt_expr_list 'paranthesis_end' for_inner_scope_start stmt_nsi
		{
			var inner_scope = ST.scope_end()

			$$ = { code: [], place: null, scope: ST.scope_end() }

			$$.code.push(
				"label" + ir_sep + $$.scope.label_start
			)

			$$.code = $$.code.concat($4.code)
			
			$$.code.push(
				"label" + ir_sep + inner_scope.label_start
			)

			$$.code = $$.code.concat($6.code)

			$$.code.push(
				"ifgoto" + ir_sep + "eq" + ir_sep + $6.place + ir_sep + "0" + ir_sep + $$.scope.label_end
			)
			
			$$.code = $$.code.concat($11.code)

			$$.code.push(
				"label" + ir_sep + inner_scope.label_end
			)

			for (var index in $8) {
				$$.code = $$.code.concat($8[index].code)
			}

			$$.code = $$.code.concat([
				"jump" + ir_sep + inner_scope.label_start,
				"label" + ir_sep + $$.scope.label_end
			])
		}
	|
		for_scope_start 'for' 'paranthesis_start' for_init 'terminator' expr 'terminator' 'paranthesis_end' for_inner_scope_start stmt_nsi
		{
			var inner_scope = ST.scope_end()

			$$ = { code: [], place: null, scope: ST.scope_end() }

			$$.code.push(
				"label" + ir_sep + $$.scope.label_start
			)

			$$.code = $$.code.concat($4.code)
			
			$$.code.push(
				"label" + ir_sep + inner_scope.label_start
			)

			$$.code = $$.code.concat($6.code)

			$$.code.push(
				"ifgoto" + ir_sep + "eq" + ir_sep + $6.place + ir_sep + "0" + ir_sep + $$.scope.label_end
			)
			
			$$.code = $$.code.concat($10.code)

			$$.code.push(
				"label" + ir_sep + inner_scope.label_end
			)

			$$.code = $$.code.concat([
				"jump" + ir_sep + inner_scope.label_start,
				"label" + ir_sep + $$.scope.label_end
			])
		}
	|
		for_scope_start 'for' 'paranthesis_start' for_init 'terminator' 'terminator' stmt_expr_list 'paranthesis_end' for_inner_scope_start stmt_nsi
		{
			var inner_scope = ST.scope_end()

			$$ = { code: [], place: null, scope: ST.scope_end() }

			$$.code.push(
				"label" + ir_sep + $$.scope.label_start
			)

			$$.code = $$.code.concat($4.code)
			
			$$.code.push(
				"label" + ir_sep + inner_scope.label_start
			)
			
			$$.code = $$.code.concat($10.code)

			$$.code.push(
				"label" + ir_sep + inner_scope.label_end
			)

			for (var index in $7) {
				$$.code = $$.code.concat($7[index].code)
			}

			$$.code = $$.code.concat([
				"jump" + ir_sep + inner_scope.label_start,
				"label" + ir_sep + $$.scope.label_end
			])
		}
	|
		for_scope_start 'for' 'paranthesis_start' for_init 'terminator' 'terminator' 'paranthesis_end' for_inner_scope_start stmt_nsi
		{
			var inner_scope = ST.scope_end()

			$$ = { code: [], place: null, scope: ST.scope_end() }

			$$.code.push(
				"label" + ir_sep + $$.scope.label_start
			)

			$$.code = $$.code.concat($4.code)
			
			$$.code.push(
				"label" + ir_sep + inner_scope.label_start
			)

			$$.code = $$.code.concat($9.code)

			$$.code.push(
				"label" + ir_sep + inner_scope.label_end
			)

			$$.code = $$.code.concat([
				"jump" + ir_sep + inner_scope.label_start,
				"label" + ir_sep + $$.scope.label_end
			])
		}
	|
		for_scope_start 'for' 'paranthesis_start' 'terminator' expr 'terminator' stmt_expr_list 'paranthesis_end' for_inner_scope_start stmt_nsi
		{
			var inner_scope = ST.scope_end()

			$$ = { code: [], place: null, scope: ST.scope_end() }

			$$.code.push(
				"label" + ir_sep + $$.scope.label_start
			)
			
			$$.code.push(
				"label" + ir_sep + inner_scope.label_start
			)

			$$.code = $$.code.concat($5.code)

			$$.code.push(
				"ifgoto" + ir_sep + "eq" + ir_sep + $5.place + ir_sep + "0" + ir_sep + $$.scope.label_end
			)
			
			$$.code = $$.code.concat($10.code)

			$$.code.push(
				"label" + ir_sep + inner_scope.label_end
			)

			for (var index in $7) {
				$$.code = $$.code.concat($7[index].code)
			}

			$$.code = $$.code.concat([
				"jump" + ir_sep + inner_scope.label_start,
				"label" + ir_sep + $$.scope.label_end
			])
		}
	|
		for_scope_start 'for' 'paranthesis_start' 'terminator' expr 'terminator' 'paranthesis_end' for_inner_scope_start stmt_nsi
		{
			var inner_scope = ST.scope_end()

			$$ = { code: [], place: null, scope: ST.scope_end() }

			$$.code.push(
				"label" + ir_sep + $$.scope.label_start
			)
			
			$$.code.push(
				"label" + ir_sep + inner_scope.label_start
			)

			$$.code = $$.code.concat($5.code)

			$$.code.push(
				"ifgoto" + ir_sep + "eq" + ir_sep + $5.place + ir_sep + "0" + ir_sep + $$.scope.label_end
			)
			
			$$.code = $$.code.concat($9.code)

			$$.code.push(
				"label" + ir_sep + inner_scope.label_end
			)

			$$.code = $$.code.concat([
				"jump" + ir_sep + inner_scope.label_start,
				"label" + ir_sep + $$.scope.label_end
			])
		}
	|
		for_scope_start 'for' 'paranthesis_start' 'terminator' 'terminator' stmt_expr_list 'paranthesis_end' for_inner_scope_start stmt_nsi
		{
			var inner_scope = ST.scope_end()

			$$ = { code: [], place: null, scope: ST.scope_end() }

			$$.code.push(
				"label" + ir_sep + $$.scope.label_start
			)
			
			$$.code.push(
				"label" + ir_sep + inner_scope.label_start
			)

			$$.code = $$.code.concat($9.code)

			$$.code.push(
				"label" + ir_sep + inner_scope.label_end
			)

			for (var index in $6) {
				$$.code = $$.code.concat($6[index].code)
			}

			$$.code = $$.code.concat([
				"jump" + ir_sep + inner_scope.label_start,
				"label" + ir_sep + $$.scope.label_end
			])
		}
	|
		for_scope_start 'for' 'paranthesis_start' 'terminator' 'terminator' 'paranthesis_end' for_inner_scope_start stmt_nsi
		{
			var inner_scope = ST.scope_end()

			$$ = { code: [], place: null, scope: ST.scope_end() }

			$$.code.push(
				"label" + ir_sep + $$.scope.label_start
			)
			
			$$.code.push(
				"label" + ir_sep + inner_scope.label_start
			)

			$$.code = $$.code.concat($8.code)

			$$.code.push(
				"label" + ir_sep + inner_scope.label_end
			)

			$$.code = $$.code.concat([
				"jump" + ir_sep + inner_scope.label_start,
				"label" + ir_sep + $$.scope.label_end
			])
		}
	;


for_init :
		stmt_expr_list 
		{
			$$ = { code: [], place: null }

			for (var index in $1) {
				$$.code = $$.code.concat($1[index].code)
			}
		}
	|
		type var_declarators 
		{
			$$ = utils.assign({
				type: $1,
				var_declarators: $2
			})
		}
	;


for_scope_start :

		{
			$$ = ST.scope_start(category = "for")
		}
	;


for_inner_scope_start :

		{
			$$ = ST.scope_start(category = "for_inner")
		}
	;


expr :
		cond_or_expr 
		{
			$$ = $1
		}
	|
		assignment 
		{
			$$ = $1
		}
	;


stmt_expr :
		assignment 
		{
			$$ = $1
		}
	|
		preinc_expr 
		{
			$$ = $1
		}
	|
		predec_expr 
		{
			$$ = $1
		}
	|
		post_expr 
		{
			$$ = $1
		}
	|
		method_invocation 
		{
			$$ = $1
		}
	|
		class_instance_creation_expr 
		{
			$$ = $1
		}
	;


assignment :
		left_hand_side assignment_operator expr 
		{
			$$ = { code: [], place: $1.place, type: $1.type }

			if (!($1.type.get_serial_type() == $3.type.get_serial_type() || ($1.type.numeric() && $3.type.numeric()))) {
				throw Error("Cannot convert '" + $3.type.get_serial_type() + "' to '" + $1.type.get_serial_type() + "'")
			}

			var place = $3.place

			$$.code = $3.code.concat($1.code)

			if ($1.type.category == "array" && $1.type.get_size() != $3.type.get_size()) {
				throw Error("Array dimensions do not match")
			}
			else if ($1.type.get_serial_type() != $3.type.get_serial_type()) {
				place = ST.create_temporary()

				$$.code = $$.code.concat([
					"decr" + ir_sep + place + ir_sep + $1.type.category + ir_sep + $1.type.get_basic_type() + ir_sep + $1.type.get_size(),
					"cast" + ir_sep + place + ir_sep + $3.type.get_serial_type() + ir_sep + $1.type.get_serial_type() + ir_sep + $3.place
				])
			}

			if ($1.field) {
				if ($2.third) {
					$$.code = $$.code.concat([
						$2.operator + ir_sep + $1.place + ir_sep + $1.place + ir_sep + place,
						"fieldset" + ir_sep + $1.field_class + ir_sep + $1.field_field + ir_sep + $1.place
					])
				}
				else {
					$$.code.push(
						"fieldset" + ir_sep + $1.field_class + ir_sep + $1.field_field + ir_sep + place
					)
				}
			}
			else {
				if ($2.third) {
					$$.code.push(
						$2.operator + ir_sep + $1.place + ir_sep + $1.place + ir_sep + place
					)
				}
				else {
					$$.code.push(
						$2.operator + ir_sep + $1.place + ir_sep + place
					)
				}
			}
		}
	|
		array_access assignment_operator expr
		{
			$$ = { code: [], place: null, type: $1.type }

			if (!($1.type.get_serial_type() == $3.type.get_serial_type() || ($1.type.numeric() && $3.type.numeric()))) {
				throw Error("Cannot convert '" + $3.type.get_serial_type() + "' to '" + $1.type.get_serial_type() + "'")
			}

			$$.code = $3.code.concat($1.code)

			var place = $3.place

			if ($1.type.get_serial_type() != $3.type.get_serial_type()) {
				place = ST.create_temporary()

				$$.code = $$.code.concat([
					"decr" + ir_sep + place + ir_sep + $1.type.category + ir_sep + $1.type.get_basic_type() + ir_sep + $1.type.get_size(),
					"cast" + ir_sep + place + ir_sep + $3.type.get_serial_type() + ir_sep + $1.type.get_serial_type() + ir_sep + $3.place
				])
			}

			if ($2.third) {
				var temp = ST.create_temporary()

				$$.code = $$.code.concat([
					"decr" + ir_sep + temp + ir_sep + $1.type.category + ir_sep + $1.type.get_basic_type() + ir_sep + $1.type.get_size(),
					"arrget" + ir_sep + temp + ir_sep + $1.place + ir_sep + $1.offset,
					$2.operator + ir_sep + temp + ir_sep + temp + ir_sep + place,
					"arrset" + ir_sep + $1.place + ir_sep + $1.offset + ir_sep + temp,
				])

				$$.place = temp
			}
			else {
				$$.code.push(
					"arrset" + ir_sep + $1.place + ir_sep + $1.offset + ir_sep + place,
				)
				
				$$.place = $3.place
			}
		}
	;


left_hand_side :
		expr_name 
		{
			$$ = $1

			if ($1.category == "method") {
				throw Error("A function cannot be used in assignment")
			}

			$$.field = false
			if ($$.code.length != 0) {
				var line = $$.code[$$.code.length - 1].split("\t")
				if (line[0] == "fieldget") {
					$$.field = true

					$$.field_class = line[2]
					$$.field_field = line[3]
				}
			}
		}
	|
		field_access 
		{
			$$ = $1
			
			var line = $$.code[$$.code.length - 1].split("\t")
			if (line[0] == "fieldget") {
				$$.field = true

				$$.field_class = line[2]
				$$.field_field = line[3]
			}
		}
	;


assignment_operator :
		'op_assign' 
		{
			$$ = { operator: "=", third: false }
		}
	|
		'op_mulAssign' 
		{
			$$ = { operator: "*", third: true }
		}
	|
		'op_divAssign' 
		{
			$$ = { operator: "/", third: true }
		}
	|
		'op_modAssign' 
		{
			$$ = { operator: "%", third: true }
		}
	|
		'op_addAssign' 
		{
			$$ = { operator: "+", third: true }
		}
	|
		'op_subAssign' 
		{
			$$ = { operator: "-", third: true }
		}
	|
		'op_andAssign' 
		{
			$$ = { operator: "&", third: true }
		}
	|
		'op_orAssign' 
		{
			$$ = { operator: "|", third: true }
		}
	|
		'op_xorAssign' 
		{
			$$ = { operator: "^", third: true }
		}
	;


cond_or_expr :
		cond_and_expr 
		{
			$$ = $1
		}
	|
		cond_or_expr 'op_oror' cond_and_expr 
		{
			var invalid = ["float"]
			if (invalid.indexOf($1.type.get_serial_type()) > -1 || invalid.indexOf($3.type.get_serial_type()) > -1) {
				throw Error("Bad operand types '" + $1.type.get_serial_type() + "' and '" + $3.type.get_serial_type() + "' on binary operator '||'")
			}

			$$ = utils.binary({
				op1: $1,
				op2: $3,
				operator: "||"
			})
		}
	;


cond_and_expr :
		incl_or_expr 
		{
			$$ = $1
		}
	|
		cond_and_expr 'op_andand' incl_or_expr 
		{
			var invalid = ["float"]
			if (invalid.indexOf($1.type.get_serial_type()) > -1 || invalid.indexOf($3.type.get_serial_type()) > -1) {
				throw Error("Bad operand types '" + $1.type.get_serial_type() + "' and '" + $3.type.get_serial_type() + "' on binary operator '&&'")
			}

			$$ = utils.binary({
				op1: $1,
				op2: $3,
				operator: "&&"
			})
		}
	;


incl_or_expr :
		excl_or_expr 
		{
			$$ = $1
		}
	|
		incl_or_expr 'op_or' excl_or_expr 
		{
			var invalid = ["float"]
			if (invalid.indexOf($1.type.get_serial_type()) > -1 || invalid.indexOf($3.type.get_serial_type()) > -1) {
				throw Error("Bad operand types '" + $1.type.get_serial_type() + "' and '" + $3.type.get_serial_type() + "' on binary operator '|'")
			}

			$$ = utils.binary({
				op1: $1,
				op2: $3,
				operator: "|"
			})
		}
	;


excl_or_expr :
		and_expr 
		{
			$$ = $1
		}
	|
		excl_or_expr 'op_xor' and_expr 
		{
			var invalid = ["float"]
			if (invalid.indexOf($1.type.get_serial_type()) > -1 || invalid.indexOf($3.type.get_serial_type()) > -1) {
				throw Error("Bad operand types '" + $1.type.get_serial_type() + "' and '" + $3.type.get_serial_type() + "' on binary operator '^'")
			}

			$$ = utils.binary({
				op1: $1,
				op2: $3,
				operator: "^"
			})
		}
	;


and_expr :
		equality_expr 
		{
			$$ = $1
		}
	|
		and_expr 'op_and' equality_expr 
		{
			var invalid = ["float"]
			if (invalid.indexOf($1.type.get_serial_type()) > -1 || invalid.indexOf($3.type.get_serial_type()) > -1) {
				throw Error("Bad operand types '" + $1.type.get_serial_type() + "' and '" + $3.type.get_serial_type() + "' on binary operator '&'")
			}

			$$ = utils.binary({
				op1: $1,
				op2: $3,
				operator: "&"
			})
		}
	;


equality_expr :
		relational_expr 
		{
			$$ = $1
		}
	|
		equality_expr 'op_equalCompare' relational_expr 
		{
			if ($1.type.category == "object" && $3.type.type == "null") {
				var temp = ST.create_temporary()
				var label = ST.create_label()

				$$ = { code: $1.code, place: null, type: null }

				$$.code = $$.code.concat([
					"decr" + ir_sep + temp + ir_sep + "basic" + ir_sep + "boolean" + ir_sep + "1",
					"=" + ir_sep + temp + ir_sep + "1",
					"ifgoto" + ir_sep + "eq" + ir_sep + $1.place + ir_sep + "0" + ir_sep + label,
					"=" + ir_sep + temp + ir_sep + "0",
					"label" + ir_sep + label
				])

				$$.place = temp
				$$.type = new Type("boolean", "basic", null, null, 0)
			}
			else if ($3.type.category == "object" && $1.type.type == "null") {
				var temp = ST.create_temporary()
				var label = ST.create_label()

				$$ = { code: $1.code, place: null, type: null }

				$$.code = $$.code.concat([
					"decr" + ir_sep + temp + ir_sep + "basic" + ir_sep + "boolean" + ir_sep + "1",
					"=" + ir_sep + temp + ir_sep + "1",
					"ifgoto" + ir_sep + "eq" + ir_sep + $3.place + ir_sep + "0" + ir_sep + label,
					"=" + ir_sep + temp + ir_sep + "0",
					"label" + ir_sep + label
				])

				$$.place = temp
				$$.type = new Type("boolean", "basic", null, null, 0)
			}
			else {
				if (!($1.type.get_serial_type() == "boolean" && $3.type.get_serial_type() == "boolean") && !($1.type.numeric() && $3.type.numeric())) {
					throw Error("Incomparable operand types '" + $1.type.get_serial_type() + "' and '" + $3.type.get_serial_type() + "' on binary operator '=='")
				}

				$$ = utils.relational({
					op1: $1,
					op2: $3,
					operator: "eq",
					operator_val: "=="
				})
			}
		}
	|
		equality_expr 'op_notequalCompare' relational_expr 
		{
			if ($1.type.category == "object" && $3.type.type == "null") {
				var temp = ST.create_temporary()
				var label = ST.create_label()

				$$ = { code: $1.code, place: null, type: null }

				$$.code = $$.code.concat([
					"decr" + ir_sep + temp + ir_sep + "basic" + ir_sep + "boolean" + ir_sep + "1",
					"=" + ir_sep + temp + ir_sep + "0",
					"ifgoto" + ir_sep + "eq" + ir_sep + $1.place + ir_sep + "0" + ir_sep + label,
					"=" + ir_sep + temp + ir_sep + "1",
					"label" + ir_sep + label
				])

				$$.place = temp
				$$.type = new Type("boolean", "basic", null, null, 0)
			}
			else if ($3.type.category == "object" && $1.type.type == "null") {
				var temp = ST.create_temporary()
				var label = ST.create_label()

				$$ = { code: $1.code, place: null, type: null }

				$$.code = $$.code.concat([
					"decr" + ir_sep + temp + ir_sep + "basic" + ir_sep + "boolean" + ir_sep + "1",
					"=" + ir_sep + temp + ir_sep + "0",
					"ifgoto" + ir_sep + "eq" + ir_sep + $3.place + ir_sep + "0" + ir_sep + label,
					"=" + ir_sep + temp + ir_sep + "1",
					"label" + ir_sep + label
				])

				$$.place = temp
				$$.type = new Type("boolean", "basic", null, null, 0)
			}
			else {
				if (!($1.type.get_serial_type() == "boolean" && $3.type.get_serial_type() == "boolean") && !($1.type.numeric() && $3.type.numeric())) {
					throw Error("Incomparable operand types '" + $1.type.get_serial_type() + "' and '" + $3.type.get_serial_type() + "' on binary operator '!='")
				}

				$$ = utils.relational({
					op1: $1,
					op2: $3,
					operator: "ne",
					operator_val: "!="
				})
			}
		}
	;


relational_expr :
		additive_expr 
		{
			$$ = $1
		}
	|
		relational_expr 'op_greater' additive_expr 
		{
			if (!$1.type.numeric() || !$3.type.numeric()) {
				throw Error("Incomparable operand types '" + $1.type.get_serial_type() + "' and '" + $3.type.get_serial_type() + "' on operator '>'")
			}

			$$ = utils.relational({
				op1: $1,
				op2: $3,
				operator: "gt",
				operator_val: ">"
			})
		}
	|
		relational_expr 'op_greaterEqual' additive_expr 
		{
			if (!$1.type.numeric() || !$3.type.numeric()) {
				throw Error("Incomparable operand types '" + $1.type.get_serial_type() + "' and '" + $3.type.get_serial_type() + "' on operator '>='")
			}

			$$ = utils.relational({
				op1: $1,
				op2: $3,
				operator: "ge",
				operator_val: ">="
			})
		}
	|
		relational_expr 'op_less' additive_expr 
		{
			if (!$1.type.numeric() || !$3.type.numeric()) {
				throw Error("Incomparable operand types '" + $1.type.get_serial_type() + "' and '" + $3.type.get_serial_type() + "' on operator '<'")
			}

			$$ = utils.relational({
				op1: $1,
				op2: $3,
				operator: "lt",
				operator_val: "<"
			})
		}
	|
		relational_expr 'op_lessEqual' additive_expr 
		{
			if (!$1.type.numeric() || !$3.type.numeric()) {
				throw Error("Incomparable operand types '" + $1.type.get_serial_type() + "' and '" + $3.type.get_serial_type() + "' on operator '<='")
			}

			$$ = utils.relational({
				op1: $1,
				op2: $3,
				operator: "le",
				operator_val: "<="
			})
		}
	|
		relational_expr 'instanceof' additive_expr 
		{
			$$ = { code: [], literal: true, place: null, type: new Type("boolean", "basic", 1, null, 0) }

			if ($1.type.get_serial_type() == $2.type.get_serial_type()) {
				$$.place = 1
			}
			else {
				$$.place = 0
			}
		}
	;


shift_expr :
		additive_expr 
		{
			$$ = $1
		}
	|
		shift_expr 'op_Lshift' additive_expr 
		{
			if (!$1.type.numeric() || !$3.type.numeric()) {
				throw Error("Bad operand types '" + $1.type.get_serial_type() + "' and '" + $3.type.get_serial_type() + "' on binary operator '<<'")
			}

			$$ = utils.binary({
				op1: $1,
				op2: $3,
				operator: "<<"
			})
		}
	|
		shift_expr 'op_Rshift' additive_expr 
		{
			if (!$1.type.numeric() || !$3.type.numeric()) {
				throw Error("Bad operand types '" + $1.type.get_serial_type() + "' and '" + $3.type.get_serial_type() + "' on binary operator '>>'")
			}

			$$ = utils.binary({
				op1: $1,
				op2: $3,
				operator: ">>"
			})
		}
	;


additive_expr :
		multiplicative_expr 
		{
			$$ = $1
		}
	|
		additive_expr 'op_add' multiplicative_expr 
		{
			if (!$1.type.numeric() || !$3.type.numeric()) {
				throw Error("Bad operand types '" + $1.type.get_serial_type() + "' and '" + $3.type.get_serial_type() + "' on binary operator '+'")
			}

			$$ = utils.binary({
				op1: $1,
				op2: $3,
				operator: "+"
			})
		}
	|
		additive_expr 'op_sub' multiplicative_expr 
		{
			if (!$1.type.numeric() || !$3.type.numeric()) {
				throw Error("Bad operand types '" + $1.type.get_serial_type() + "' and '" + $3.type.get_serial_type() + "' on binary operator '-'")
			}

			$$ = utils.binary({
				op1: $1,
				op2: $3,
				operator: "-"
			})
		}
	;


multiplicative_expr :
		unary_expr 
		{
			$$ = $1
		}
	|
		multiplicative_expr 'op_mul' unary_expr 
		{
			if (!$1.type.numeric() || !$3.type.numeric()) {
				throw Error("Bad operand types '" + $1.type.get_serial_type() + "' and '" + $3.type.get_serial_type() + "' on binary operator '*'")
			}

			$$ = utils.binary({
				op1: $1,
				op2: $3,
				operator: "*"
			})
		}
	|
		multiplicative_expr 'op_div' unary_expr 
		{
			if (!$1.type.numeric() || !$3.type.numeric()) {
				throw Error("Bad operand types '" + $1.type.get_serial_type() + "' and '" + $3.type.get_serial_type() + "' on binary operator '/'")
			}

			$$ = utils.binary({
				op1: $1,
				op2: $3,
				operator: "/"
			})
		}
	|
		multiplicative_expr 'op_mod' unary_expr 
		{
			if (!$1.type.numeric() || !$3.type.numeric() || $3.type.get_serial_type() == "float") {
				throw Error("Bad operand types '" + $1.type.get_serial_type() + "' and '" + $3.type.get_serial_type() + "' on binary operator '%'")
			}

			$$ = utils.binary({
				op1: $1,
				op2: $3,
				operator: "%"
			})
		}
	;


predec_expr :
		'op_decrement' unary_expr 
		{
			$$ = $2

			if ($2.literal && !isNaN($2.place)) {
				throw Error("Cannot apply decrement on constant")
			}

			if (!$$.type.numeric()) {
				throw Error("Bad operand type '" + $$.type.get_serial_type() + "' on unary operator '++'")
			}

			$$.code.push(
				"dec" + ir_sep + $$.place
			)

			if ($$.code.length >= 2) {
				var line = $$.code[$$.code.length - 2].split("\t")
				if (line[0] == "fieldget") {
					$$.field = true

					$$.field_class = line[2]
					$$.field_field = line[3]

					$$.code.push(
						"fieldset" + ir_sep + $$.field_class + ir_sep + $$.field_field + ir_sep + $$.place
					)
				}
			}
		}
	;


preinc_expr :
		'op_increment' unary_expr 
		{
			$$ = $2

			if ($2.literal && !isNaN($2.place)) {
				throw Error("Cannot apply increment on constant")
			}

			if (!$$.type.numeric()) {
				throw Error("Bad operand type '" + $$.type.get_serial_type() + "' on unary operator '++'")
			}

			$$.code.push(
				"inc" + ir_sep + $$.place
			)

			if ($$.code.length >= 2) {
				var line = $$.code[$$.code.length - 2].split("\t")
				if (line[0] == "fieldget") {
					$$.field = true

					$$.field_class = line[2]
					$$.field_field = line[3]

					$$.code.push(
						"fieldset" + ir_sep + $$.field_class + ir_sep + $$.field_field + ir_sep + $$.place
					)
				}
			}
		}
	;


unary_expr :
		preinc_expr 
		{
			$$ = $1
		}
	|
		predec_expr 
		{
			$$ = $1
		}
	|
		sign unary_expr 
		{
			if ($1 == "+") {
				$$ = $2
			}
			else {
				$$ = $2
				
				if (!$$.type.numeric()) {
					throw Error("Bad operand type '" + $$.type.get_serial_type() + "' on unary operator '-'")
				}

				var temp = ST.create_temporary()
				$$.code = $$.code.concat([
					"decr" + ir_sep + temp + ir_sep + $2.type.category + ir_sep + $2.type.get_basic_type() + ir_sep + $2.type.get_size(),
					"=" + ir_sep + temp + ir_sep + $$.place,
					"neg" + ir_sep + temp
				])

				$$.place = temp
			}
		}
	|
		unary_expr_npm 
		{
			$$ = $1
		}
	;


unary_expr_npm :
		postfix_expr 
		{
			$$ = $1
		}
	|
		post_expr 
		{
			$$ = $1
		}
	|
		'op_not' unary_expr 
		{
			$$ = $2
			
			if ($$.type.get_serial_type() != "boolean") {
				throw Error("Bad operand type '" + $$.type.get_serial_type() + "' on unary operator '!'")
			}

			var temp = ST.create_temporary()
			$$.code = $$.code.concat([
				"decr" + ir_sep + temp + ir_sep + $2.type.category + ir_sep + $2.type.get_basic_type() + ir_sep + $2.type.get_size(),
				"=" + ir_sep + temp + ir_sep + $$.place,
				"not" + ir_sep + temp
			])

			$$.place = temp
		}
	|
		cast_expr 
		{
			$$ = $1
		}
	;


cast_expr :
		'paranthesis_start' primitive_type 'paranthesis_end' unary_expr 
		{
			$$ = { 
				code: $4.code,
				type: new Type($2.type, "basic", $2.width, $2.length, 0),
				place: null
			}

			if (!($4.type.category == "basic" && ($4.type.type == $2.type || ($4.type.numeric() && $$.type.numeric())))) {
				throw Error("Cannot convert '" + $4.type.get_serial_type() + "' to '" + $2.type + "'")
			}

			temp = ST.create_temporary()

			$$.code = $$.code.concat([
				"decr" + ir_sep + temp + ir_sep + "basic" + ir_sep + $2.type + ir_sep + "1",
				"cast" + ir_sep + temp + ir_sep + $4.type.type + ir_sep + $2.type + ir_sep + $4.place
			])

			$$.place = temp
		}
	;


postdec_expr :
		postfix_expr 'op_decrement' 
		{
			$$ = $1

			if (!$$.type.numeric()) {
				throw Error("Bad operand type '" + $$.type.get_serial_type() + "' on unary operator '++'")
			}

			var temp = ST.create_temporary()

			$$.code = $$.code.concat([
				"decr" + ir_sep + temp + ir_sep + $$.type.category + ir_sep + $$.type.get_basic_type() + ir_sep + $$.type.get_size(),
				"=" + ir_sep + temp + ir_sep + $$.place,
				"dec" + ir_sep + $$.place
			])

			if ($$.code.length >= 4) {
				var line = $$.code[$$.code.length - 4].split("\t")
				if (line[0] == "fieldget") {
					$$.field = true

					$$.field_class = line[2]
					$$.field_field = line[3]

					$$.code.push(
						"fieldset" + ir_sep + $$.field_class + ir_sep + $$.field_field + ir_sep + $$.place
					)
				}
			}

			$$.place = temp
		}
	|
		post_expr 'op_decrement' 
		{
			$$ = $1

			if (!$$.type.numeric()) {
				throw Error("Bad operand type '" + $$.type.get_serial_type() + "' on unary operator '++'")
			}

			var temp = ST.create_temporary()

			$$.code = $$.code.concat([
				"decr" + ir_sep + temp + ir_sep + $$.type.category + ir_sep + $$.type.get_basic_type() + ir_sep + $$.type.get_size(),
				"=" + ir_sep + temp + ir_sep + $$.place,
				"dec" + ir_sep + $$.place
			])

			if ($$.code.length >= 4) {
				var line = $$.code[$$.code.length - 4].split("\t")
				if (line[0] == "fieldget") {
					$$.field = true

					$$.field_class = line[2]
					$$.field_field = line[3]

					$$.code.push(
						"fieldset" + ir_sep + $$.field_class + ir_sep + $$.field_field + ir_sep + $$.place
					)
				}
			}

			$$.place = temp
		}
	;


postinc_expr :
		postfix_expr 'op_increment' 
		{
			$$ = $1

			if ($$.literal && !isNaN($$.place)) {
				throw Error("Cannot apply decrement on constant")
			}

			if (!$$.type.numeric()) {
				throw Error("Bad operand type '" + $$.type.get_serial_type() + "' on unary operator '++'")
			}

			var temp = ST.create_temporary()

			$$.code = $$.code.concat([
				"decr" + ir_sep + temp + ir_sep + $$.type.category + ir_sep + $$.type.get_basic_type() + ir_sep + $$.type.get_size(),
				"=" + ir_sep + temp + ir_sep + $$.place,
				"inc" + ir_sep + $$.place
			])

			if ($$.code.length >= 4) {
				var line = $$.code[$$.code.length - 4].split("\t")
				if (line[0] == "fieldget") {
					$$.field = true

					$$.field_class = line[2]
					$$.field_field = line[3]

					$$.code.push(
						"fieldset" + ir_sep + $$.field_class + ir_sep + $$.field_field + ir_sep + $$.place
					)
				}
			}

			$$.place = temp
		}
	|
		post_expr 'op_increment' 
		{
			$$ = $1

			if ($$.literal && !isNaN($$.place)) {
				throw Error("Cannot apply increment on constant")
			}

			if (!$$.type.numeric()) {
				throw Error("Bad operand type '" + $$.type.get_serial_type() + "' on unary operator '++'")
			}

			var temp = ST.create_temporary()

			$$.code = $$.code.concat([
				"decr" + ir_sep + temp + ir_sep + $$.type.category + ir_sep + $$.type.get_basic_type() + ir_sep + $$.type.get_size(),
				"=" + ir_sep + temp + ir_sep + $$.place,
				"inc" + ir_sep + $$.place
			])

			if ($$.code.length >= 4) {
				var line = $$.code[$$.code.length - 4].split("\t")
				if (line[0] == "fieldget") {
					$$.field = true

					$$.field_class = line[2]
					$$.field_field = line[3]

					$$.code.push(
						"fieldset" + ir_sep + $$.field_class + ir_sep + $$.field_field + ir_sep + $$.place
					)
				}
			}

			$$.place = temp
		}
	;


post_expr :
		postinc_expr 
		{
			$$ = $1
		}
	|
		postdec_expr 
		{
			$$ = $1
		}
	;


postfix_expr :
		primary 
		{
			$$ = $1
		}
	|
		expr_name 
		{
			$$ = $1
		}
	;


method_invocation :
		expr_name 'paranthesis_start' argument_list 'paranthesis_end' 
		{
			$$ = { code: [], place: null, type: null }

			if ($1.category != "method") {
				throw Error("Type '" + $1.type.get_serial_type() + "' is not callable")
			}

			var method = $1.method

			$3.unshift({
				type: $1.place.type,
				place: $1.place.place,
				code: $1.code
			})

			if ($3.length != method.num_parameters) {
				throw Error("The method " + method.name + " requires " + (method.num_parameters - 1) + " parameters, provided " + ($3.length - 1))
			}

			for (var index in $3) {
				if (!($3[index].type.get_serial_type() == method.parameters[index].type.get_serial_type() || ($3[index].type.numeric() && method.parameters[index].type.numeric()))) {
					throw Error("Argument must be of type " + method.parameters[index].type.get_serial_type())
				}
				if ($3[index].type.category == "array" && $3[index].type.get_size() != method.parameters[index].type.get_size()) {
					throw Error("Array dimensions do not match")
				}

				if ($3[index].type.get_serial_type() != method.parameters[index].type.get_serial_type()) {
					var t = ST.create_temporary()

					$3[index].code = $3[index].code.concat([
						"decr" + ir_sep + t + ir_sep + method.parameters[index].type.category + ir_sep + method.parameters[index].type.get_basic_type() + ir_sep + method.parameters[index].type.get_size(),
						"cast" + ir_sep + t + ir_sep + $3[index].type.get_basic_type() + ir_sep + method.parameters[index].type.get_basic_type() + ir_sep + $3[index].place
					])

					$3[index].place = t
				}

				$$.code = $$.code.concat($3[index].code)
			}

			var temp

			if (method.return_type.type != "null") {
				temp = ST.create_temporary()

				$$.code.push(
					"decr" + ir_sep + temp + ir_sep + method.return_type.category + ir_sep + method.return_type.get_basic_type() + ir_sep + method.return_type.get_size()
				)

				$$.place = temp
			}

			for (var index in $3) {
				$$.code.push(
					"param" + ir_sep + $3[index].place
				)
			}

			if (method.return_type.type != "null") {
				$$.code.push(
					"call" + ir_sep + $1.place.type.type + "_" + method.name + ir_sep + method.num_parameters + ir_sep + temp
				)
			}
			else {
				$$.code.push(
					"call" + ir_sep + $1.place.type.type + "_" + method.name + ir_sep + method.num_parameters
				)
			}

			$$.type = method.return_type
		}
	|
		expr_name 'paranthesis_start' 'paranthesis_end' 
		{
			$$ = { code: $1.code, place: null, type: null }

			if ($1.category != "method") {
				throw Error("Type '" + $1.type.get_serial_type() + "' is not callable")
			}

			var method = $1.method

			if (method.num_parameters > 1) {
				throw Error("The method " + method.name + " requires " + (method.num_parameters - 1) + ", provided 0")
			}

			var temp

			if (method.return_type.type != "null") {
				temp = ST.create_temporary()

				$$.code.push(
					"decr" + ir_sep + temp + ir_sep + method.return_type.category + ir_sep + method.return_type.get_basic_type() + ir_sep + method.return_type.get_size()
				)

				$$.place = temp
			}

			$$.code.push(
				"param" + ir_sep + $1.place.place
			)

			if (method.return_type.type != "null") {
				$$.code.push(
					"call" + ir_sep + $1.place.type.type + "_" + method.name + ir_sep + method.num_parameters + ir_sep + temp
				)
			}
			else {
				$$.code.push(
					"call" + ir_sep + $1.place.type.type + "_" + method.name + ir_sep + method.num_parameters
				)
			}

			$$.type = method.return_type
		}
	|
		primary 'field_invoker' 'identifier' 'paranthesis_start' argument_list 'paranthesis_end' 
		{
			$$ = { code: [], type: null, place: null }

			if ($1.type.category != "object") {
				throw Error("Type '" + $1.type.get_serial_type() + "' does not have the property " + $identifier)
			}

			var method = ST.lookup_method($identifier, true, ST.classes[$1.type.type])
			var type = method.return_type

			$5.unshift({
				type: $1.type,
				place: $1.place,
				code: $1.code
			})

			if ($5.length != method.num_parameters) {
				throw Error("The method " + method.name + " requires " + (method.num_parameters - 1) + " parameters, provided " + ($5.length - 1))
			}

			for (var index in $5) {
				if (!($5[index].type.get_serial_type() == method.parameters[index].type.get_serial_type() || ($5[index].type.numeric() && method.parameters[index].type.numeric()))) {
					throw Error("Argument must be of type " + method.parameters[index].type.get_serial_type())
				}
				if ($5[index].type.category == "array" && $5[index].type.get_size() != method.parameters[index].type.get_size()) {
					throw Error("Array dimensions do not match")
				}

				if ($5[index].type.get_serial_type() != method.parameters[index].type.get_serial_type()) {
					var t = ST.create_temporary()

					$5[index].code = $5[index].code.concat([
						"decr" + ir_sep + t + ir_sep + method.parameters[index].type.category + ir_sep + method.parameters[index].type.get_basic_type() + ir_sep + method.parameters[index].type.get_size(),
						"cast" + ir_sep + t + ir_sep + $5[index].type.get_basic_type() + ir_sep + method.parameters[index].type.get_basic_type() + ir_sep + $5[index].place
					])

					$5[index].place = t
				}

				$$.code = $$.code.concat($5[index].code)
			}

			var temp

			if (method.return_type.type != "null") {
				temp = ST.create_temporary()

				$$.code.push(
					"decr" + ir_sep + temp + ir_sep + method.return_type.category + ir_sep + method.return_type.get_basic_type() + ir_sep + method.return_type.get_size()
				)

				$$.place = temp
			}

			for (var index in $5) {
				$$.code.push(
					"param" + ir_sep + $5[index].place
				)
			}

			if (method.return_type.type != "null") {
				$$.code.push(
					"call" + ir_sep + $1.type.type + "_" + method.name + ir_sep + method.num_parameters + ir_sep + temp
				)
			}
			else {
				$$.code.push(
					"call" + ir_sep + $1.type.type + "_" + method.name + ir_sep + method.num_parameters
				)
			}

			$$.type = method.return_type
		}
	|
		primary 'field_invoker' 'identifier' 'paranthesis_start' 'paranthesis_end' 
		{
			$$ = { code: $1.code, type: null, place: null }

			if ($1.type.category != "object") {
				throw Error("Type '" + $1.type.get_serial_type() + "' does not have the property " + $identifier)
			}

			var method = ST.lookup_method($identifier, true, ST.classes[$1.type.type])
			var type = method.return_type

			if (method.num_parameters > 1) {
				throw Error("The method " + method.name + " requires " + (method.num_parameters - 1) + ", provided 0")
			}
			
			var temp;
			
			if (method.return_type.type != "null") {
				temp = ST.create_temporary()

				$$.code.push(
					"decr" + ir_sep + temp + ir_sep + method.return_type.category + ir_sep + method.return_type.get_basic_type() + ir_sep + method.return_type.get_size()
				)

				$$.place = temp
			}

			$$.code.push(
				"param" + ir_sep + $1.place
			)

			if (method.return_type.type != "null") {
				$$.code.push(
					"call" + ir_sep + $1.type.type + "_" + method.name + ir_sep + method.num_parameters + ir_sep + temp
				)
			}
			else {
				$$.code.push(
					"call" + ir_sep + $1.type.type + "_" + method.name + ir_sep + method.num_parameters
				)
			}

			$$.type = method.return_type
		}
	;


field_access :
		primary 'field_invoker' 'identifier' 
		{
			$$ = { code: $1.code, type: null, place: null }

			if ($1.type.category != "object") {
				throw Error("Type '" + $1.type.get_serial_type() + "' does not have the property " + $identifier)
			}

			var variable = ST.lookup_variable($identifier, true, ST.classes[$1.type.type])
			var temp = ST.create_temporary()
			var type = variable.type

			$$.code = $$.code.concat([
				"decr" + ir_sep + temp + ir_sep + type.category + ir_sep + type.get_basic_type() + ir_sep + type.get_size(),
				"fieldget" + ir_sep + temp + ir_sep + $1.place + ir_sep + variable.display_name
			])

			$$.type = type
			$$.place = temp
		}
	;


array_access :
		expr_name 'colon' dim_exprs 
		{
			$$ = { code: $1.code, place: null, offset: null, type: null }

			var temp = ST.create_temporary()

			var array = $1.variable
			var type = array.type

			$$.code = $$.code.concat([
				"decr" + ir_sep + temp + ir_sep + "basic" + ir_sep + "int" + ir_sep + "1",
				"=" + ir_sep + temp + ir_sep + "0"
			])

			var first = true

			for (var index in $3) {
				var dim = $3[index]

				if (dim.type.category != "basic" && dim.type.type != "int") {
					throw Error("Array indices can only be of type (int)")
				}
				if (type.category != "array") {
					throw Error("Array dimensions do not match")
				}
				
				$$.code = $$.code.concat(dim.code)

				if (!isNaN(dim.place)) {
					var dim_val = parseInt(dim.place)

					if (dim_val >= type.length) {
						throw Error("Array index exceeds dimension size")
					}
				}
				else {
					var label = ST.create_label()
				
					$$.code = $$.code.concat([
						"ifgoto" + ir_sep + "ge" + ir_sep + dim.place + ir_sep + "0" + ir_sep + label,
						"error" + ir_sep + "array_access_low",
						"label" + ir_sep + label
					])

					label = ST.create_label()
				
					$$.code = $$.code.concat([
						"ifgoto" + ir_sep + "lt" + ir_sep + dim.place + ir_sep + type.length + ir_sep + label,
						"error" + ir_sep + "array_access_up",
						"label" + ir_sep + label
					])
				}

				if (first) {
					$$.code.push(
						"+" + ir_sep + temp + ir_sep + temp + ir_sep + dim.place
					)
					first = false
				}
				else {
					$$.code = $$.code.concat([
						"*" + ir_sep + temp + ir_sep + temp + ir_sep + type.length,
						"+" + ir_sep + temp + ir_sep + temp + ir_sep + dim.place
					])
				}

				type = type.type
			}

			if (type.category == "array") {
				throw Error("Array dimensions do not match")
			}

			$$.place = $1.place
			$$.offset = temp
			$$.type = type
		}
	;


primary :
		literal 
		{
			$$ = $1
		}
	|
		'paranthesis_start' expr 'paranthesis_end' 
		{
			$$ = $2
		}
	|
		class_instance_creation_expr 
		{
			$$ = $1
		}
	|
		field_access 
		{
			$$ = $1
		}
	|
		array_access 
		{
			$$ = { code: $1.code, place: null, type: null }

			$$.place = ST.create_temporary()

			$$.code = $$.code.concat([
				"decr" + ir_sep + $$.place + ir_sep + $1.type.category + ir_sep + $1.type.get_basic_type() + ir_sep + $1.type.get_size(),
				"arrget" + ir_sep + $$.place + ir_sep + $1.place + ir_sep + $1.offset
			])

			$$.type = $1.type
		}
	|
		method_invocation 
		{
			$$ = $1
		}
	;


class_instance_creation_expr :
		'new' 'identifier' 'paranthesis_start' argument_list 'paranthesis_end' 
		{
			$$ = { code: [], place: null, type: null }

			//if ($identifier == ST.current_class) {
			//	throw Error("Class '" + $identifier + "' has not beed declared")
			//}

			var new_class = ST.lookup_class($identifier)

			var class_temp = ST.create_temporary()
			var class_type = new Type(new_class.name, "basic", null, null, 0)

			$$.code = $$.code.concat([
				"decr" + ir_sep + class_temp + ir_sep + "object" + ir_sep + class_type.type + ir_sep + "1",
				"new" + ir_sep + class_temp + ir_sep + class_type.type
			])

			$4.unshift({
				type: class_type,
				place: class_temp,
				code: []
			})

			var method = new_class.constructor

			if ($4.length != method.num_parameters) {
				throw Error("The method " + method.name + " requires " + (method.num_parameters - 1) + " parameters, provided " + ($4.length - 1))
			}

			for (var index in $4) {
				if (!($4[index].type.get_serial_type() == method.parameters[index].type.get_serial_type() || ($4[index].type.numeric() && method.parameters[index].type.numeric()))) {
					throw Error("Argument must be of type " + method.parameters[index].type.get_serial_type())
				}
				if ($4[index].type.category == "array" && $4[index].type.get_size() != method.parameters[index].type.get_size()) {
					throw Error("Array dimensions do not match")
				}

				if ($4[index].type.get_serial_type() != method.parameters[index].type.get_serial_type()) {
					var t = ST.create_temporary()

					$4[index].code = $4[index].code.concat([
						"decr" + ir_sep + t + ir_sep + method.parameters[index].type.category + ir_sep + method.parameters[index].type.get_basic_type() + ir_sep + method.parameters[index].type.get_size(),
						"cast" + ir_sep + t + ir_sep + $4[index].type.get_basic_type() + ir_sep + method.parameters[index].type.get_basic_type() + ir_sep + $4[index].place
					])

					$4[index].place = t
				}

				$$.code = $$.code.concat($4[index].code)
			}
			for (var index in $4) {
				$$.code.push(
					"param" + ir_sep + $4[index].place
				)
			}

			$$.code.push(
				"call" + ir_sep + new_class.name + "_" + new_class.name + ir_sep + method.num_parameters
			)

			$$.place = class_temp
			
			$$.type = class_type
		}
	|
		'new' 'identifier' 'paranthesis_start' 'paranthesis_end' 
		{
			
			$$ = { code: [], place: null, type: null }

			//if ($identifier == ST.current_class) {
			//	throw Error("Class '" + $identifier + "' has not beed declared")
			//}

			var new_class = ST.lookup_class($identifier)

			var class_temp = ST.create_temporary()
			var class_type = new Type(new_class.name, "basic", null, null, 0)

			$$.code = $$.code.concat([
				"decr" + ir_sep + class_temp + ir_sep + "object" + ir_sep + class_type.type + ir_sep + "1",
				"new" + ir_sep + class_temp + ir_sep + class_type.type
			])

			var parameters = []

			parameters.unshift({
				type: class_type,
				place: class_temp,
				code: []
			})

			var method = new_class.constructor

			if (parameters.length != method.num_parameters) {
				throw Error("The method " + method.name + " requires " + (method.num_parameters - 1) + " parameters, provided " + (parameters.length - 1))
			}

			for (var index in parameters) {
				$$.code = $$.code.concat(parameters[index].code)

				if (!(parameters[index].type.get_serial_type() == method.parameters[index].type.get_serial_type() || (parameters[index].type.numeric() && method.parameters[index].type.numeric()))) {
					throw Error("Argument must be of type " + method.parameters[index].type.get_serial_type())
				}
				if (parameters[index].type.category == "array" && parameters[index].type.get_size() != method.parameters[index].type.get_size()) {
					throw Error("Array dimensions do not match")
				}
			}
			for (var index in parameters) {
				$$.code.push(
					"param" + ir_sep + parameters[index].place
				)
			}

			$$.code.push(
				"call" + ir_sep + new_class.name + "_" + new_class.name + ir_sep + method.num_parameters
			)

			$$.place = class_temp
			
			$$.type = class_type
		}
	;


argument_list :
		expr 
		{
			$$ = [$1]
		}
	|
		argument_list 'separator' expr 
		{
			$$ = $1
			$$.push($3)
		}
	;


dim_exprs :
		dim_exprs dim_expr 
		{
			$$ = $1
			$$.push($2)
		}
	|
		dim_expr 
		{
			$$ = [$1]
		}
	;


dim_expr :
		'brackets_start' expr 'brackets_end' 
		{
			$$ = $2
			
			if ($2.type.get_serial_type() != "int") {
				throw Error("Array dimension should be of int type")
			}
		}
	;


expr_name :
		'identifier' 
		{
			var variable = ST.lookup_variable($identifier, false)
			var method = ST.lookup_method($identifier, false)

			$$ = {
				code: [],
				place: null,
				method: null,
				variable: null,
				type: null,
				category: null
			}

			if (variable) {
				var type = variable.type
				var place = variable.display_name

				if (variable.isfield) {
					place = ST.create_temporary()
					
					$$.code = $$.code.concat([
						"decr" + ir_sep + place + ir_sep + type.category + ir_sep + type.get_basic_type() + ir_sep + type.get_size(),
						"fieldget" + ir_sep + place + ir_sep + "this" + ir_sep + variable.display_name
					])
				}

				$$.field = true
				$$.type = type
				$$.place = place
				$$.variable = variable
				$$.category = "variable"
			}
			else if (method) {
				var self = ST.lookup_variable("this")

				$$.place = {
					place: self.display_name,
					type: self.type
				}

				$$.method = method
				$$.category = "method"
				$$.type = new Type("method", "method", null, null, null)
			}
			else {
				throw Error("No variable or method '" + $identifier + "' found")
			}

			
		}
	|
		expr_name 'field_invoker' 'identifier' 
		{
			$$ = {
				code: $1.code,
				place: null,
				method: null,
				variable: null,
				type: null,
				category: null
			}

			if ($1.category != "variable") {
				throw Error("Function does not have fields to invoke")
			}
			if ($1.type.category != "object") {
				throw Error("Type '" + $1.type.get_serial_type() + "' does not have fields to invoke")
			}
			
			var variable = ST.lookup_variable($identifier, false, ST.classes[$1.type.type])
			var method = ST.lookup_method($identifier, false, ST.classes[$1.type.type])

			if (variable) {
				var type = variable.type
				var temp = ST.create_temporary()

				$$.code = $$.code.concat([
					"decr" + ir_sep + temp + ir_sep + type.category + ir_sep + type.get_basic_type() + ir_sep + type.get_size(),
					"fieldget" + ir_sep + temp + ir_sep + $1.place + ir_sep + variable.display_name
				])

				$$.place = temp
				$$.variable = variable
				$$.type = type
				$$.category = "variable"
				$$.field = true
			}
			else if (method) {
				$$.place = $1
				$$.method = method
				$$.category = "method"
				$$.type = new Type("method", "method", null, null, null)
			}
			else {
				throw Error("Type '" + $1.type.type + "' does not have the property '" + $identifier + "'")
			}
		}
	;


literal :
		'integer_literal' 
		{
			$$ = {
				code: [],
				place: $integer_literal,
				literal: true,
				type: new Type("int", "basic", 4, null, 0)
			}
		}
	|
		'float_literal' 
		{
			$$ = {
				code: [],
				place: $float_literal,
				literal: true,
				type: new Type("float", "basic", 4, null, 0)
			}
		}
	|
		'boolean_literal' 
		{
			$$ = {
				code: [],
				place: ($boolean_literal == "true") ? "1" : "0",
				literal: true,
				type: new Type("boolean", "basic", 1, null, 0)
			}
		}
	|
		'character_literal' 
		{
			var s = $character_literal
			s = s.substr(1, s.length - 2)

			if (s.length == 2) {
				s = {
					"a": "\a",
					"b": "\b",
					"f": "\f",
					"n": "\n",
					"r": "\r",
					"t": "\t",
					"v": "\v",
					"\\": "\\",
					"\'": "\'",
					"\"": "\"",
					"?": "\?"
				}[s[1]]

				if (s == null) {
					throw Error("Invalid escape sequence found")
				}
			}

			$$ = {
				code: [],
				place: s.charCodeAt(0).toString(),
				literal: true,
				type: new Type("int", "basic", 4, null, 0)
			}
		}
	|
		'null_literal' 
		{
			$$ = {
				code: [],
				place: $null_literal,
				literal: true,
				type: new Type("null", "basic", null, null, 0)
			}
		}
	;


sign :
		'op_add' 
		{
			$$ = "+"
		}
	|
		'op_sub' 
		{
			$$ = "-"
		}
	;


