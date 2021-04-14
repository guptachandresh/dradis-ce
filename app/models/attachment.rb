=begin
**
** attachment.rb
** 7 March 2009
**
** Desc:
** This class in an abstraction layer to the attachments folder. It allows
** access to the folder content in a way that mimics the working of ActiveRecord
**
** The Attachment class inherits from the ruby core File class
**
** License:
**   See LICENSE.txt for copyright and licensing information.
**
=end


# ==Description
# This class in an abstraction layer to the <tt>attachments/</tt> folder. It allows
# access to the folder content in a way that mimics the working of ActiveRecord
#
# The Attachment class inherits from the ruby core File class
#
# Folder structure
# The attachement folder structure example:
# AttachmentPWD
#    |
#    - 1     - this directory level represents the nodes, folder name = node id
#    |   |
#    |   - 3.image.gif
#    |   - 4.another_image.gif
#    |
#    - 2
#        |
#        - 1.icon.gif
#        - 2.another_icon.gif
#
# ==General usage
#   attachment = Attachment.new("images/my_image.gif", :node_id => 1)
#
# This will create an instance of an attachment that belongs to node with ID = 0
# Nothing has been saved yet
#
#   attachment.save
#
# This will save the attachment in the attachment directory structure
#
# You can inspect the saved instance:
#   attachment.node_id
#   attachment.id
#   attachment.filename
#   attachment.fullpath
#
#   attachments = Attachment.find(:all)
# Creates an array instance that contains all the attachments
#
#   Attachment.find(:all, :conditions => {:node_id => 1})
# Creates an array instance that contains all the attachments for node with ID=1
#
#   Attachment.find('test.gif', :conditions => {:node_id => 1})
# Retrieves the test.gif image that is associated with node 1

class Attachment < File
  require 'fileutils'
  # Set the path to the attachment storage
  AttachmentPwd = Rails.env.test? ? Rails.root.join('tmp', 'storage') : Rails.root.join('storage')

  # -- Class Methods  ---------------------------------------------------------
  def self.all(*args)
    find(:all, *args)
  end

  def self.create(*args)
    new(*args).save
  end

  def self.count
    find(:all).count
  end

  def self.find_by(filename:, node_id:)
    find(filename, conditions: { node_id: node_id } )
  rescue StandardError
  end

  # Return the attachment instance(s) based on the find parameters
  def self.find(*args)
    options = args.extract_options!

    # makes the find request and stores it to resources
    case args.first
    when :all, :first, :last
      attachments = []
      if options[:conditions] && options[:conditions][:node_id]
        node_id = options[:conditions][:node_id].to_s
        raise "Node with ID=#{node_id} does not exist" unless Node.exists?(node_id)
        attachments = ActiveStorage::Attachment.new(record_id: node_id.to_i, record_type: 'Node')
      else
        attachments = ActiveStorage::Attachment.all.order(:filename)
      end

      # return based on the request arguments
      case args.first
      when :first
        attachments.first
      when :last
        attachments.last
      else
        attachments
      end
    else
      # in this routine we find the attachment by file name and node id
      filename = args.first
      raise "You need to supply a node id in the condition parameter" unless options[:conditions] && options[:conditions][:node_id]

      node_id = options[:conditions][:node_id].to_s
      raise "Node with ID=#{node_id} does not exist" unless Node.exists?(node_id)

      attachment = ActiveStorage::Attachment.
        joins(:blob).
        where(
          'active_storage_blobs.filename': filename,
          record_type: 'Node',
          record_id: node_id
        ).first
      raise "Could not find Attachment with filename #{filename}" unless attachment

      attachment
    end
  end

  def self.model_name
    ActiveModel::Name.new(self)
  end
end
