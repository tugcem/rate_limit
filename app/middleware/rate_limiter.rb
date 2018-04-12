RATE_LIMIT             = 100
RATE_LIMIT_EXPIRE_TIME = 3600

module Middleware
  class RateLimiter
    def initialize app
      @app = app
    end

    def call env
      client_ip env['REMOTE_ADDR']
      increment_request_count > RATE_LIMIT ? too_many_requests : @app.call(env)
    end

    private

    def client_ip ip=nil
      @client_ip ||= ip
    end

    def request_count
      REDIS.get(client_ip)&.to_i
    end

    def initialize_request_count
      REDIS.set(client_ip, 0)
      REDIS.EXPIRE(client_ip, RATE_LIMIT_EXPIRE_TIME)
    end

    def increment_request_count
      initialize_request_count unless request_count
      REDIS.incr(client_ip)&.to_i
    end

    def time_to_reset_counter
      REDIS.ttl(client_ip)
    end

    def too_many_requests
      [
        429,
        {},
        [
          "Rate limit exceeded. Try again in #{time_to_reset_counter} seconds"
        ]
      ]
    end
  end
end
