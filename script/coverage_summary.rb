# Prints a Markdown coverage report from SimpleCov's JSON output.
# CI appends it to the GitHub Actions job summary so the coverage
# percentage and per-file breakdown can be viewed and screenshotted.
require "json"

report_path = File.expand_path("../coverage/coverage.json", __dir__)

unless File.exist?(report_path)
     puts "## Test coverage", "", "No coverage results were found. Run `bundle exec rspec` first."
     exit
end

report = JSON.parse(File.read(report_path))
totals = report.fetch("total")

def percent(value)
     "#{value.to_f.round(2)}%"
end

def missed_lines(file)
     file.fetch("lines").each_with_index.filter_map { |hits, index| index + 1 if hits&.zero? }
end

def missed_branches(file)
     file.fetch("branches", []).select { |branch| branch["coverage"].zero? }
                               .map { |branch| "#{branch["report_line"]} (#{branch["type"]})" }
end

puts "## Test coverage"
puts
puts "| Metric | Covered | Total | Coverage |"
puts "| --- | ---: | ---: | ---: |"
%w[lines branches].each do |metric|
     total = totals.fetch(metric)
     puts "| #{metric.capitalize} | #{total["covered"]} | #{total["total"]} | #{percent(total["percent"])} |"
end
puts
puts "### Coverage by file"
puts
puts "| File | Lines | Line coverage | Branches | Branch coverage | Not covered |"
puts "| --- | ---: | ---: | ---: | ---: | --- |"
report.fetch("coverage").sort.each do |path, file|
     gaps = missed_lines(file).map { |line| "line #{line}" } + missed_branches(file).map { |branch| "branch #{branch}" }
     puts "| `#{path}` | #{file["covered_lines"]}/#{file["total_lines"]} | " \
          "#{percent(file["lines_covered_percent"])} | " \
          "#{file["covered_branches"]}/#{file["total_branches"]} | " \
          "#{percent(file["branches_covered_percent"])} | #{gaps.empty? ? "—" : gaps.join(", ")} |"
end
