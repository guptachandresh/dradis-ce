require 'rails_helper'

describe "Describe attachments" do
  it "should require authenticated users" do
    Configuration.create(name: 'admin:password', value: 'rspec_pass')
    node = create(:node)
    visit project_node_attachments_path(node.project, node)

    expect(current_path).to eq(login_path)
    expect(page).to have_content('Access denied.')
  end

  describe "as authenticated user" do
    before do
      login_to_project_as_user
      @node = create(:node, project: current_project)
    end

    it "stores the file on disk" do
      visit project_node_path(current_project, @node)

      file_path = Rails.root.join('spec/fixtures/files/rails.png')
      attach_file('files[]', file_path)
      click_button 'Start'

      expect(page).to have_content('rails.png')
      attachment = @node.attachments.first
      expect(File.exist?(ActiveStorage::Blob.service.path_for(attachment.key))).to be true
    end

    it "auto-renames the upload if an attachment with the same name already exists" do
      @node.attachments.attach(io: File.open(Rails.root.join('spec/fixtures/files/rails.png')), filename: 'rails.png')

      expect(@node.attachments.count).to eq(1)

      visit project_node_path(current_project, @node)

      file_path = Rails.root.join('spec/fixtures/files/rails.png')
      attach_file('files[]', file_path)
      click_button 'Start'

      expect(@node.attachments.count).to eq(2)
    end
  end
end
