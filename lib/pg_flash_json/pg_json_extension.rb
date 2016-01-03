require 'active_record'

module ActiveRecord
  module PgJsonExtension

    def to_pg_json
      PGJsonBuilder.new(self).json
    end


  end
end

ActiveRecord::Relation.include ActiveRecord::PgJsonExtension