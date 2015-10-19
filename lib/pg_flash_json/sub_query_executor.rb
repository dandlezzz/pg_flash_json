
class SubQueryExecutor

  attr_accessor :parent_alias, :query

  def initialize(opts={}, parent_alias=nil, &block)
    @proc = opts[:proc]
    @proc ||= block
    @bind_sub = opts[:bind_sub]
    @set_attr = opts[:set_attr]
    @parent_alias = parent_alias
    @self_sql_alias = SqlAlias.new.sql_alias
    eval_alias
  end

  def eval_alias
    "(select #{@set_attr} from (#{to_sql(@proc)})#{@self_sql_alias})"
  end

  def to_sql(proc)
    relation   = proc.call(self)
    connection = ActiveRecord::Base.connection
    visitor    = connection.visitor

    if relation.eager_loading?
      relation.send(:find_with_associations) { |rel| relation = rel }
    end

    arel  = relation.arel
    binds = (arel.bind_values + relation.bind_values).dup
    if !@bind_sub
      binds.map! { |b| b.last =~ /#{@parent_alias}\./ ? b.last : connection.quote(*b.reverse) }
    else
      binds = [@parent_alias]
    end
    collect = visitor.accept(arel.ast, Arel::Collectors::Bind.new)
    @query = collect.substitute_binds(binds).join
    if @bind_sub
      @query.gsub!(/\=\s(t\d+)/,"in (#{@parent_alias}.id)")
    end
    @query
  end

  def method_missing(a, *b, &block)
    return "#{@parent_alias}.#{a}"
  end
end
