README file for PA2 Lexer (C++ edition)
=====================================================

Your directory should now contain the following files:

* `README.md`
* `cool.ll` (original cool.flex but scons recognizes only `*.ll`)
* `test.cl`
* `lextest.cc`     
* `stringtab.cc`   
* `utilities.cc`   
* `handle_flags.cc`
* `*.h`
* `SConstruct` and `SConscript` (replace original Makefile)

The include (.h) files for this assignment are copied from original
[course dir]/include/PA2.

* The original Makefile has been replaced by scons with `SConstruct` and `SConscript`.

* `cool.ll` is a skeleton file for the specification of the lexical analyzer. You should complete it with your regular expressions, patterns and actions. 

* `test.cl` is a COOL program that you can test the lexical analyzer on. It contains some errors, so it won't compile with coolc. However, test.cl does not exercise all lexical constructs of COOL and part of your assignment is to rewrite test.cl with a complete set of tests for your lexical analyzer.

* `cool-parse.h` contains definitions that are used by almost all parts of the compiler. DO NOT MODIFY.

* `stringtab.{cc|h}` and stringtab_functions.h contains functions to manipulate the string tables. DO NOT MODIFY.

* `utilities.{cc|h}` contains functions used by the main() part of the lextest program. You may want to use the strdup() function defined in here. Remember that you should not print anything from inside cool.flex! DO NOT MODIFY.

* `lextest.cc` contains the main function which will call your lexer and print out the tokens that it returns.  DO NOT MODIFY.

* `cool.cc` is the scanner generated by flex from `cool.flex`. DO NOT MODIFY IT, as your changes will be overritten the next time you run flex.

Instructions
------------

* To compile your lextest program type:

```console

	% scons

```

* Run your lexer by putting your test input in a file such as `test.cl` and run the lextest program:

```console

	% ./build/debug/lexer test.cl

```

* If you think your lexical analyzer is correct and behaves like the one we wrote, you can actually try 'mycoolc' and see whether it runs and produces correct code for any examples. If your lexical analyzer behaves in an unexpected manner, you may get errors anywhere, i.e. during parsing, during semantic analysis, during code generation or only when you run the produced code on spim. So beware.

Notes on using flex with C++
----------------------------

The Stackoverflow question [[How do I use C++ in flex and bison?]](http://stackoverflow.com/questions/778431/how-do-i-use-c-in-flex-and-bison) described a way to use C++ with flex.

    For using flex with C++:

     1: read the flex docs:
     2: use flex -+ -o file.cc parser.ll
     3: In the .ll file:
    
    %option c++
    %option yyclass="Your_class_name"
    %option batch
    
     4: In your .hh file, derive Your_class_name from  `public yyFlexLexer`
     5: you can then use your_class_instance.yylex()

However the original code is only using `*.cc` but actually not full C++, so we do not use the above way to generate `cool.cc`.