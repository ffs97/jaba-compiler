# Jaba Compiler

We have built a Jaba (a subset of the Java Programming Language) compiler as
part of our CS335 course project (Compiler Design). The target language is the
X86 assembly language, and the compiler is implemented using node.js.

**Team**
-   Gurpreet Singh (guggu@iitk.ac.in)
-   Manish Kumar Bera (mkbera@iitk.ac.in)
-   Prann Bansal (prann@iitk.ac.in)

## Features

**Basic Features**

|      Category     |                         Features                         |
| ----------------- | -------------------------------------------------------- |
| Types             | Int, Float, Char, Boolean                                |
| Loops             | For, While                                               |
| Binary Operations | +-/*, And, Or, Xor, Mod, Relops                          |
| Unary Operations  | Not, (Pre|Post)Increment, (Pre|Post)-Decrement           |
| Assignments       | =, [+-/*]=, [&%|]=                                       |
| Arrays            | Multi-Dimensional Arrays (with any number of dimensions) |
| Functions         | Import functionality for pre-compiled code               |
| Library Functions | print, scan                                              |

**Advanced Features**
- Classes, Objects and Methods
- Type Casting
- Recursion

## Files Description

* **includes/tokens.jison**: Contains the required tokens for the lexer
* **includes/grammar.jison**: Contains the grammar and tokens used by jison for buiding the parser along with the semantic actions for each rule
* **src/irgen.js**: Uses the generated parser to parse the required test file
* **symbol-table.js**: contains the class symboltable with the structure of the symbol table and functions for building the symbol table.
* **assembly.js**: Contains the assembly class with constructs to add individual assembly code instructions to assembly object and also to indent them.
* **components.js**: Contains the classes for variables, functions and arrays declared in the 3AC.
* **descriptor.js**: Descibes the keywords and the operations that our 3AC implements.
* **registers.js**: Contains the list of registers to be used and the class Registers with methods to get registers and unload registers and variables.
* **tac.js**: Defines the functions to generate the list of variables, functions, arrays, nextUseTable and basic blocks from the 3AC.
* **translate.js**: Translates the 3AC to assembly code.


## Deviations from Java Syntax

### Array Access
Before the square brackets, there needs to be a 'colon' (':'), i.e. the (i, j)th element of Array 'arr' can be accessed as => a:[i][j]. This was done to avoid a reduce/reduce conflict, for which we couldn't find any other workaround.

### Array Declaration

Array declaration follows the following format:

```java
int[d1][...][dn] arr;
		OR
int[d1][...][dn] arr = { { ... }, ... { ... } }
```
where each dimension needs to be an integer literal

## Java Features not Implemented

* Class Inheretence
* Private Classes
* Static Objects and Variables

## Tools Used

For this assignment, we have made use of 'jison' which is available as an open source plugin for node.js. The docs are available at 'https://zaa.ch/jison/'

## Running the Code

The following command will run the code:
```bash
$ bin/jaba path/to/java/file
```
The IR file will be created in out/irgen, and the assembly file will be created in out/codegen
