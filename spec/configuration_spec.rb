# frozen_string_literal: true

require 'spec_helper'

describe "Stealth::Configuration" do

  describe "accessing via method calling" do
    let(:services_yml) { File.read(File.join(File.dirname(__FILE__), 'support', 'services.yml')) }
    let(:parsed_config) { YAML.load(ERB.new(services_yml).result)[Stealth.env] }
    let(:config) { Stealth.load_services_config!(services_yml) }

    it "should return the root node" do
      expect(config.facebook).to eq parsed_config['facebook']
    end

    it "should access deeply nested nodes" do
      expect(config.facebook.setup.greeting).to eq parsed_config['facebook']['setup']['greeting']
    end

    it "should handle values that are arrays correctly" do
      expect(config.facebook.setup.persistent_menu).to be_a(Array)
    end

    it "should retain the configuration at the class level" do
      expect(Stealth.config.facebook.setup.greeting).to eq parsed_config['facebook']['setup']['greeting']
    end

    it "should handle multiple keys at the root level" do
      expect(config.twilio_sms.account_sid).to eq parsed_config['twilio_sms']['account_sid']
    end

    it "should return nil if the key is not present at the node" do
      expect(config.twilio_sms.api_key).to be nil
    end

    it "should raise a NoMethodError when accessing multi-levels of missing nodes" do
      expect { config.slack.api_key }.to raise_error(NoMethodError)
    end
  end

  describe "config files with ERB" do
    let(:services_yml) { File.read(File.join(File.dirname(__FILE__), 'support', 'services_with_erb.yml')) }
    let(:config) { Stealth.load_services_config!(services_yml) }

    it "should replace available embedded env vars" do
      ENV['FACEBOOK_VERIFY_TOKEN'] = 'it works'
      expect(config.facebook.verify_token).to eq 'it works'
    end

    it "should replace unavailable embedded env vars with nil" do
      expect(config.facebook.challenge).to be_nil
    end

    it "should not reload the configuration file if one already exists" do
      Stealth.load_services_config(services_yml)
      expect(config.facebook.challenge).to be_nil
    end
  end

end
