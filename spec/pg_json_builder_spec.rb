require 'spec_helper'
describe PGJsonBuilder do

  describe "initialize" do
    it "takes an active record association" do
      expect{PGJsonBuilder.new(Post.all)}.to_not raise_error
    end

    it "takes an active record association relation" do
      expect{PGJsonBuilder.new(Post.last.comments)}.to_not raise_error
    end

    it "throws an error if it does not receive an active record association or relation" do
      expect{PGJsonBuilder.new(Post.first)}.to raise_error
    end

    it "clears the alias tracker after initialization" do
      PGJsonBuilder.new(Post.all)
      expect(SqlAlias.used.count).to eq(0)
    end

  end

  describe "setting included attributes" do
    it "sets the included attributes to an ivar based on the options hash" do
      builder = PGJsonBuilder.new(Post.all, attrs: [:title])
      expect(builder.attrs).to eq [:title]
    end

    it "defaults to all attributes of the relation model" do
      builder = PGJsonBuilder.new(Post.all)
      expect(builder.attrs).to eql(["id", "title", "content"])
    end

    it "defaults to all attributes of the association relation model " do
      builder = PGJsonBuilder.new(Post.last.comments)
      expect(builder.attrs).to eql(["id", "content", "post_id"])
    end
  end

  describe "building the json_agg query" do
    let!(:builder) { PGJsonBuilder.new(Post.all) }

    describe "the attribute pairs string" do
      it "should create json structure required by postgres based on the requested attrs" do
        expect(builder.attr_pairs_string.squish.chomp).to eq("'id', #{builder._alias}.id,'title',
        #{builder._alias}.title,'content', #{builder._alias}.content".squish.chomp)
      end
    end

    describe "building the json object query" do
      it "should use the attribute pair string and the relation sub query to build the final query" do
        expect(builder.build_json_object_query.squish.chomp).to eql(
        "SELECT json_agg(
        json_build_object('id', #{builder._alias}.id,'title', #{builder._alias}.title,'content', #{builder._alias}.content))
        ".chomp.squish)
      end
    end

    describe "returning record(s) as json" do

      let!(:post) { Post.first }

      it "should return the requested records as json" do
        builder = PGJsonBuilder.new(Post.limit(1))
        expect(builder.json).to eq("[{\"id\" : #{post.id}, \"title\" : \"#{post.title}\", \"content\" : \"#{post.content}\"}]")
      end

      it "should return the requested records as json respecting the attrs argument" do
        builder = PGJsonBuilder.new(Post.limit(1), attrs: [:title])
        expect(builder.json).to eq("[{\"title\" : \"#{post.title}\"}]")
      end
    end

    describe "to_sql" do
      it "allows you to print the query instead of running it" do
        builder = PGJsonBuilder.new(Post.limit(1))
        expect(builder.to_sql.squish.chomp).to eq(
        "SELECT json_agg(
        json_build_object('id', #{builder._alias}.id,'title', #{builder._alias}.title,'content', #{builder._alias}.content))
        as json FROM(SELECT  \"posts\".* FROM \"posts\" LIMIT 1)#{builder._alias}".chomp.squish)
      end
    end
  end
end
