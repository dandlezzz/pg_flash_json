require 'spec_helper'
describe PGJsonSerializerBase do
  describe "initialization" do
    it "requires a relation and and instantiates a builder" do
      relation = Post.all
      serializer = PGJsonSerializerBase.new(relation)
      expect(serializer.builder).to be_an_instance_of PGJsonBuilder
      expect(serializer.builder.relation).to eq(Post.all)
    end
  end

  describe "serialize" do
    it "should return the json of the relation" do
      relation = Post.limit(1)
      post = Post.first
      serializer = PGJsonSerializerBase.new(relation)
      expect(serializer.serialize).to eq(
      "[{\"id\" : #{post.id}, \"title\" : \"#{post.title}\", \"content\" : \"#{post.content}\"}]"
      )
    end
  end
end
