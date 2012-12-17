require './lexical_analysis.rb'
require './syntactical_analysis.rb'

filename = ARGV.empty? ? './samples/sample3.small' : ARGV.shift()
puts filename

output = ARGV.delete('-o')

lex_analysis = LexicalAnalysis.new(filename)
syntax_analysis = SyntacticalAnalysis.new
syntax_analysis.output = output
syntax_analysis.lex_analysis = lex_analysis
syntax_analysis.analyse()