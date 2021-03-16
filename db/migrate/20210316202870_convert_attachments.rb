class ConvertAttachments < ActiveRecord::Migration[6.1]
  class MigrationAttachment
    AttachmentPwd = Rails.root.join('attachments')

    def self.all(&block)
      Dir.foreach(AttachmentPwd) do |foldername|
        next if foldername == '.' or foldername == '..'

        Dir.foreach(AttachmentPwd.join(foldername)) do |attachment|
          next if attachment == '.' or attachment == '..'
          block.call(foldername, attachment)
        end
      end
    end
  end

  def up
    MigrationAttachment.all do |foldername, attachment|
      n = Node.find(foldername)
      file = MigrationAttachment::AttachmentPwd.join(foldername, attachment)
      n.attachments.attach(io: File.open(file), filename: attachment)

      FileUtils.rm(file)
    end

    FileUtils.rm_rf(MigrationAttachment::AttachmentPwd)
  end

  def down
    FileUtils.mkdir_p(MigrationAttachment::AttachmentPwd)

    ActiveStorage::Attachment.all.each do |attachment|
      folder = MigrationAttachment::AttachmentPwd.join(attachment.record_id.to_s)
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
