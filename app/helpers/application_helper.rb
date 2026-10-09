module ApplicationHelper
     # Active subteams labelled with their team, since names repeat across teams.
     def subteam_options(selected)
          subteams = Subteam.active.joins(:team).merge(Team.active).includes(:team).order("teams.name", :name)
          options_for_select(subteams.map { |subteam| [ subteam.full_name, subteam.id ] }, selected)
     end

     def field_error_id(record, attribute)
          "#{record.model_name.param_key}_#{attribute}_error"
     end

     # Accessibility attributes that tie an input to its error message.
     def field_error_attributes(record, attribute)
          return {} if record.errors[attribute].empty?

          { aria: { describedby: field_error_id(record, attribute), invalid: true } }
     end

     def field_error(record, attribute)
          return if record.errors[attribute].empty?

          tag.p(record.errors.full_messages_for(attribute).to_sentence,
                id: field_error_id(record, attribute), class: "field-error")
     end
end
