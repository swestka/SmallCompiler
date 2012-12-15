class SyntacticalAnalysis
  attr_accessor :table, :stack, :input, :lex_analysis

  def analyse

    finish = false
    self.input = lex_analysis.get_lexical_unit()

    while not finish
      stack_top = stack.shift

      if not table.has_key?(stack_top)
        if input == stack_top
          self.input = lex_analysis.get_lexical_unit()
          next
        else
          puts 'error'
        end
      end

      if table[stack_top].has_key?(input)
        rules = table[stack_top][input]
        if rules.kind_of?(Array)
          self.stack = rules + self.stack
        else
          process_error(rules)
        end
      end

      finish = stack.empty?
    end
  end

  def process_error(code)
    puts 'Error happened'
  end

  def initialize
    self.stack = ['PROG']
    self.table = {
        'PROG'     => {'BEGIN'=>['BEGIN','STATLIST','END']},

        'STATLIST' => {'a-z'  =>['STAT','STATLIST1'],
                       'WRITE'=>['STAT','STATLIST1'],
                       'READ'=>['STAT','STATLIST1'],
                       'IF'=>['STAT','STATLIST1']},

        'STATLIST1' => {'a-z'  =>['STATLIST'],
                        'WRITE'=>['STATLIST'],
                        'READ'=>['STATLIST'],
                        'IF'=>['STATLIST']},

        'STAT'      => {'a-z'  =>['IDENT',':=','EXP',';'],
                        'WRITE'=>['WRITE','(','EXPLIST',')',';'],
                        'READ'=>['READ','(','IDLIST',')',';'],
                        'IF'=>['IF','BEXPR','THEN','STAT','STAT1',';']},

        'STAT1'     => {'ELSE'=>['ELSE','STAT']},

        'IDLIST'    => {'a-z'=>['IDENT','IDLIST1']},

        'IDLIST1'   => {','=>[',','IDLIST']},

        'EXPLIST'   => {'('=>['EXP','EXPLIST1'],
                        'a-z'=>['EXP','EXPLIST1'],
                        '+'=>['EXP','EXPLIST1'],
                        '-'=>['EXP','EXPLIST1'],
                        '1-9'=>['EXP','EXPLIST1']},

        'EXPLIST1'  => {','=>[',','EXPLIST']},

        'EXP'       => {'('=>['FACTOR','EXP1'],
                        'a-z'=>['FACTOR','EXP1'],
                        '+'=>['FACTOR','EXP1'],
                        '-'=>['FACTOR','EXP1'],
                        '1-9'=>['FACTOR','EXP1']},

        'EXP1'      => {'+'=>['OP','FACTOR','EXP1'],
                        '-'=>['OP','FACTOR','EXP1']},

        'FACTOR'    => {'('=>['(','EXP',')'],
                        'a-z'=>['IDENT'],
                        '+'=>['NUM'],
                        '-'=>['NUM'],
                        '1-9'=>['NUM'],
                        '0'=>['0']},

        'OP'        => {'+'=>['+'],
                        '-'=>['-']},

        'BEXPR'     => {'NOT'=>['BTERM','BEXPR1'],
                        '('=>['BTERM','BEXPR1'],
                        'TRUE'=>['BTERM','BEXPR1'],
                        'FALSE'=>['BTERM','BEXPR1']},

        'BEXPR1'    => {'OR'=>['OR','BTERM','BEXPR']},

        'BTERM'     => {'NOT'=>['BFACTOR','BTERM1'],
                        '('=>['BFACTOR','BTERM1'],
                        'TRUE'=>['BFACTOR','BTERM1'],
                        'FALSE'=>['BFACTOR','BTERM1']},

        'BTERM1'    => {'AND'=>['AND','BFACTOR','BEXPR1']},

        'BFACTOR'   => {'NOT'=>['NOT','BFACTOR'],
                        '('=>['(','BEXPR',')'],
                        'TRUE'=>['TRUE'],
                        'FALSE'=>['FALSE']},

        'IDENT'     => {'a-z'=>['LETTER','IDENT1']},

        'IDENT1'    => {'a-z'=>['LETTER','IDENT1'],
                        '1-9'=>['DIG09','IDENT1'],
                        '0'=>['DIG09','IDENT1']},

        'NUM'       => {'+'=>['+','DIG19','NUM1'],
                        '-'=>['-','DIG19','NUM1'],
                        '1-9'=>['DIG19','NUM1']},

        'NUM1'      => {'1-9'=>['1-9','NUM1'],
                        '0'=>['0','NUM1']},

        'LETTER'    => {'a-z'=>['a-z']},

        'DIG19'     => {'1-9'=>['1-9']},

        'DIG09'     => {'0'=>['0'],
                        '1-9'=>['1-9']}

      }
  end
end