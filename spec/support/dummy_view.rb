require "action_view"

class DummyView < ActionView::Base
  module FakeRequest
    class Request
      attr_accessor :path,
                    :fullpath,
                    :protocol,
                    :host_with_port,
                    :_request_method
      def get?
        return true if _request_method.nil?

        _request_method == "GET"
      end

      def post?
        return false if _request_method.nil?

        _request_method == "POST"
      end

      def put?
        return false if _request_method.nil?

        _request_method == "PUT"
      end

      def patch?
        return false if _request_method.nil?

        _request_method == "PATCH"
      end

      def delete?
        return false if _request_method.nil?

        _request_method == "DELETE"
      end

      def head?
        return false if _request_method.nil?

        _request_method == "HEAD"
      end
    end
    def request
      @request ||= Request.new
    end
    def params
      @params ||= {}
    end
  end

  include FakeRequest
  include ActionView::Helpers::UrlHelper
  include Loaf::ViewExtensions

  def initialize
    context = ActionView::LookupContext.new([])
    assigns = {}
    controller = nil
    super(context, assigns, controller)
  end

  attr_reader :_breadcrumbs

  routes = ActionDispatch::Routing::RouteSet.new
  routes.draw do
    get "/" => "foo#bar", :as => :home
    get "/posts" => "foo#posts"
    get "/posts/:title" => "foo#posts"
    get "/post/:id" => "foo#post", :as => :post
    get "/post/:title" => "foo#title"
    get "/post/:id/comments" => "foo#comments"

    namespace :blog do
      get "/" => "foo#bar"
    end
  end

  include routes.url_helpers

  def set_path(path)
    request.path = path
    request.fullpath = path
    request.protocol = "http://"
    request.host_with_port = "www.example.com"
  end

  def set_request_method(method)
    request._request_method = method.upcase.to_s
  end
end
