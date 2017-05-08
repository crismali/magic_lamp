# frozen_string_literal: true

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

  %i[after before].each do |type|
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

  describe "#execute_callbacks_around" do
    it "raises an error without a block" do
      expect do
        subject.execute_callbacks_around
      end.to raise_error(MagicLamp::ArgumentError, "#{described_class.name}#execute_callbacks_around requires a block")
    end

    it "calls the callbacks around the block" do
      def subject.foo; end
      expect(subject).to receive(:execute_before_each_callback).ordered
      expect(subject).to receive(:foo).ordered
      expect(subject).to receive(:execute_after_each_callback).ordered
      subject.execute_callbacks_around { subject.foo }
    end

    it "returns the return value of the block" do
      spy = double
      expect(subject.execute_callbacks_around { spy }).to eq(spy)
    end
  end
end
