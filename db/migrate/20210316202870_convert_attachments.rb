class ConvertAttachments < ActiveRecord::Migration[6.1]
  AttachmentPwd = Rails.root.join('attachments')

  def up
    Pathname.glob(AttachmentPwd.join('*', '**')).each do |attachment|
      node_id = attachment.to_s.split('/')[-2]
      node = Node.find(node_id)
      node.attachments.attach(io: File.open(attachment), filename: attachment.basename)

      FileUtils.rm(attachment)
    end

    FileUtils.rm_rf(AttachmentPwd)
  end

  def down
    FileUtils.mkdir_p(AttachmentPwd)

    ActiveStorage::Attachment.all.each do |attachment|
      folder = AttachmentPwd.join(attachment.record_id.to_s)
      filename = folder.join(attachment.filename.to_s)

      FileUtils.mkdir_p(folder)

      File.open(filename, 'wb') do |input|
        attachment.download { |chunk| input.write(chunk) }
      end

      attachment.destroy
    end

    FileUtils.rm_rf(Rails.root.join('storage'))
  end
end
