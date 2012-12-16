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
          # chyba - ocakava sa iny znak ako je na vstupe
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
        elsif rules == 'e'
          # epsilonove pravidlo, pokracujeme s dalsim prvkom zo zasobnika
          next
        else
          # inak je to kod chyby
          process_error(rules)
        end
      else
        process_error('unexpected', :stack_top => stack_top)
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
        position = lex_analysis.position
        while not (input.nil? or params[:stack_top] == input)
          self.input = lex_analysis.get_lexical_unit()
        end
        if self.input.nil?
          self.input = params[:stack_top]
          lex_analysis.rewind(position)
        end

        self.stack.unshift(params[:stack_top])
      when 'unexpected'
        error += 'Unexpected symbol "' + input + '".'
        while not table[params[:stack_top]].has_key? self.input
          self.input = lex_analysis.get_lexical_unit()
        end
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
    self.errors += lex_analysis.errors
    if not errors.empty?
      errors.uniq.each do |e| puts e end
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

        'STATLIST' => {'a-z'  =>['STAT','STATLIST0'],
                       'WRITE'=>['STAT','STATLIST0'],
                       'READ'=>['STAT','STATLIST0'],
                       'IF'=>['STAT','STATLIST0']},

        'STATLIST0' => {'a-z'  =>['STATLIST'],
                        'WRITE'=>['STATLIST'],
                        'READ'=>['STATLIST'],
                        'IF'=>['STATLIST'],
                        'END'=>'e'},

        'STAT'      => {'a-z'  =>['IDENT',':=','EXP',';'],
                        'WRITE'=>['WRITE','(','EXPLIST',')',';'],
                        'READ'=>['READ','(','IDLIST',')',';'],
                        'IF'=>['IF','BEXPR','THEN','STAT','STATTT',';']},

        'STATTT'     => {'ELSE'=>['ELSE','STAT'],
                        ';'=>'e'},

        'IDLIST'    => {'a-z'=>['IDENT','IDLIST0']},

        'IDLIST0'   => {','=>[',','IDLIST'],
                        ')'=>'e'},

        'EXPLIST'   => {'('=>['EXP','EXPLIST0'],
                        'a-z'=>['EXP','EXPLIST0'],
                        '+'=>['EXP','EXPLIST0'],
                        '-'=>['EXP','EXPLIST0'],
                        '1-9'=>['EXP','EXPLIST0']},

        'EXPLIST0'  => {','=>[',','EXPLIST'],
                        ')'=>'e'},

        'EXP'       => {'('=>['FACTOR','EXPPP'],
                        'a-z'=>['FACTOR','EXPPP'],
                        '+'=>['FACTOR','EXPPP'],
                        '-'=>['FACTOR','EXPPP'],
                        '1-9'=>['FACTOR','EXPPP']},

        'EXPPP'      => {'+'=>['OP','FACTOR','EXPPP'],
                        '-'=>['OP','FACTOR','EXPPP'],
                        ';'=>'e',
                        ')'=>'e',
                        ','=>'e'},

        'FACTOR'    => {'('=>['(','EXP',')'],
                        'a-z'=>['IDENT'],
                        '+'=>['NUM'],
                        '-'=>['NUM'],
                        '1-9'=>['NUM'],
                        '0'=>['0']},   # ????

        'OP'        => {'+'=>['+'],
                        '-'=>['-']},

        'BEXPR'     => {'NOT'=>['BTERM','BEXPRRR'],
                        '('=>['BTERM','BEXPRRR'],
                        'TRUE'=>['BTERM','BEXPRRR'],
                        'FALSE'=>['BTERM','BEXPRRR']},

        'BEXPRRR'    => {'OR'=>['OR','BTERM','BEXPR'],
                         'THEN'=>'e',
                         ')'=>'e'},

        'BTERM'     => {'NOT'=>['BFACTOR','BTERMMM'],
                        '('=>['BFACTOR','BTERMMM'],
                        'TRUE'=>['BFACTOR','BTERMMM'],
                        'FALSE'=>['BFACTOR','BTERMMM']},

        'BTERMMM'    => {'AND'=>['AND','BFACTOR','BTERMMM'],
                        'THEN'=>'e',
                        'OR'=>'e',
                        ')'=>'e'},

        'BFACTOR'   => {'NOT'=>['NOT','BFACTOR'],
                        '('=>['(','BEXPR',')'],
                        'TRUE'=>['TRUE'],
                        'FALSE'=>['FALSE']},

        'IDENT'     => {'a-z'=>['LETTER','IDENTTT']},

        'IDENTTT'    => {'a-z'=>['LETTER','IDENTTT'],
                        '1-9'=>['DIG09','IDENTTT'],
                        '0'=>['DIG09','IDENTTT'],
                        ';'=>'e',
                        ':='=>'e',
                        ')'=>'e',
                        '+'=>'e',
                        '-'=>'e',
                        'THEN'=>'e',
                        ','=>'e'},

        'NUM'       => {'+'=>['OPP','DIG19','DIGITTT'],
                        '-'=>['OPP','DIG19','DIGITTT'],
                        '1-9'=>['OPP','DIG19','DIGITTT']},

        'OPP'       => {'+'=>['+'],
                        '-'=>['-'],
                        '1-9'=>'e'},

        'DIGITTT'      => {'1-9'=>['DIG09','DIGITTT'],
                        '0'=>['DIG09','DIGITTT'],
                        ';'=>'e',
                        ')'=>'e',
                        '+'=>'e',
                        '-'=>'e',
                        ','=>'e'},

        'LETTER'    => {'a-z'=>['a-z']},

        'DIG19'     => {'1-9'=>['1-9'],
                        },

        'DIG09'     => {'0'=>['0'],
                        '1-9'=>['1-9']},

      }
  end
end