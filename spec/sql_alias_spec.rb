require 'spec_helper'
describe SqlAlias do
  it "should create a new sql alias" do
    sql_alias = SqlAlias.new.sql_alias
    expect(sql_alias =~ /t\d{0,3}/).to be_truthy
  end
  it "should not repeat aliases" do
    aliases = []
    10.times {aliases << SqlAlias.new.sql_alias}
    expect(aliases.uniq.count).to eq 10
  end
end


# class SqlAlias
#   @used = []
#   def self.used
#     @used
#   end
#   attr_accessor :sql_alias
#   def initialize
#     @sql_alias = new_alias
#     self.class.used << @sql_alias
#   end
#
#   def new_alias
#     alias_needed = true
#     while alias_needed do
#       potential_alias = "t#{rand(1000)}"
#       if !self.class.used.include?(potential_alias)
#         alias_needed = false
#         return potential_alias
#       end
#     end
#     potential_alias
#   end
# end
