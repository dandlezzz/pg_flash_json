class PGJsonBuilder

  attr_accessor :attrs, :relation, :_alias

  def initialize(relation, opts={})
    @relation = relation
    raise ArgumentError unless @relation.is_a?(ActiveRecord::Relation) || @relation.is_a?(ActiveRecord::AssociationRelation)
    @_alias = SqlAlias.new.sql_alias
    @attrs = opts.fetch(:attrs, @relation.column_names)
    SqlAlias.clear
    self
  end

  def attr_pairs_string
    aps = ""
     @attrs.each do |a|
      a = a.to_s
      value = "#{@_alias}.#{a}"
      aps << "'#{a}', #{value},"
    end
    aps[0..-2]
  end

  def to_sql
    build_json_object_query + query_end
  end

  def build_json_object_query(from_sub=false, relation_aps=attr_pairs_string)
    first_char = from_sub ? "(" : ""
    "#{first_char}SELECT json_agg( json_build_object(#{relation_aps}))"
  end

  def query_end
    " as json FROM(#{@relation.to_sql})#{@_alias}"
  end

  def json
    @relation.connection.execute(to_sql).first["json"]
  end
end
