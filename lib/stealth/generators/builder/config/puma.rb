threads_count = ENV.fetch("STEALTH_MAX_THREADS") { 5 }.to_i
threads threads_count, threads_count

# Specifies the `port` that Puma will listen on to receive requests, default is 3000.
#
port ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("STEALTH_ENV") { "development" }
