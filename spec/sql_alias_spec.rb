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

  it "should be able to clear its aliases" do
    10.times { SqlAlias.new.sql_alias}
    SqlAlias.clear
    expect(SqlAlias.used.count).to eq(0)
  end

end