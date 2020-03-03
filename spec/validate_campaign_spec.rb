require File.expand_path("../../lib/services/ad_service/validate_campaign.rb", __FILE__)
require 'rspec'

RSpec.describe AdService::ValidateCampaign, type: :service do
    let(:campaign_no_errors) { AdService::Campaign.new(true) }
    let(:campaign_with_errors) { AdService::Campaign.new(false) }

    it 'gathers the campaign data' do
      data = campaign_no_errors.get_campaigns
      expect(data).not_to eq({})
    end
  
    it 'gathers the ad service data' do
      validator = AdService::ValidateCampaign.new(campaign_no_errors)
      data = validator.get_campaign_ad_service
      # for this particular case
      expect(data).to eq({"ads"=>[{"reference"=>"1", "status"=>"enabled", "description"=>"Description for campaign 11"}, {"reference"=>"2", "status"=>"disabled", "description"=>"Description for campaign 12"}, {"reference"=>"3", "status"=>"enabled", "description"=>"Description for campaign 13"}]})
    end

    it "returns empty no errors" do
      validator = AdService::ValidateCampaign.new(campaign_no_errors).call
      expect(validator).to eq([])
    end

    it "returns non empty with errors" do
      validator = AdService::ValidateCampaign.new(campaign_with_errors).call
      expect(validator).to eq([{:remote_reference=>"2", :discrepancies=>[{"status"=>{:remote=>"disabled", :local=>"paused"}}]}, {:remote_reference=>"3", :discrepancies=>[{"description"=>{:remote=>"Description for campaign 13", :local=>"Description for campaign 1223"}}]}])
    end

end