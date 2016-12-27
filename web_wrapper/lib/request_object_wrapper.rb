module RequestObjectWrapper

  def request_obj
    add_renderers \
    add_method_to_set_content_type \
    add_method_to_set_status_code \
    make_params_indifferent_access \
    request
  end

  def make_params_indifferent_access request
    request.define_singleton_method(:params) do
      super().with_indifferent_access
    end
    request
  end

  def add_renderers request
    return request if defined?(request.renderers)
    _renderers = method(:renderers)
    request.define_singleton_method(:renderers) do
      _renderers.call
    end
    request
  end

  def add_method_to_set_content_type request
    _set_content_type = method(:content_type)
    request.define_singleton_method(:"set_content_type") do |type|
      _set_content_type.call type
    end
    request
  end

  def add_method_to_set_status_code request
    _set_status_code = method(:status_code)
    request.define_singleton_method(:"set_status_code") do |type|
      _set_status_code.call type
    end
    request
  end

  def renderers
    OpenStruct.new(
      slim: method(:slim),
    )
  end

end
