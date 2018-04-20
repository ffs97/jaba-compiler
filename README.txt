GROUP 24:
   -   Manish Kumar Bera	150381
   -   Gurpreet Singh		150259
   -   Prann Bansal			150510

Source language :- Java
Implementation language :- NODE.JS
Target language :- x86 assembly language



----------------------------------	FEATURES ----------------------------------
BASIC FEATURES:
	TYPES:	INT, FLOAT, CHAR, BOOLEAN

	LOOPS:	FOR, WHILE

	BINARY OPERATIONS:	add, sub, mul, div, and, or, xor, mod, relops

	UNARY OPERATIONS:	not, preinc, predec, postinc, postdec

	ASSIGNMENTS:	=, +=, -=, *=, /=, %=, &=, |=

	FUNCTIONS and FUNCTION CALLS and IMPORT

	MULTI-DIMENSIONAL ARRAYS for ALL data types

	BASIC LIBRARY FUNCTIONS:	print, scan


ADVANCED FEATURES:
	CLASSES and OBJECTS and METHODS

	TYPE CASTING

	RECURSION


-------------------------------- FILES DESCRIPTION -------------------------------

includes/tokens.jison		:	Contains   the	 required	tokens	 for   lexer
includes/grammar.jison		:	Contains the grammar  and tokens used  by  jison
								for buiding  the parser along with the  semantic
								actions for each rule
src/irgen.js   				:   Uses the generated	parser to parse the	required
								test file
symbol-table.js				:	contains   the   class   symboltable   with  the
								structure of the  symbol table and functions for
								building the symbol table.

assembly.js					:	Contains the assembly class with constructs to add 
								individual assembly code instructions to assembly 
								object and also to indent them.

components.js				:	Contains the classes for variables, functions and 
								arrays declared in the 3AC.

descriptor.js				:	Descibes the keywords and the operations that our
 								3AC implements.

registers.js				:	Contains the list of registers to be used and the 
								class Registers with methods to get registers and 
								unload registers and variables.

tac.js						:	Defines the functions to generate the list of 
								variables, functions, arrays, nextUseTable and 
								basic blocks from the 3AC.

translate.js				:	Translates the 3AC to assembly code.


------------------------- DEVIATIONS FROM JAVA SYNTAX -------------------------

## Array Access

Before the square brackets, there needs to be a 'colon' (':'), i.e. the (i, j)th
element    of	 Array	  'arr'    can	  be	accessed	as	  =>	a:[i][j]

This was done to avoid a  reduce/reduce conflict, for which we couldn't find any
other workaround.

## Array Declaration

Array declaration will follow the following format:

	int[d1][...][dn] arr;

		OR

	int[d1][...][dn] arr = { { ... }, ... { ... } }

where each dimension is an integer literal




----------------------	SOME JAVA FEATURES NOT IMPLEMENTED	--------------------
CLASS INHERITANCE

PRIVATE CLASSES and STATIC OBJECTS & VARIABLES





---------------------------------- TOOLS USED ----------------------------------

For this assignment, we have made use of 'jison' which is available as	an	open
source plugin for node.js.	The docs are  available  at  'https://zaa.ch/jison/'




------------------------------- RUNNING THE CODE -------------------------------

The following command will run the code":

	$ bin/jaba path/to/java/file

The IR file will be created in out/irgen
The assembly file will be created in out/codegen