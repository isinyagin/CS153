# We are not really tracking dependencies because everything is small
# enough to recompile at will.

# change to a different ocamlc if you prefer (e.g., ocamlopt)
COMPILER=ocamlc
 
all: clean cish cish_stdin scish scish_stdin

mips:
	$(COMPILER) -c word32.ml
	$(COMPILER) -c mips.ml

cish: mips
	$(COMPILER) -c cish_ast.ml
	ocamlyacc cish_parse.mly
	$(COMPILER) -c cish_parse.mli
	$(COMPILER) -c cish_parse.ml
	ocamllex cish_lex.mll
	$(COMPILER) -c cish_lex.ml
	$(COMPILER) -c utility.ml
	$(COMPILER) -c cish_eval.ml
	$(COMPILER) -c cish_compile.ml
	$(COMPILER) -c cish.ml
	$(COMPILER) -o ps4_cish cish_ast.cmo cish_parse.cmo cish_lex.cmo cish_eval.cmo word32.cmo mips.cmo utility.cmo cish_compile.cmo cish.cmo

cish_stdin: cish
		$(COMPILER) -c cish_stdin.ml
		$(COMPILER) -o ps4_cish_stdin cish_ast.cmo cish_parse.cmo cish_lex.cmo cish_eval.cmo word32.cmo mips.cmo utility.cmo cish_compile.cmo cish_stdin.cmo

scish: cish mips	
	$(COMPILER) -c cish_ast.ml
	$(COMPILER) -c scish_ast.ml
	ocamlyacc scish_parse.mly
	$(COMPILER) -c scish_parse.mli
	$(COMPILER) -c scish_parse.ml
	ocamllex scish_lex.mll
	$(COMPILER) -c scish_lex.ml
	$(COMPILER) -c scish_eval.ml
	$(COMPILER) -c environment.ml
	$(COMPILER) -c scish_compile.ml
	$(COMPILER) -c scish.ml
	$(COMPILER) -o ps4_scish cish_ast.cmo cish_parse.cmo cish_lex.cmo scish_ast.cmo scish_parse.cmo scish_lex.cmo scish_eval.cmo utility.cmo word32.cmo mips.cmo environment.cmo scish_compile.cmo scish.cmo

scish_stdin: scish
	$(COMPILER) -c scish_stdin.ml
	$(COMPILER) -o ps4_scish_stdin cish_ast.cmo cish_parse.cmo cish_lex.cmo scish_ast.cmo scish_parse.cmo scish_lex.cmo scish_eval.cmo utility.cmo word32.cmo mips.cmo environment.cmo scish_compile.cmo scish_stdin.cmo


clean:
	rm -rf *.cmo *.cmi ps4_cish ps4_scish ps4_cish_stdin ps4_scish_stdin cish_parse.ml cish_parse.mli cish_lex.ml scish_parse.ml scish_parse.mli scish_lex.ml

