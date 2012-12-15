class SyntacticalAnalysis
  attr_accessor :table, :stack, :input, :lex_analysis, :errors

  def analyse
    # nacitanie vstupu
    self.input = lex_analysis.get_lexical_unit()
    # vstup je prazdny => koniec
    finalize() if self.input.nil?

    # kym nie je zasobnik prazdny
    while not stack.empty?
      # pop zo zasobnika
      stack_top = stack.shift

      # ak vstup nie je neterminal
      if not table.has_key?(stack_top)

        # vstup sa zhoduje s vrchom zasobnika
        if input == stack_top
          # vylucenie
          # nacitanie dalsieho vstupu
          self.input = lex_analysis.get_lexical_unit()
          break if self.input.nil?
          next
        else
          # chyba
          process_error('expecting', :stack_top => stack_top)
          next
        end
      end

      # v tabulke je zaznam pre symbol zasobnika a vstup
      if table[stack_top].has_key?(input)
        # nacitanie pravidiel z tabulky
        rules = table[stack_top][input]

        # pravidla su ulozene v Array
        if rules.kind_of?(Array)
          self.stack = rules + self.stack

        else
          # inak je to kod chyby
          process_error(rules)
        end
      end
    end

    # ukoncenie
    finalize()
  end

  # spracovanie chyby
  # vseobecny vypis
  # switch s postupom opravy chyb
  def process_error(code, params= {})
    error =  'Error occured: line '+lex_analysis.line.uniq.length.to_s+': '
    case code
      when 'expecting'
        error += 'expecting "'+params[:stack_top]+'", found "'+input+'"'
        self.input = params[:stack_top]
        self.stack.unshift(params[:stack_top])
        lex_analysis.rewind()
      else
        error += code
    end

    # vlozenie chyby do zoznamu
    self.errors.push error
  end


  def finalize()
    # zasobnik nie je prazdny - program nesuhlasi s gramatikou
    if stack.empty? and not input.nil?
      process_error('Invalid end of program.')
    end

    # ak su chyby - vypis
    if not errors.empty?
      errors.each do |e| puts e end
    else
      puts 'Success.'
    end
    return
  end

  # konstruktor
  def initialize
    # inicializacia
    self.stack = ['PROG']
    self.errors = []

    # tabulka
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