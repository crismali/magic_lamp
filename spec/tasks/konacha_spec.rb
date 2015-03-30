require "rails_helper"

describe "Konacha tasks" do
  def self.it_redraws_the_konacha_routes
    it "redraws the konacha routes" do
      allow(Konacha).to receive(:serve)
      allow(Konacha).to receive(:run).and_return(true)

      subject.execute

      route_names = Konacha::Engine.routes.router.routes.map(&:name)
      expect(route_names).to eq(["magic_lamp", "iframe", "root", nil])
    end
  end

  describe "magic_lamp:konacha:serve" do
    it { is_expected.to depend_on(:environment) }
    it_redraws_the_konacha_routes

    it "runs the konacha server" do
      expect(Konacha).to receive(:serve)
      subject.execute
    end
  end

  describe "magic_lamp:konacha:run" do
    it { is_expected.to depend_on(:environment) }
    it_redraws_the_konacha_routes

    it "runs the Konacha specs" do
      expect(Konacha).to receive(:run).and_return(true)

      subject.execute
    end

    context "specs pass" do
      it "does not exit" do
        expect(Konacha).to receive(:run).and_return(true)
        expect(MagicLamp::Genie.instance).to_not receive(:exit)
        subject.execute
      end
    end

    context "specs fail" do
      it "exits with 1" do
        expect(Konacha).to receive(:run).and_return(false)
        expect(MagicLamp::Genie.instance).to receive(:exit).with(1)
        subject.execute
      end
    end
  end

  context "aliases" do
    context "mlks" do
      it { is_expected.to depend_on("magic_lamp:konacha:serve") }
    end

    context "mlkr" do
      it { is_expected.to depend_on("magic_lamp:konacha:run") }
    end
  end
end
