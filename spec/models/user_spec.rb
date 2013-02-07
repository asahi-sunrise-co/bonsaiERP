require 'spec_helper'

describe User do

  it { should have_many(:links) }
  it { should have_many(:active_links) }
  it { should have_many(:links) }

  before(:each) do
  end

  let(:valid_attributes)do
    {email: 'demo@example.com', password: 'demo1234'}
  end

  it 'should not create' do
    expect{ User.create!(params)}.to raise_error
  end

  it '#set_confirmation_token' do
    u = User.new
    u.confirmation_token.should be_nil
    
    u.set_confirmation_token

    u.confirmation_token.should_not be_blank
  end

  context "Update methods" do
    subject { User.new }
    before(:each) do
      User.any_instance.stub(save: true)
    end

    it "#set_auth_token" do
      subject.auth_token.should be_nil

      subject.set_auth_token.should be_true
      subject.auth_token.should_not be_blank
    end

    it "#reset_auth_token" do
      subject.auth_token = "jajjajaja"
      subject.auth_token.should_not be_blank

      subject.reset_auth_token.should be_true
      subject.auth_token.should be_blank
    end
  end

  context "Tenant" do
    before(:each) do
      OrganisationSession.organisation = build :organisation, id: 100
    end

    it "creates the methods for each rol" do
      u = User.new {|us| us.id = 10}
      u.stub_chain(:active_links, find_by_organisation_id: Link.new(active:true, user_id: u.id, rol:'') )

      u.link_rol = 'admin'

      u.should be_is_admin
      u.should_not be_is_group
      u.should_not be_is_other


      u.link_rol = 'group'

      u.should be_is_group
      u.should_not be_is_admin
      u.should_not be_is_other


      u.link_rol = 'other'

      u.should be_is_other
      u.should_not be_is_admin
      u.should_not be_is_group
    end
  end
end
