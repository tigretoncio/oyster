require 'oystercard'

describe Oystercard do

  let(:journey) { double(:journey, fare: 1, start_journey: nil, end_journey: nil, complete?: false) }
  let(:invalid_journey) { double(:journey, start_journey: nil, end_journey: nil, fare: 6, exit_nil?: true) }
  let(:journeycomplete) { double(:journey, complete?: true, start_journey: nil) }
  subject(:oystercard) { described_class.new }
  let(:startstation) { double(:station) }
  let(:endstation) { double(:station) }
 
  it 'defaults with balance of 0' do
    expect(oystercard.balance).to eq 0
  end

  describe '#top_up' do
    it 'increase the balance' do
      oystercard.top_up(10)
      expect(oystercard.balance).to eq 10
    end
    it 'cannot increase the balance beyond limit' do
      message = "No more than #{Oystercard::MAX_LIMIT} in balance!"
      expect{oystercard.top_up(Oystercard::MAX_LIMIT+1)}.to raise_error message
    end
  end

  describe '#touch_in' do
    it 'makes the journey start' do
      oystercard.top_up(Oystercard::MAX_LIMIT)
      expect(journey).to receive(:start_journey).with(startstation)
      oystercard.touch_in(startstation,journey)
    end
    it 'deducts a penalty fare if the last journey was not completed' do
      oystercard.top_up(Oystercard::MAX_LIMIT)
      oystercard.touch_in(startstation,invalid_journey)
      expect {oystercard.touch_in(startstation,journey)}.to change{oystercard.balance}.by -6  
    end
  end
    
  describe '#touch_out' do
    it 'makes the journey end' do
      oystercard.top_up(Oystercard::MAX_LIMIT)
      oystercard.touch_in(startstation,journey)
      expect(journey).to receive(:end_journey).with(endstation)
      oystercard.touch_out(endstation)
    end
    it 'adds the journey to the journey history' do
      oystercard.top_up(Oystercard::MAX_LIMIT)
      oystercard.touch_in(startstation,journey)
      oystercard.touch_out(endstation)
      expect(oystercard.journey_history).to include(journey)
    end
    it 'deducts a penalty fare if the last journey was completed' do
      oystercard.top_up(Oystercard::MAX_LIMIT)
      oystercard.touch_in(startstation,journeycomplete)
      expect {oystercard.touch_out(startstation,invalid_journey)}.to change{oystercard.balance}.by -6  
    end
  end
  
  describe "When there is less than #{Oystercard::MIN_LIMIT}" do
    it "cannot begin journey" do
      message = "insufficient funds! Need at least #{Oystercard::MIN_LIMIT}"
      expect{oystercard.touch_in(startstation)}.to raise_error message
    end
  end

end