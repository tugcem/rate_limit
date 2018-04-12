module Middleware
  class RateLimiter
    def initialize app
      @app = app
    end

    def call env
      increment_request_count env
      @app.call env
    end

    def increment_request_count env
      client_ip = env['REMOTE_ADDR']
      REDIS.get(client_ip) ? REDIS.incr(client_ip) : REDIS.set(client_ip, 1)
    end
  end
end
