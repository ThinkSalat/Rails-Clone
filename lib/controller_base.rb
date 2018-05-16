require 'active_support'
require 'active_support/inflector'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'json'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req,@res = req,res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise 'Already built response!' if already_built_response?
    res.status = 302
    res.location = url
    # res.set_cookie('_rails_lite_app',session['_rails_lite_app'])
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise 'Already built response!' if already_built_response?
    # res.set_cookie('_rails_lite_app',session['_rails_lite_app'])
    res.write(content)
    res['Content-Type'] = content_type
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.name.underscore
    path = "views/#{controller_name}/#{template_name}.html.erb"
    template = File.read(path)
    erb_template = ERB.new(template)
    content = erb_template.result(binding)
    content_type = 'text/html'
    render_content(content, content_type)
  end

  # method exposing a `Session` object
  def session
    # @session ||= Session.new(req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end
