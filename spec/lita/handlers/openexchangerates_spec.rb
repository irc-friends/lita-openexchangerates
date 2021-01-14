require "spec_helper"

describe Lita::Handlers::Openexchangerates, lita_handler: true do
  let(:robot) { Lita::Robot.new(registry) }

  subject { described_class.new(robot) }

  it { is_expected.to route("exchange usd cad").to(:exchange) }
  it { is_expected.to route("currencies").to(:list_currencies) }

  describe "#exchange" do
    it "should convert" do
      allow_any_instance_of(described_class).to receive(:convert).and_return(1.0)
      send_message("convert usd cad")
      expect(replies.last).to eq("USD \u279e CAD: 1.0000")
    end

    it "should exchange" do
      allow_any_instance_of(described_class).to receive(:convert).and_return(1.0)
      send_message("exchange usd cad")
      expect(replies.last).to eq("USD \u279e CAD: 1.0000")
    end

    it "should convert with value" do
      allow_any_instance_of(described_class).to receive(:convert).and_return(2.0)
      send_message("convert usd cad 10")
      expect(replies.last).to eq("USD \u279e CAD: 20.0000")
    end
  end
end
