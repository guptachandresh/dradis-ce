module Dradis::CE::API
  module V1
    class AttachmentsController < Dradis::CE::API::APIController
      include ActivityTracking
      include Dradis::CE::API::ProjectScoped

      before_action :set_node

      skip_before_action :json_required, :only => [:create]

      def index
        @attachments = @node.attachments
      end

      def show
        begin
          @attachment = Attachment.find(params[:filename], conditions: { node_id: @node.id } )
        rescue
          raise ActiveRecord::RecordNotFound, "Couldn't find attachment with filename '#{params[:filename]}'"
        end
      end

      def create
        uploaded_files = params.fetch(:files, [])

        @attachments = []
        uploaded_files.each do |uploaded_file|
          attachment_name = NamingService.name_file(
            original_filename: uploaded_file.original_filename,
          )

          @node.attachments.attach(io: uploaded_file, filename: attachment_name)
          attachment = @node.attachments.last

          @attachments << attachment
        end

        if @attachments.any? && @attachments.count == uploaded_files.count
          render status: 201
        else
          render status: 422
        end
      end

      def update
        @attachment = Attachment.find(params[:filename], conditions: { node_id: @node.id } )
        new_name = CGI::unescape(attachment_params[:filename])

        existing_attachment = ActiveStorage::Attachment.joins(:blob).where(
          'active_storage_blobs.filename': new_name,
          record_id: @node.id,
          record_type: 'Node'
        ).first

        if !existing_attachment
          @attachment.update(filename: new_name)
          render status: 200
        else
          render status: 422
        end
      end

      def destroy
        @attachment = Attachment.find(params[:filename], conditions: { node_id: @node.id} )
        @attachment.destroy

        render_successful_destroy_message
      end

      private

      def set_node
        @node = current_project.nodes.find(params[:node_id])
      end

      def attachment_params
        params.require(:attachment).permit(:filename)
      end
    end
  end
end
