# frozen_string_literal: true

require "rails_helper"

describe "All fixtures js erb" do
  subject do
    sprockets_env = Sprockets::Environment.new
    sprockets_env.append_path("app/assets/javascripts/")
    sprockets_env["magic_lamp/all_fixtures.js"].to_s
  end

  it "sets cache only to true" do
    expect(subject).to match(/MagicLamp.genie.cacheOnly = true/)
  end

  it "provides all of the fixtures as json in the cache" do
    excaped_json = Regexp.escape(MagicLamp.generate_all_fixtures.to_json)
    expect(subject).to match(/MagicLamp.genie.cache = #{excaped_json}/)
  end

  it "does not throw an error" do
    expect(subject).to_not match(/throw new Error\(MagicLamp.genericError\)/)
  end

  context "errors" do
    before do
      allow(MagicLamp).to receive(:generate_all_fixtures).and_raise("Some error")
    end

    it "throws an error" do
      expect(subject).to match(/throw new Error\(MagicLamp.genericError\)/)
      expect(subject).to_not match(/MagicLamp.genie/)
    end
  end
end
