all:
	mkdir -p bin
	mkdir -p out/irgen out/codegen
	cp src/jaba bin/jaba
	chmod +x bin/jaba
	#jison -p lr -o src/node_modules/parser/index.js src/includes/grammar.jison

clean:
	rm -r bin out
