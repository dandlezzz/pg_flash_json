class SqlAlias
  @used = []
  def self.used
    @used
  end
  attr_accessor :sql_alias
  def initialize
    @sql_alias = new_alias
    self.class.used << @sql_alias
  end

  def new_alias
    alias_needed = true
    while alias_needed do
      potential_alias = "t#{rand(1000)}"
      if !self.class.used.include?(potential_alias)
        alias_needed = false
        return potential_alias
      end
    end
    potential_alias
  end
end
