class PGJsonSerializerBase

  attr_accessor :builder

  def initialize(relation)
    @relation = relation
    @builder = set_builder
    self
  end

  def set_builder
    attrs = self.class.attrs || @relation.columns_hash.keys.map(&:to_sym)
    PGJsonBuilder.new(@relation, attrs: attrs )
  end

  def call_sets
    methods = [public_methods(false)- PGJsonSerializerBase.instance_methods].flatten
    methods.each do |pm|
      send(pm)
    end
    @builder
  end

  def call_relations
    call_has_manys
  end

  def call_has_manys
    self.class.has_manys.each do |hm|
      builder.add_has_many(hm)
    end
  end

  def serialize
    call_sets
    call_relations
    @builder.json
  end

  def self.attrs
    @attrs
  end

  def self.has_manys
    @has_manys ||= []
  end

  def self.has_many(*relations)
    has_manys << relations
  end

  def self.attributes(*attrs)
    @attrs = attrs
  end

end
