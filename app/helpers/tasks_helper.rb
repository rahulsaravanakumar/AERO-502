module TasksHelper
     def estimate_label(hours)
          return "Not estimated" if hours.nil?

          pluralize(number_with_precision(hours, precision: 2, strip_insignificant_zeros: true), "hour")
     end
end
