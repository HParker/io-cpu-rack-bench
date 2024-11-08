require 'csv'

files = Dir["out/puma-*-50-report.csv"]

puts files.size

output = []

files.each do |file_name|
  results = CSV.readlines(file_name, headers: true)

  total_time = results.map { |r| r["response-time"].to_f }.sum

  row_count = results.size.to_f

  if row_count > 0
    avg = total_time / results.size.to_f
  end

  match = file_name.match(/out\/puma-io-([0-9]+)-cpu-([0-9]+)-p-([0-9]+)-t-([0-9]+)-w-([0-9]+)-report.csv/)

  io = match[1]
  cpu = match[2]
  processes = match[3]
  threads = match[4]
  workers = match[5]


  total_elapsed = results.dig(-1, "offset")&.to_f

  if total_elapsed && avg
    output << { processes:, threads:, io:, cpu:, workers:, avg:, rps: row_count / results[-1]["offset"].to_f }
  else
    # output << { processes:, threads:, io:, cpu:, workers:, avg:, rps: 0 }
  end
end

sorted_output = output.sort_by { |r|
  [r[:io].to_i, r[:cpu].to_i, r[:processes].to_i, r[:threads].to_i]
}

puts sorted_output.size

sorted_output.each do |r|
  if r[:cpu] == "10" && (r[:processes] == "1" && r[:threads] == "32" || r[:processes] == "32" && r[:threads] == "1")
    puts "io:cpu #{r[:io]}:#{r[:cpu]} p: #{r[:processes]}, t: #{r[:threads]} - rps: #{r[:rps]}, avg: #{r[:avg]}"
  end
end
