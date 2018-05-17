require 'active_support'
require 'active_support/inflector'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'json'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req,@res = req,res
    @params = route_params.merge(req.params)
    @already_built_response = false
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

    session.store_session(res)

    @already_built_response = true

    nil
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise 'Already built response!' if already_built_response?


    res.write(content)
    res['Content-Type'] = content_type
    session.store_session(res)

    @already_built_response = true

    nil
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.name.underscore
    path = "views/#{controller_name}/#{template_name}.html.erb"
    content = ERB.new(File.read(path)).result(binding)
    content_type = 'text/html'
    render_content(content, content_type)
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?

    nil
  end
  def controller_name
    self.class.to_s.underscore
  end
end
