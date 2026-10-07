module TasksHelper
     # Links only http(s) addresses; anything else is shown as plain text.
     def external_link(url)
          return url unless url.to_s.match?(%r{\Ahttps?://}i)

          link_to url, url, target: "_blank", rel: "noopener"
     end

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
