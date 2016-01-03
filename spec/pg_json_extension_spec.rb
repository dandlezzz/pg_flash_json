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


  describe "performance benchmarks" do
    it "should be faster than active_record to_json" do

      ar_time = Benchmark.realtime {
        Post.limit(50).to_json
      }

      pg_json_time = Benchmark.realtime {
        Post.limit(50).offset(50).to_pg_json
      }

      puts ar_time
      puts pg_json_time

      expect(ar_time > pg_json_time).to eq true
    end
  end
end