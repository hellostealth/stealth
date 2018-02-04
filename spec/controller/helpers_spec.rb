# coding: utf-8
# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

$:.unshift File.expand_path("../support/helpers", __dir__)

describe "Stealth::Controller helpers" do

  Stealth::Controller.helpers_path = File.expand_path("../support/helpers", __dir__)

  module Fun
    class GamesController < Stealth::Controller
      helper :all

      def say_hello_world
        hello_world
      end
    end

    class PdfController < Stealth::Controller
      def say_pdf_name
        generate_pdf_name
      end
    end
  end

  class BaseController < Stealth::Controller

  end

  class AllHelpersController < Stealth::Controller
    helper :all
  end

  class SizzleController < Stealth::Controller
    helper :standalone

    def say_sizzle

    end
  end

  class HelpersTypoController < Stealth::Controller
    path = File.expand_path("../support/helpers_typo", __dir__)
    $:.unshift(path)
    self.helpers_path = path
  end

  class VoodooController < Stealth::Controller
    helpers_path = File.expand_path("../support/alternate_helpers", __dir__)

    # Reload helpers
    _helpers = Module.new
    helper :all

    def zoom

    end
  end

  let(:facebook_message) { SampleMessage.new(service: 'facebook') }
  let(:all_helper_methods) { [:hello_world, :baz, :generate_pdf_name] }

  describe "loading" do

    it "should load all helpers if none are specified by default" do
      expect(BaseController._helpers.instance_methods).to match_array(all_helper_methods)
    end

    it "should not load helpers if none are specified by default and include_all_helpers = false" do
      Stealth::Controller.include_all_helpers = false
      class HelperlessController < Stealth::Controller; end
      expect(HelperlessController._helpers.instance_methods).to eq []
    end

    it "should load all helpers if :all is used" do
      expect(AllHelpersController._helpers.instance_methods).to match_array(all_helper_methods)
    end

    it "should allow a controller that has loaded all helpers to access a helper method" do
      expect {
        Fun::GamesController.new(service_message: facebook_message.message_with_text).say_hello_world
      }.to_not raise_error
    end

    it "should allow a controller action to access a helper method" do
      expect {
        Fun::PdfController.new(service_message: facebook_message.message_with_text).say_pdf_name
      }.to_not raise_error
    end
  end

end
