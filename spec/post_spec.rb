require "spec_helper"

describe Post do
  let(:post) do
    Post.new <<-TEXT
      title: Title
      date: 2010-10-10

      Content, and some more __content__.
    TEXT
  end

  describe "#title" do
    subject { post.title }
    it { should == "Title" }
  end

  describe "#body" do
    subject { post.body }
    it { should == "Content, and some more __content__." }
  end

  describe "#slug" do
    subject { post.slug }
    it { should == "title" }

    context "when specified on metadata" do
      let(:post) do
        Post.new <<-POST
          title: Post
          date: 2010-10-10
          slug: a-nice-post

          Content
        POST
      end

      it { should == "a-nice-post" }
    end
  end

  describe "#date" do
    subject { post.date }
    it { should == Date.parse("2010-10-10") }
  end

  describe "#path" do
    subject { post.path }

    it { should == "/2010/10/10/title" }

    context "when the post has no date" do
      before { post.date = nil }
      it { should == "/draft/title" }
    end
  end

  describe "#published?" do
    subject { post.published? }

    context "when the post has a date" do
      before { post.date = Date.today }
      it { should be_true }
    end

    context "when the post has no date" do
      before { post.date = nil }
      it { should be_false }
    end
  end

  describe "#cache_key" do
    subject { post.cache_key }

    it "is the sha1 of the body" do
      should == Digest::SHA1.hexdigest(post.body)
    end
  end
end
