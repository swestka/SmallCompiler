class LexicalAnalysis

  attr_accessor :data, :length, :position, :last_position

  attr_accessor :terminals

  def initialize(filename)
    file = File.open(filename, "r")
    self.data = file.read
    file.close

    self.length = data.length
    self.position = self.last_position = 0

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

  def get_lexical_unit()

    while space() do
      self.position+=1
      self.last_position+=1
    end

    while not alnum() and not space() do
      self.position+=1
    end

    if position == self.last_position
      while alnum() do
        self.position+=1
      end
    end

    unit = data[last_position..position-1]
    print unit

    if terminals.include? unit.upcase
      self.last_position = position
      return unit
    else
      unit = data[last_position]
      self.last_position+=1
      self.position = last_position
      print unit

      if terminals.include? unit.upcase
        return unit
      end


    end

    if /[+-]?\d+/ === unit
      return '1-9'
    else
      return 'a-z'
    end

  end

  def space()
    return /\s/ === data[position]
  end

  def alnum()
    return /[a-zA-Z0-9]+/ === data[position]
  end
end