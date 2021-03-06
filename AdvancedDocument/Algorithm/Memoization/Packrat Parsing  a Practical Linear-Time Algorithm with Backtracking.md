[Packrat Parsing: a Practical Linear-Time Algorithm with Backtracking](https://pdos.csail.mit.edu/~baford/packrat/thesis/)

# Packrat Parsing: a Practical Linear-Time Algorithm with Backtracking

## 
Bryan Ford

Master's Thesis

Massachusetts Institute of Technology

</center>

### Abstract

Packrat parsing is a novel and practical method
for implementing linear-time parsers
for grammars defined in Top-Down Parsing Language (TDPL).
While TDPL was originally created as a formal model
for top-down parsers with backtracking capability,
this thesis extends TDPL
into a powerful general-purpose notation for describing language syntax,
providing a compelling alternative
to traditional context-free grammars (CFGs).
Common syntactic idioms
that cannot be represented concisely in a CFG
are easily expressed in TDPL,
such as longest-match disambiguation and "syntactic predicates,"
making it possible
to describe the complete lexical and grammatical syntax
of a practical programming language
in a single TDPL grammar.

Packrat parsing is an adaptation of a 30-year-old tabular parsing algorithm
that was never put into practice until now.
A packrat parser can recognize
any string defined by a TDPL grammar in linear time,
providing the power and flexibility
of a backtracking recursive descent parser
without the attendant risk of exponential parse time.
A packrat parser can recognize any LL(_k_) or LR(_k_) language,
as well as many languages requiring unlimited lookahead
that cannot be parsed by shift/reduce parsers.
Packrat parsing also provides better composition properties than LL/LR parsing,
making it more suitable for dynamic or extensible languages.
The primary disadvantage of packrat parsing is its storage cost,
which is a constant multiple of the total input size
rather than being proportional to the nesting depth
of the syntactic constructs appearing in the input.

Monadic combinators and lazy evaluation
enable elegant and direct implementations of packrat parsers
in recent functional programming languages such as Haskell.
Three different packrat parsers for the Java language
are presented here,
demonstrating the construction of packrat parsers in Haskell
using primitive pattern matching, using monadic combinators,
and by automatic generation from a declarative parser specification.
The prototype packrat parser generator developed for the third case
itself uses a packrat parser to read its parser specifications,
and supports full TDPL notation
extended with "semantic predicates,"
allowing parsing decisions to depend on the semantic values
of other syntactic entities.
Experimental results show that all of these packrat parsers
run reliably in linear time,
efficiently support "scannerless" parsing
with integrated lexical analysis,
and provide the user-friendly error-handling facilities
necessary in practical applications.

### Full Thesis

In [PDF](thesis.pdf)
or [PostScript](thesis.ps)

### Pappy: a Parser Generator for Haskell

The full source code for Pappy,
the prototype packrat parser generator described in the thesis,
is available for browsing [in this directory](pappy/),
or for downloading [as a gzipped tar file](pappy.tgz).
A brief breakdown of the source files follows:

*   **[Pos.hs](pappy/Pos.hs)**:
	Library module for keeping track of line/column position
	in a text file.

*   **[Parse.hs](pappy/Parse.hs)**:
	Library of support functions and monadic combinators
	for use in constructing packrat parsers.
	Inspired by Daan Leijen's
	[Parsec](http://www.cs.uu.nl/~daan/parsec.html) library,
	which was designed for traditional predictive parsers
	and mostly-predictive parsers with special-case backtracking.

*   **[ReadGrammar.hs](pappy/ReadGrammar.hs)**:
	Monadic packrat parser for Pappy parser specifications.

*   **[ReduceGrammar.hs](pappy/ReduceGrammar.hs)**:
	Grammar reduction module,
	which rewrites left-recursive rules
	and repetition operators ('*' and '+')
	into primitive right-recursive form.

*   **[SimplifyGrammar.hs](pappy/SimplifyGrammar.hs)**:
	Grammar simplification module,
	which optimizes the grammar
	and eliminates as many nonterminals as possible.

*   **[MemoAnalysis.hs](pappy/MemoAnalysis.hs)**:
	Memoization analysis modle,
	which determines the set of nonterminals
	to be memoized by the packrat parser.

*   **[WriteParser.hs](pappy/WriteParser.hs)**:
	Code generation module.

*   **[Main.hs](pappy/Main.hs)**:
	Top-level control module,
	which links all the compiler stages together.

### Example Arithmetic Expression Parsers

Following are complete versions of the example parsers
for the trivial arithmetic expression language used in the thesis:

*   **[ArithRecurse.hs](arith/ArithRecurse.hs)**:
Recursive descent parser described in Section 3.1.1,
for the trivial arithmetic expression language of Figure 1.

*   **[ArithPackrat.hs](arith/ArithPackrat.hs)**:
Equivalent packrat parser for the same trivial language,
Section 3.1.4.

*   **[ArithLeft.hs](arith/ArithLeft.hs)**:
Left recursion example for Section 3.2.1,
which extends the above packrat parser with
properly left-associative subraction, division, and modulo operators.

*   **[ArithLex.hs](arith/ArithLex.hs)**:
Integrated lexical analysis example for Section 3.2.2,
which extends the previous packrat parser
with support for multiple-digit decimal literals
and optional whitespace padding
between literals, operators, and punctuation.

*   **[ArithMonad.hs](arith/ArithMonad.hs)**:
Example packrat parser, equivalent to ArithLex.hs,
but using monadic combinators to express the parsing functions more succinctly
and provide support for user-friendly error detection and reporting.
Discussed in Section 3.2.3 and 3.2.4 of the thesis.
The following two library modules from Pappy are required:

*   **[Arith.pappy](arith/Arith.pappy)**:
Pappy parser specification for a parser
equivalent to ArithLex.hs and ArithMonad.hs.
The resulting automatically-generated parser
is available as [Arith.hs](arith/Arith.hs).

        *   [Pos.hs](pappy/Pos.hs):
	Keeps track of line and column position while scanning input text.

        *   [Parse.hs](pappy/Parse.hs):
	Monadic combinator library for packrat parsers.

### Example Java Language Parsers

The three complete and working parsers for the Java language,
which are described in the paper and used
for analysis and comparison purposes,
are available here:

*   **[JavaMonad.hs](java/JavaMonad.hs)**:
	A packrat parser for the Java language
	that exclusively uses monadic combinators
	to define the parsing functions making up the parser.
	Both "safe", constant-time combinators
	and "unsafe" combinators with hidden recursion
	are used in this parser,
	meaning that it is not quite a linear-time parser
	although it appears to come pretty close in practice.

*   **[JavaPat.hs](java/JavaPat.hs)**:
	A version of the above parser
	modified to use direct Haskell pattern-matching
	for some of the performance-critical lexical analysis functions:
	whitespace, identifiers, keywords, operators,
	and integer, character, and string literals.
	The rest of the parser is monadic just as before,
	and likewise uses "unsafe" combinators.

*   **[Java.pappy](java/Java.pappy)**:
	Pappy parser specification for the Java language.
	The resulting automatically-generated parser
	is available as [Java.hs](java/Java.hs).
	Since Pappy rewrites repetition operators,
	this parser uses only constant-time primitives
	and therefore should be a strictly linear-time parser -
	at least to the extent that memory access is constant-time
	(which is not quite the case
	in the presence of garbage collection and cache effects and such).

The test suite of Java source files
used to obtain the experimental results in the thesis
are available [in this gzipped tar file](testsuite.tgz).
All of these Java source files
were taken from [Cryptix](http://www.cryptix.org/) version 3.2.0.

Enjoy!

* * *
[Bryan Ford's Home Page](http://www.brynosaurus.com/)

<!--#include virtual="../../footer.html" -->
