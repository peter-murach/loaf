# encoding: utf-8

RSpec.describe Loaf::ViewExtensions, "#breadcrumb_trail" do
  it "doesn't configure any breadcrumbs by default" do
    view = DummyView.new

    expect(view.breadcrumb_trail.to_a).to be_empty
  end

  it "resolves breadcrumb paths" do
    view = DummyView.new
    view.breadcrumb("home", :home_path)
    view.breadcrumb("posts", :posts_path)
    view.set_path("/posts")

    yielded = []
    block = -> (crumb) { yielded << crumb.to_a }
    view.breadcrumb_trail(&block)

    expect(yielded).to eq([
      ["home", "/", false],
      ["posts", "/posts", true]
    ])
  end

  it "matches current path with :inclusive option as default" do
    view = DummyView.new
    view.breadcrumb("home", :home_path)
    view.breadcrumb("posts", :posts_path)
    view.set_path("/posts?id=73-title")

    yielded = []
    block = -> (crumb) { yielded << crumb.to_a }
    view.breadcrumb_trail(&block)

    expect(yielded).to eq([
      ["home", "/", false],
      ["posts", "/posts", true]
    ])
  end

  it "matches current path with :inclusive when query params" do
    view = DummyView.new
    view.breadcrumb("posts", "/posts", match: :inclusive)
    view.set_path("/posts?foo=bar")

    expect(view.breadcrumb_trail.map(&:to_a)).to eq([["posts", "/posts", true]])
  end

  it "matches current path with :inclusive when nested" do
    view = DummyView.new
    view.breadcrumb("posts", "/posts", match: :inclusive)
    view.set_path("/posts/1/comment")

    expect(view.breadcrumb_trail.map(&:to_a)).to eq([["posts", "/posts", true]])
  end

  it "doesn't match with :inclusive when unrelated path" do
    view = DummyView.new
    view.breadcrumb("posts", "/posts", match: :inclusive)
    view.set_path("/post/1")

    expect(view.breadcrumb_trail.map(&:to_a)).to eq([["posts", "/posts", false]])
  end

  it "matches current path with :inclusive when extra trailing slash" do
    view = DummyView.new
    view.breadcrumb("posts", "/posts/", match: :inclusive)
    view.set_path("/posts")

    expect(view.breadcrumb_trail.map(&:to_a)).to eq([["posts", "/posts/", true]])
  end

  it "matches current path with :inclusive when absolute path" do
    view = DummyView.new
    view.breadcrumb("posts", "http://www.example.com/posts/", match: :inclusive)
    view.set_path("/posts")

    expect(view.breadcrumb_trail.map(&:to_a)).to eq([
      ["posts", "http://www.example.com/posts/", true]
    ])
  end

  it "matches current path with :exact when trailing slash" do
    view = DummyView.new
    view.breadcrumb("posts", "/posts/", match: :exact)
    view.set_path("/posts")

    expect(view.breadcrumb_trail.map(&:to_a)).to eq([["posts", "/posts/", true]])
  end

  it "fails to match current path with :exact when nested" do
    view = DummyView.new
    view.breadcrumb("posts", "/posts", match: :exact)
    view.set_path("/posts/1/comment")

    expect(view.breadcrumb_trail.map(&:to_a)).to eq([["posts", "/posts", false]])
  end

  it "fails to match current path with :exact when query params" do
    view = DummyView.new
    view.breadcrumb("posts", "/posts", match: :exact)
    view.set_path("/posts?foo=bar")

    expect(view.breadcrumb_trail.map(&:to_a)).to eq([["posts", "/posts", false]])
  end

  it "matches current path with :exclusive option when query params" do
    view = DummyView.new
    view.breadcrumb("posts", "/posts", match: :exclusive)
    view.set_path("/posts?foo=bar")

    expect(view.breadcrumb_trail.map(&:to_a)).to eq([["posts", "/posts", true]])
  end

  it "fails to match current path with :exclusive option when nested" do
    view = DummyView.new
    view.breadcrumb("posts", "/posts", match: :exclusive)
    view.set_path("/posts/1/comment")

    expect(view.breadcrumb_trail.map(&:to_a)).to eq([["posts", "/posts", false]])
  end

  it "matches current path with regex option when query params" do
    view = DummyView.new
    view.breadcrumb("posts", "/posts", match: %r{/po})
    view.set_path("/posts?foo=bar")

    expect(view.breadcrumb_trail.map(&:to_a)).to eq([["posts", "/posts", true]])
  end

  it "matches current path with query params option" do
    view = DummyView.new
    view.breadcrumb("posts", "/posts", match: {foo: :bar})
    view.set_path("/posts?foo=bar&baz=boo")

    expect(view.breadcrumb_trail.map(&:to_a)).to eq([["posts", "/posts", true]])
  end

  it "fails to match current path with query params option" do
    view = DummyView.new
    view.breadcrumb("posts", "/posts", match: {foo: :bar})
    view.set_path("/posts?foo=2&baz=boo")

    expect(view.breadcrumb_trail.map(&:to_a)).to eq([["posts", "/posts", false]])
  end

  it "overrides breadcrumb :inclusive match option with :exclusive" do
    view = DummyView.new
    view.breadcrumb("posts", "/posts", match: :inclusive)
    view.set_path("/posts/1/comment")

    yielded = []
    block = ->(crumb) { yielded << crumb.to_a }
    view.breadcrumb_trail(match: :exclusive, &block)

    expect(yielded).to eq([["posts", "/posts", false]])
  end

  it "overrides default :inclusive match option with :exact" do
    view = DummyView.new
    view.breadcrumb("posts", :posts_path)
    view.set_path("/posts/1/comment")

    yielded = []
    block = ->(crumb) { yielded << crumb.to_a }
    view.breadcrumb_trail(match: :exact, &block)

    expect(yielded).to eq([["posts", "/posts", false]])
  end

  it "fails to recognize the match option" do
    view = DummyView.new
    view.breadcrumb("posts", "http://www.example.com/posts/", match: :boom)
    view.set_path("/posts")
    block = -> (*args) { }
    expect {
      view.breadcrumb_trail(&block)
    }.to raise_error(ArgumentError, "Unknown `:boom` match option!")
  end

  it "forces current path" do
    view = DummyView.new
    view.breadcrumb("home", :home_path)
    view.breadcrumb("posts", :posts_path, match: :force)
    view.set_path("/")

    yielded = []
    block = -> (crumb) { yielded << crumb.to_a }
    view.breadcrumb_trail(&block)

    expect(yielded).to eq([
      ["home", "/", true],
      ["posts", "/posts", true]
    ])
  end

  it "returns enumerator without block" do
    view = DummyView.new
    view.breadcrumb("home", :home_path)
    view.breadcrumb("posts", :posts_path)
    view.set_path("/posts")

    result = view.breadcrumb_trail

    expect(result).to be_a(Enumerable)
    expect(result.take(2).map(&:to_a)).to eq([
      ["home", "/", false],
      ["posts", "/posts", true]
    ])
  end

  it "validates passed options" do
    view = DummyView.new
    block = -> (name, url, styles) {  }
    expect {
      view.breadcrumb_trail(unknown: true, &block)
    }.to raise_error(Loaf::InvalidOptions)
  end

  it "permits arbitrary length crumb names" do
    view = DummyView.new
    view.breadcrumb("<span class='fa fa-home'></span>", :home_path)
    view.set_path("/posts")

    yielded = []
    block = -> (crumb) { yielded << crumb.to_a }
    view.breadcrumb_trail(&block)

    expect(yielded).to eq([
      ["<span class='fa fa-home'></span>", "/", false]
    ])
  end

  it "uses global configuration for crumb formatting" do
    view = DummyView.new
    view.breadcrumb("home-sweet-home", :home_path)
    view.breadcrumb("posts-for-everybody", :posts_path)
    view.set_path("/posts")

    yielded = []
    block = -> (crumb) { yielded << crumb.to_a }
    view.breadcrumb_trail(&block)

    expect(yielded).to eq([
      ["home-sweet-home", "/", false],
      ["posts-for-everybody", "/posts", true]
    ])
  end

  it "overwrites global configuration" do
    view = DummyView.new
    view.breadcrumb("home-sweet-home", :home_path)
    view.breadcrumb("posts-for-everybody", :posts_path)
    view.set_path("/posts/1")

    yielded = []
    block = -> (crumb) { yielded << crumb.to_a }
    view.breadcrumb_trail(match: :exact, &block)

    expect(yielded).to eq([
      ["home-sweet-home", "/", false],
      ["posts-for-everybody", "/posts", false]
    ])
  end

  it "allows to enumerate all breadcrumb properties individually" do
    view = DummyView.new
    links = {
     "Home" => :home_path,
     "Posts" => :posts_path,
     "Edit post" => "/posts/1"
    }
    links.each do |name, url|
      view.breadcrumb(name, url)
    end
    view.set_path("/posts/1")

    expect(view.breadcrumb_trail.map(&:name)).to eq(links.keys)
    expect(view.breadcrumb_trail.map(&:url)).to eq(%w[/ /posts /posts/1])
    expect(view.breadcrumb_trail(match: :exact).map(&:current?)).to eq([false, false, true])
  end

  it "matches the current path with :request_methods set to custom" do
    view = DummyView.new
    view.breadcrumb("posts", "/posts", request_methods: %i[get post])
    view.set_path("/posts")
    view.set_request_method(:post)

    trail = view.breadcrumb_trail.map(&:to_a)
    expect(trail).to eq([["posts", "/posts", true]])
  end

  it "fails to match current path with :request_methods set to default" do
    view = DummyView.new
    view.breadcrumb("posts", "/posts")
    view.set_path("/posts")
    view.set_request_method(:post)

    trail = view.breadcrumb_trail.map(&:to_a)
    expect(trail).to eq([["posts", "/posts", false]])
  end

  it "matches current path with :request_methods set to :all" do
    view = DummyView.new
    view.breadcrumb("posts", "/posts", request_methods: :all)
    view.set_path("/posts")
    view.set_request_method(:delete)

    trail = view.breadcrumb_trail.map(&:to_a)
    expect(trail).to eq([["posts", "/posts", true]])
  end
end
