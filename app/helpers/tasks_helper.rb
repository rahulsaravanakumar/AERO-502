module TasksHelper
     def estimate_label(hours)
          return "Not estimated" if hours.nil?

          pluralize(number_with_precision(hours, precision: 2, strip_insignificant_zeros: true), "hour")
     end

     # Describes actual minus estimated hours in words.
     def variance_label(difference)
          return "On estimate" if difference.zero?

          "#{estimate_label(difference.abs)} #{difference.positive? ? "over" : "under"} estimate"
     end
end
