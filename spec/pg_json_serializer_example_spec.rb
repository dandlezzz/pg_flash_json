describe "An example PG JSON serializer" do

  class PostSerializer < PGJsonSerializerBase
    attributes :id, :title, :content
  end

  describe "serialization" do
    it "should serialize the object according the attributes" do
      post = Post.first
      json = PostSerializer.new(Post.limit(1)).serialize
      expect(json).to eq("[{\"id\" : #{post.id}, \"title\" : \"#{post.title}\", \"content\" : \"#{post.content}\"}]")
    end

    describe "setting attrs" do
      it "should allow you to set attributes using public_methods/active_record" do
        class PostSerializerWithCount < PGJsonSerializerBase
          attributes :id, :comments_count

          def comments_count
            builder.set("comments_count", "count(*)") do |s|
              Comment.where(post_id: s.id)
            end
          end
        end
        post = Post.first
        json = PostSerializerWithCount.new(Post.limit(1)).serialize

        expect(json).to eq("[{\"id\" : #{post.id}, \"comments_count\" : #{post.comments.count}}]")
      end
      it "should take multiple records" do
        class PostSerializerWithCount < PGJsonSerializerBase
          attributes :id, :comments_count

          def comments_count
            builder.set("comments_count", "count(*)") do |s|
              Comment.where(post_id: s.id)
            end
          end
        end
        post = Post.first
        post2 = Post.second
        json = PostSerializerWithCount.new(Post.limit(2)).serialize
        expect(json).to eq("[{\"id\" : #{post.id}, \"comments_count\" : #{post.comments.count}},
                             {\"id\" : #{post2.id}, \"comments_count\" : #{post2.comments.count}}]"
                             .squish.chomp)
      end
      it "should properly serialize relations" do
        class PostSerializerWithComments < PGJsonSerializerBase
          attributes :id
          has_many :comments
        end
        post = Post.first
        post2 = Post.second
        json = PostSerializerWithComments.new(Post.limit(2)).serialize
        expect(JSON.parse(json)).to eq(JSON.parse("[{\"id\" : #{post.id}, \"comments\" : #{post.comments.to_json}},
                                                   {\"id\" : #{post2.id}, \"comments\" : #{post2.comments.to_json}}]"))
      end
      it "should properly serialize relations and sets in the same serializer" do
        class ComplexPostSerializer < PGJsonSerializerBase
          attributes :id, :comments_count
          has_many :comments

          def comments_count
            builder.set("comments_count", "count(*)") do |s|
              Comment.where(post_id: s.id)
            end
          end
        end
        post = Post.first
        post2 = Post.second
        json = ComplexPostSerializer.new(Post.limit(2)).serialize
        expect(JSON.parse(json)).to eq(JSON.parse("[{\"id\" : #{post.id}, \"comments_count\" : #{post.comments.count}, \"comments\" : #{post.comments.to_json}},
                                                   {\"id\" : #{post2.id}, \"comments_count\" : #{post2.comments.count}, \"comments\" : #{post2.comments.to_json}}]"))
      end
    end
  end
end
