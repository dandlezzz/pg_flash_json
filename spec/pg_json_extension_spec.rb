require 'spec_helper'
RSpec.describe "pg json extension" do
  describe "included in active record relations" do
    it "should be included" do
      expect(Post.limit(1).respond_to?(:to_pg_json)).to eq(true)
    end
  end

  describe "#to_pg_json" do
    it "should turn the relation into json, like active record does" do
      pg_json = JSON.parse(Post.limit(1).to_pg_json)
      ar_json = JSON.parse(Post.limit(1).to_json)
      expect(pg_json).to eq(ar_json)
    end

    it "should turn the relation into json, like active record does and work as expected for relations" do
      pg_json = JSON.parse(Post.limit(1).first.comments.to_pg_json)
      ar_json = JSON.parse(Post.limit(1).first.comments.to_json)
      expect(pg_json).to eq(ar_json)
    end
  end
end