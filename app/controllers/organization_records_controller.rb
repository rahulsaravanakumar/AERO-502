# Shared create, rename, archive and restore actions for projects, teams and
# subteams. Subclasses name the model, its parent field and who may manage it.
class OrganizationRecordsController < ApplicationController
     before_action :require_sign_in
     before_action :ensure_leader
     before_action :set_record, only: %i[edit update archive restore]
     before_action :ensure_can_manage_record, only: %i[edit update archive restore]

     helper_method :parent_field, :parent_options, :record_label

     def new
          @record = model_class.new(parent_field ? { parent_field => params[parent_field] } : {})
          return deny_organization_access unless can_manage?(@record)

          render "organization/form"
     end

     def create
          @record = model_class.new(record_params)
          return deny_organization_access unless can_manage?(@record)

          save_record("created")
     end

     def edit
          render "organization/form"
     end

     def update
          @record.assign_attributes(record_params)
          return deny_organization_access unless can_manage?(@record)

          save_record("updated")
     end

     def archive
          @record.archive!
          redirect_to organization_path, notice: "#{record_label} “#{@record.name}” was archived."
     end

     def restore
          @record.restore!
          redirect_to organization_path, notice: "#{record_label} “#{@record.name}” was restored."
     end

     private

     def ensure_leader
          deny_access unless current_user.leader?
     end

     def set_record
          @record = model_class.find(params[:id])
     end

     def ensure_can_manage_record
          deny_organization_access unless can_manage?(@record)
     end

     def deny_organization_access
          redirect_to organization_path, alert: "You can manage only your own team's subteams."
     end

     def save_record(verb)
          if @record.save
               redirect_to organization_path, notice: "#{record_label} “#{@record.name}” was #{verb}."
          else
               render "organization/form", status: :unprocessable_entity
          end
     end

     def record_params
          params.require(model_class.model_name.param_key).permit(:name, *parent_field)
     end

     def record_label
          model_class.model_name.human
     end

     def can_manage?(_record)
          current_user.chief_engineer?
     end
end
