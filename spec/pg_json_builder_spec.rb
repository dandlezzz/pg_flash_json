require 'spec_helper'
describe PGJsonBuilder do

  describe "initialize" do
    it "takes an active record assocation" do
      expect{PGJsonBuilder.new(Post.all)}.to_not raise_error
    end

    it "takes an active record assocation relation" do
      expect{PGJsonBuilder.new(Post.last.comments)}.to_not raise_error
    end

    it "throws an error if it does not receive an active record association or relation" do
      expect{PGJsonBuilder.new(Post.first)}.to raise_error
    end
  end

  describe "setting included attributes" do
    it "sets the included attribtues to an ivar based on the options hash" do
      builder = PGJsonBuilder.new(Post.all, attrs: [:title])
      expect(builder.attrs).to eq [:title]
    end

    it "defaults to all attribtes of the relation model" do
      builder = PGJsonBuilder.new(Post.all)
      expect(builder.attrs).to eql([:id, :title, :content])
    end

    it "defaults to all attribtes of the association relation model " do
      builder = PGJsonBuilder.new(Post.last.comments)
      expect(builder.attrs).to eql([:id, :content, :post_id])
    end
  end

  describe "building the json_agg query" do
    describe "building the subquery" do
      it "should build the subquery based on the relation and alias it" do
        builder = PGJsonBuilder.new(Post.all)
        sub_q = builder.build_subquery
        expect(sub_q).to eq("FROM(SELECT \"posts\".* FROM \"posts\")#{builder.rs_alias}")
      end
    end

    describe "building the attribute pairs string" do
      it "should create json structure required by postgres based on the requested attrs" do
        builder = PGJsonBuilder.new(Post.all)
        q_string = builder.attr_pairs_string
        expect(q_string.squish.chomp).to eq("'id', #{builder.rs_alias}.id,'title',
        #{builder.rs_alias}.title,'content', #{builder.rs_alias}.content".squish.chomp)
      end
    end

    describe "building the json object query" do
      it "should use the attribute pair string and the relation sub query to build the final query" do
        builder = PGJsonBuilder.new(Post.all)
        q_string = builder.build_json_object_query
        expect(q_string.squish.chomp).to eql(
        "SELECT json_agg(
        json_build_object('id', #{builder.rs_alias}.id,'title', #{builder.rs_alias}.title,'content', #{builder.rs_alias}.content))
        ".chomp.squish)
      end
    end

    describe "returning record(s) as json" do
      it "should return the requested records as json" do
        post = Post.first
        builder = PGJsonBuilder.new(Post.limit(1))
        expect(builder.json).to eq("[{\"id\" : #{post.id}, \"title\" : \"#{post.title}\", \"content\" : \"#{post.content}\"}]")
      end

      it "should return the requested records as json respecting the attrs argument" do
        post = Post.first
        builder = PGJsonBuilder.new(Post.limit(1), attrs: [:title])
        expect(builder.json).to eq("[{\"title\" : \"#{post.title}\"}]")
      end
    end

    describe "to_sql" do
      it "allows you to print the query instead of running it" do
        builder = PGJsonBuilder.new(Post.limit(1))
        expect(builder.to_sql.squish.chomp).to eq(
        "SELECT json_agg(
        json_build_object('id', #{builder.rs_alias}.id,'title', #{builder.rs_alias}.title,'content', #{builder.rs_alias}.content))
        as json FROM(SELECT  \"posts\".* FROM \"posts\" LIMIT 1)#{builder.rs_alias}".chomp.squish)
      end
    end
  end
end
