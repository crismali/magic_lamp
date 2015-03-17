shared_examples "it has callbacks" do
  subject { described_class.new(MagicLamp::Configuration.new) }

  context "attr_accessor" do
    it { is_expected.to attr_accessorize(:configuration) }
  end

  describe "#initialize" do
    it "sets configuration to the given argument" do
      configuration = double
      subject = described_class.new(configuration)
      expect(subject.configuration).to eq(configuration)
    end
  end

  [:after, :before].each do |type|
    describe "#execute_before_each_callback" do
      it "calls the type each callback" do
        dummy = double
        expect(dummy).to receive(:call)
        subject.configuration.send("#{type}_each_proc=", dummy)
        subject.send("execute_#{type}_each_callback")
      end

      context "no callback" do
        it "does not raise an error" do
          subject.configuration.send("#{type}_each_proc=", nil)
          expect do
            subject.send("execute_#{type}_each_callback")
          end.to_not raise_error
        end
      end
    end
  end
end
