class LexicalAnalysis

  attr_accessor :data, :length, :position, :last_position, :line, :errors, :skip_spaces

  attr_accessor :terminals

  # konstruktor
  # param String filename
  def initialize(filename)
    file = File.open(filename, "r")
    self.data = file.read
    file.close

    # inicializacia atributov
    self.skip_spaces = true
    self.errors = []
    self.line = [0]
    self.length = data.length
    self.position = self.last_position = 0

    # zoznam terminalov a operatorov
    self.terminals = [
          'BEGIN',
          'END',
          ':=',
          ';',
          '(',
          ')',
          'WRITE',
          'READ',
          'IF',
          'THEN',
          'ELSE',
          'IDENT',
          '+',
          '-',
          'NOT',
          'AND',
          'OR',
          'TRUE',
          'FALSE',
          ','
      ]

  end

  # vracia lexikalnu jednotku
  def get_lexical_unit()
    # ulozenie vychodzej pozicie
    self.last_position = position

    # vynechanie medzier
    while space() do
      break unless position_increase()
      self.last_position+=1
    end

    # prechadza cez ne-alfanumericke znaky
    while not alnum() do
      break unless position_increase()
      break if terminals.include? data[last_position..position-1]
    end

    # ak neboli najdene ziadne ne-alfanum. znaky
    if position == self.last_position
      # prechadza cez alfanumericke
      while alnum() or space() do
        break if space() and terminals.include? data[last_position..position-1]
        break unless position_increase()
      end
    end


    # jednotka - sekvencia vyhradne alnum. znakov
    # alebo vyhradne nealnum. znakov
    unit = data[last_position..position-1]
    return nil if unit.nil?
    # je sekvencia znakov klucove slovo?
    if terminals.include? unit.upcase
      # koniec, retazec odovzdany syntakt. analyzatoru
      return unit
    else
      process_error('invalid') if unit.strip.scan(/\s/).length > 0
      # retazec nie je kluc.slovo, vratime len jeho prvy znak
      unit = data[last_position]
      self.position = last_position + 1

      # ak je prvy znak klucovy symbol
      if unit.nil? or terminals.include? data[last_position].upcase
        return unit
      end
    end

    # zatriedenie symbolov

    if /[+-]?[1-9]+/ === unit
      #cislo  od 1 do 9
      return '1-9'
    elsif /[a-zA-Z]+/ === unit
      #pismeno
      return 'a-z'
    elsif '0' === unit
      # 0
      return unit
    else
      self.errors.push 'Error: line '+line.uniq.length.to_s+': invalid characer "'+unit+'"'
      return get_lexical_unit
    end
  end

  # true ak je aktualny znak whitespace
  def space()
    # pocitanie riadkov
    self.line.push position if /\n/ === data[position]
    /\s/ === data[position]

  end

  # true ak je aktualny znak alfanum. znak
  def alnum()
    is_alnum = /[a-zA-Z0-9]+/ === data[position]
    self.skip_spaces = (not is_alnum)
    return is_alnum
  end

  # posun pozicie na vstupe
  # true - ak sa posunula
  # false - ak je koniec vstupu
  def position_increase()
    if self.position < length
      self.position+=1
      return true
    end

    false
  end

  # navrat pozicie na danu uroven
  # default: posledna ulozena pozicia
  def rewind(pos = self.last_position)
    self.position = pos
  end

  def process_error(code)
    error = 'Error: at line '+line.uniq.length.to_s+': '
    case code
      when 'invalid'
        error+=' Invalid character "'+data[position]+'"'
    end
    self.errors.push error
  end
end