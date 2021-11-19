class UpdateColumnsJob < ApplicationJob
  queue_as :dradis_project

  def perform(project_id:)
    project = Project.find(project_id)
    key = "projects.#{project.id}.issue_columns"

    last_written = Rails.cache.read(key)&.fetch(:last_write)

    # This makes sure in the event of multiple items in the queue we don't
    # process an earlier queue item before the last as this should be a latest
    # value wins operation.
    return if last_written && enqueued_at && (last_written > enqueued_at)

    # Enqueued_at is blank if this was called with perform_now
    written_at = enqueued_at || Time.now.utc.iso8601
    columns = project.issues.map(&:fields).map(&:keys).uniq.flatten | ['Title', 'Tags', 'Affected', 'Created', 'Created by', 'Updated']
    Rails.cache.write(key, { columns: columns, last_write: written_at })

    columns
  end
end
