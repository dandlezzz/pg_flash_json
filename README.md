# PgFlashJson

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pg_flash_json'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pg_flash_json

## Usage

PGFlashJSON turns your ActiveRecord relations into json using the power of postgres' json support.
It works by using the attributes of the model to build the proper postgres json query.

```ruby
	class Post < ActiveRecord::Base
		#attributes :id, :title, :content
	end

	PGJsonBuilder.new(Post.where(id: 1)).json
		# SELECT json_agg(
		#	json_build_object(
		#		'id', t582.id,
		#		'title', t582.title,
		#		'content', t582.content
		#	))
		#	as json
		#   FROM(SELECT "posts".* FROM "posts" WHERE "posts"."id" = 1)t582
```
This query is run and the aliases in the above example will be generated on the fly to ensure uniqueness.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pg_flash_json.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
