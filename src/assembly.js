class Assembly {
	constructor() {
		this.indent = 0

		this.data = ""
		this.shiftRight()
		this.add_data("\tfunction_return_error_msg db \"Error: function with return type not void, did not seem to return\", 0x0a, 0")
		this.add_data("\tarray_access_up_error_msg db \"Error: array index exceeds dimension size\", 0x0a, 0")
		this.add_data("\tarray_access_low_error_msg db \"Error: array index cannot be negative\", 0x0a, 0")
		this.code = ""
		this.externs = ["malloc", "printf"]
	}


	add_extern(extern) {
		if (!this.externs.includes(extern)) {
			this.externs.push(extern)
		}
	}


	add_data(line) {
		for (var i = 0; i < this.indent; i += 1) {
			line = "\t" + line
		}
		this.data += "\t" + line + "\n"
	}


	add(line) {
		for (var i = 0; i < this.indent; i += 1) {
			line = "\t" + line
		}
		this.code += line + "\n"
	}


	shiftRight() {
		this.indent += 1
	}

	shiftLeft() {
		this.indent -= 1
		if (this.indent < 0) {
			this.indent = 0
		}
	}


	setLabels(labels) {
		this.labels = labels
	}


	addModules(module) {
		var self = this;

		var path = "src/modules/" + module + ".json"

		var fs = require("fs")
		if (fs.existsSync(path)) {
			var components = JSON.parse(fs.readFileSync(path, "utf8"))

			for (var index = 0; index < components.externs.length; index += 1) {
				self.add_extern(components.externs[index])
			}

			for (var index = 0; index < components.data.length; index += 1) {
				self.add_data(components.data[index])
			}

			self.add("")
			for (var index = 0; index < components.code.length; index += 1) {
				self.add(components.code[index])
			}
		}
		else {
			throw Error("The module " + module + " was not found")
		}
	}


	generate_code() {
		var code = ""

		code += "global main" + "\n\n"

		for (var index = 0; index < this.externs.length; index += 1) {
			code += "extern " + this.externs[index] + "\n"
		}
		code += "\n"

		code += "section .data\n"
		code += this.data + "\n\n"

		code += "section .text\n\n"
		code += this.code

		return code
	}


	print(file = "") {
		var code = this.generate_code().replace(/\:\s*\n\s*\n/g, ":\n")
		// console.log(code)
		if (file != "") {
			var fs = require("fs")
			fs.writeFile(file, code, (err) => {
				if (err) throw err

				console.log("Saved to " + file)
			})
		}
	}
}


module.exports = {
	Assembly: Assembly
}