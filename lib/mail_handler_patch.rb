require_dependency 'mail_handler'
module HelpdeskRequiredCfIgnore
  module MailHandlerPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method :receive_issue_without_ignore, :receive_issue
        alias_method :receive_issue, :receive_issue_with_ignore
      end
    end

    module InstanceMethods
      def receive_issue_with_ignore
        project = target_project
        # check permission
        unless handler_options[:no_permission_check]
          raise UnauthorizedAction unless user.allowed_to?(:add_issues, project)
        end

        issue = Issue.new(:author => user, :project => project)
        attributes = issue_attributes_from_keywords(issue)
        if handler_options[:no_permission_check]
          issue.tracker_id = attributes['tracker_id']
          if project
            issue.tracker_id ||= project.trackers.first.try(:id)
          end
        end
        issue.safe_attributes = attributes
        issue.safe_attributes = {'custom_field_values' => custom_field_values_from_keywords(issue)}
        issue.subject = cleaned_up_subject
        if issue.subject.blank?
          issue.subject = '(no subject)'
        end
        issue.description = cleaned_up_text_body
        issue.start_date ||= User.current.today if Setting.default_issue_start_date_to_creation_date?
        issue.is_private = (handler_options[:issue][:is_private] == '1')

        # add To and Cc as watchers before saving so the watchers can reply to Redmine
        add_watchers(issue)
        issue.save!(:validate => false)
        add_attachments(issue)
        logger.info "MailHandler: issue ##{issue.id} created by #{user}" if logger
        issue

      end
    end # module InstanceMethods
  end # module MailHandlerPatch
end # module HelpdeskRequiredCfIgnore

# Add module to MailHandler class
MailHandler.send(:include, HelpdeskRequiredCfIgnore::MailHandlerPatch)
