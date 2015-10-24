class PGJsonBuilder

  attr_accessor :attrs, :relation, :rs_alias, :has_manys

  def initialize(relation, opts={})
    @relation = relation
    unless @relation.is_a?(ActiveRecord::Relation) || @relation.is_a?(ActiveRecord::AssociationRelation)
      raise ArgumentError
    end
    @has_manys =[]
    @rs_alias =  opts.fetch(:rs_alias,SqlAlias.new.sql_alias)
    @sets = opts.fetch(:sets, {})
    @attrs = opts.fetch(:attrs, @relation.columns_hash.keys.map(&:to_sym))
    self
  end

  def set(set_key, set_attr,  &block)
    pr = Proc.new(&block)
    @sets[set_key.to_sym] = {proc: pr, set_attr: set_attr}
    @attrs << @sets.keys
    @attrs = @attrs.flatten.compact.uniq
    self
  end

  def add_has_many(relation_name)
    @has_manys << relation_name
  end

  def run_has_many(hm)
    subq = ""
    @relation.pluck(:id).map do |id|
      sqe = SubQueryExecutor.new({bind_sub: true},@rs_alias) do |s|
        @relation.find_by(id: id).send(hm)
      end
      subq = sqe.query
      break
    end
    new_alias= SqlAlias.new.sql_alias
    relation_aps = self.class.new(@relation.first.send(hm), rs_alias: new_alias).attr_pairs_string
    "(select json_agg(
      json_build_object(#{relation_aps}))
        from (#{subq})#{new_alias}
        )
    )"
  end


  def attr_pairs_string
    aps = ""
     @attrs.each do |a|
      value = @sets.fetch(a.to_sym,"#{@rs_alias}.#{a}")
      value = SubQueryExecutor.new(value, @rs_alias).eval_alias if value.is_a?(Hash)
      aps << "'#{a.to_s}', #{value},"

    end
    hm_q = ""
    @has_manys.flatten.each do |hm|
      hm_q = "'#{hm}', #{run_has_many(hm)}"
      aps << hm_q
    end
    aps[0..-2]
  end

  def build_subquery
    "FROM(#{@relation.to_sql})#{@rs_alias}"
  end

  def to_sql
    build_json_object_query + query_end
  end

  def build_json_object_query(from_sub=false)
    first_char = from_sub ? "(" : ""
    "#{first_char}SELECT json_agg(
          json_build_object(#{attr_pairs_string}))"
  end

  def query_end
    " as json #{build_subquery}"
  end

  def json
    @relation.connection.execute(to_sql).first["json"]
  end
end
