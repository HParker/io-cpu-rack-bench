require "active_record"

# ActiveRecord::Base.establish_connection(
#   adapter: 'trilogy',
#   host: 'localhost',
#   username: 'root',
#   database: 'blog_development'
#   # TODO: connection pooling
# )

# class Post < ActiveRecord::Base
# end

module Util
  class << self
    def fib(i: 20)
      if i <= 1
        i
      else
        fib(i: i - 1) + fib(i: i - 2)
      end
    end

    def post
      sleep 0.001
      # ::Post.find(rand(1..99))
    end

    # def posts
    #   ::Post.where(id: 10..30)
    # end
  end
end

CPU_TIME_UNIT = ((100.times.map { Benchmark.realtime { Util.fib } }).last(10).sum / 10.0) * 1000

IO_TIME_UNIT = ((100.times.map { Benchmark.realtime { Util.post } }).last(10).sum / 10.0) * 1000

puts "CPU_TIME_UNIT: #{CPU_TIME_UNIT}, IO_TIME_UNIT: #{IO_TIME_UNIT}"

class App
  def initialize
  end

  def call(env)
    request = Rack::Request.new(env)

    case request.path
    when "/empty"
      [200, {}, [""]]
    when "/"
      bench(request)
    end
  end

  private

  def bench(request)
    params = request.GET

    io_time = (params["io_time"] || "10").to_f
    cpu_time = (params["cpu_time"] || "10").to_f
    schedule = params["schedule"] || "mix"

    cpu_spend = 0.0
    io_spend = 0.0

    case schedule
    when "mix"
      while cpu_spend < cpu_time || io_spend < io_time
        if io_spend < io_time
          Util.post
          io_spend += IO_TIME_UNIT
        end
        if cpu_spend < cpu_time
          Util.fib
          cpu_spend += CPU_TIME_UNIT
        end
      end
    when "contiguous_cpu"
      while cpu_spend < cpu_time
        Util.fib
        cpu_spend += CPU_TIME_UNIT
      end

      sleep io_time / 1000.0
    end

    [200, {}, ["cpu: #{cpu_spend}/#{cpu_time}, io: #{io_spend}/#{io_time}"]]
  end
end
