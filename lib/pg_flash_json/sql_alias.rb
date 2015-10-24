class SqlAlias
  @used = []

  attr_accessor :sql_alias

  def self.used
    @used
  end

  def initialize
    @sql_alias = new_alias
    self.class.used << @sql_alias
  end

  def new_alias
    alias_needed = true
    while alias_needed do
      potential_alias = "t#{rand(1000)}"
      alias_needed = self.class.used.include?(potential_alias)
    end
    potential_alias
  end
end
