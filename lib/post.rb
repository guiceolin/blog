require "date"
require "digest/sha1"

class Post
  extend Enumerable

  attr_accessor :metadata, :title, :body, :date, :author

  def self.files
    Dir["posts/*.md"]
  end

  def self.each
    files.each do |entry|
      File.open(entry) { |file| yield Post.new(file.read) }
    end
  end

  def self.all
    published.sort_by(&:date).reverse
  end

  def self.find_by_slug(slug)
    find { |post| post.slug == slug }
  end

  def self.published
    find_all(&:published?)
  end

  def initialize(data)
    yaml, @body = data.split(/\n\n/, 2)

    @metadata = YAML.load(yaml)

    @title  = @metadata["title"]
    @body   = @body.strip
    @date   = @metadata["date"]
    @author = @metadata["author"]
  end

  def slug
    @slug ||= @metadata["slug"] || title.to_slug.normalize
  end

  def path
    @path ||= published?? date.strftime("/%Y/%m/%d/#{slug}") : "/draft/#{slug}"
  end

  def published?
    !!@date
  end

  def cache_key
    Digest::SHA1.hexdigest body
  end
end
