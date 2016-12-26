module Routes

  def self.extended(base)
    base.class_exec do

      get '/' do
        Routes::Index.run(request_obj)
      end

      post '/' do
        Routes::PostMsg.run(request_obj)
      end

    end
  end

end
