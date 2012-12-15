require './lexical_analysis.rb'
require './syntactical_analysis.rb'

lex_analysis = LexicalAnalysis.new('./samples/sample1.small')

syntax_analysis = SyntacticalAnalysis.new
syntax_analysis.lex_analysis = lex_analysis
syntax_analysis.analyse()