require 'json'
require 'httparty'

module AdService
    class Campaign
        def initialize(without_errors)
            @without_errors = without_errors
        end

        def find_by_external_id(id)
            get_campaigns[:campaigns].select{ |n| n[:external_reference].to_i == id.to_i }.compact
        end
    
        def get_campaigns
            @without_errors ?
            {"campaigns": [
                {
                    "id": 11,
                    "job_id": 344,
                    "status": "enabled",
                    "external_reference": 1,
                    "ad_description": "Description for campaign 11"
                },
                {
                    "id": 12,
                    "job_id": 77,
                    "status": "disabled",
                    "external_reference": 2,
                    "ad_description": "Description for campaign 12"
                },
                {
                    "id": 13,
                    "job_id": 733,
                    "status": "enabled",
                    "external_reference": 3,
                    "ad_description": "Description for campaign 13"
                }
            ]}
            :
            {"campaigns": [
                {
                    "id": 11,
                    "job_id": 344,
                    "status": "enabled",
                    "external_reference": 1,
                    "ad_description": "Description for campaign 11"
                },
                {
                    "id": 12,
                    "job_id": 77,
                    "status": "paused",
                    "external_reference": 2,
                    "ad_description": "Description for campaign 12"
                },
                {
                    "id": 13,
                    "job_id": 733,
                    "status": "enabled",
                    "external_reference": 3,
                    "ad_description": "Description for campaign 1223"
                }
            ]}    
        end
    end

    class ValidateCampaign
        def initialize(campaigns)
            @campaigns = campaigns
            @discrepencies = []
        end

        def call
            ad_service_data = get_campaign_ad_service
            build_descrepencies(ad_service_data)
            return @discrepencies
        end

        def build_descrepencies(ad_service_data)
            ad_service_data['ads'].each do |ad|
                errors = {}
                campaign = @campaigns.find_by_external_id(ad['reference'])[0].to_h
                if !campaign.nil?
                    if ad['status'] != campaign[:status]
                        errors['status'] = {
                            remote: ad['status'],
                            local: campaign[:status]
                        }
                    end
                    if ad['description'] != campaign[:ad_description]
                        errors['description'] = {
                            remote: ad['description'],
                            local: campaign[:ad_description]
                        }
                    end
                    add_descrepency(ad['reference'], errors) if !errors.empty?
                end                          
            end
        end

        def add_descrepency(remote_reference, errors)
            @discrepencies <<
            {
                "remote_reference": remote_reference,
                "discrepancies": [errors]
            }
        end

        def get_campaign_ad_service
            response = HTTParty.get('https://mockbin.org/bin/fcb30500-7b98-476f-810d-463a0b8fc3df')
            JSON.parse(response.body)
        end
    end
end