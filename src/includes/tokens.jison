%lex

%s BLOCKCOMMENT
%s COMMENT

%%

\/\*								this.pushState('BLOCKCOMMENT');

<BLOCKCOMMENT>\*\/					this.popState();

<BLOCKCOMMENT>(\n|\r|.)				/* SKIP BLOCKCOMMENTS */

\/\/								this.pushState('COMMENT');

<COMMENT>(.)						/* SKIP COMMENTS */

<COMMENT>(\n|\r)					this.popState();

\s+									/* SKIP WHITESPACES */

"boolean"							return 'boolean';

"break"								return 'break';

"byte"								return 'byte';

"case"								return 'case';

"char"								return 'char';

"class" 							return 'class';

"const"								return 'const';

"continue"							return 'continue';

"default"							return 'default';

"do"								return 'do';

"double"							return 'double';

"else"								return 'else';

"extends"							return 'extends';

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

"static"							return 'static';

"super" 							return 'super';

"switch"							return 'switch';

"this"								return 'this';

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

\"(\\[^\n\r]|[^\\\'\n\r])*\"		return 'string_literal';

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