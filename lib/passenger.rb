require_relative "csv_record"

module RideShare
  class Passenger < CsvRecord
    attr_reader :name, :phone_number, :trips

    def initialize(id:, name:, phone_number:, trips: nil)
      super(id)

      @name = name
      @phone_number = phone_number
      @trips = trips || []
    end

    def add_trip(trip)
      @trips << trip
    end

    def net_expenditures
      sum = 0

      trips.each do |trip|
        if trip.cost
          sum += trip.cost
        end
      end
      return sum == nil ? 0 : sum
    end

    def total_time_spent
      time_sum = 0
      trips.each do |trip|
        time_sum += trip.trip_duration
      end
      return time_sum == nil ? 0 : time_sum / 60
    end

    private

    def self.from_csv(record)
      return new(
               id: record[:id],
               name: record[:name],
               phone_number: record[:phone_num],
             )
    end
  end
end
