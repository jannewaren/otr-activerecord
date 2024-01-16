module OTR
  module ActiveRecord
    #
    # Rack middleware that returns active db connections to the connection pool after a request completes.
    #
    class ConnectionManagement
      def initialize(app)
        @app = app
      end

      def call(env)
        testing = env['rack.test'] == true

        resp = @app.call env
        resp[2] = ::Rack::BodyProxy.new resp[2] do
          clear_active_connections! unless testing
        end
        resp

      rescue Exception
        clear_active_connections! unless testing
        raise
      end

      def clear_active_connections!
        if ::ActiveRecord::VERSION::MAJOR < 7
          ::ActiveRecord::Base.clear_active_connections!
        else
          ::ActiveRecord::Base.connection_handler.clear_active_connections!
        end
      end
    end
  end
end
