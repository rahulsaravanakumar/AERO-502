# Archived records leave everyday lists but keep their tasks and hours.
module Archivable
     extend ActiveSupport::Concern

     included do
          scope :active, -> { where(archived_at: nil) }
          scope :archived, -> { where.not(archived_at: nil) }
     end

     def archived?
          archived_at.present?
     end

     def archive!
          update!(archived_at: Time.current)
     end

     def restore!
          update!(archived_at: nil)
     end
end
