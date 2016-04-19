class Oystercard

  BALANCE_LIMIT = 90
  MINIMUM_BALANCE = 1
  MINIMUM_FARE = 2
  attr_reader :balance, :entry_station

  def initialize
    @balance = 0
  end

  def top_up(amount)
    @amount = amount

   fail "balance should not exceed £#{BALANCE_LIMIT}"  if reach_limit?
   @balance += amount
  end

  def in_journey?
    !!entry_station
  end

  def touch_in(station)
    fail "insufficient balance" if @balance < MINIMUM_BALANCE
    @entry_station = station
  end

  def touch_out
    @entry_station = nil
    deduct(MINIMUM_FARE)
  end

  private

  def deduct(amount)
   @balance -= amount
  end

  def reach_limit?
    @balance + @amount > BALANCE_LIMIT
  end

end
