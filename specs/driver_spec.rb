require_relative "spec_helper"

describe "Driver class" do
  describe "Driver instantiation" do
    before do
      @driver = RideShare::Driver.new(
        id: 54,
        name: "Test Driver",
        vin: "12345678901234567",
        status: :AVAILABLE,
      )
    end

    it "sets the status to :AVAILABLE if no status is given at init" do
      @driver = RideShare::Driver.new(
        id: 54,
        name: "Test Driver",
        vin: "12345678901234567",
      )
      expect(@driver.status).must_equal :AVAILABLE
    end

    it "raises an error when a bad status is passed in init" do
      expect {
        @driver = RideShare::Driver.new(
          id: 54,
          name: "Test Driver",
          vin: "12345678901234567",
          status: :UNLOVED,
        )
      }.must_raise ArgumentError
    end

    it "is an instance of Driver" do
      expect(@driver).must_be_kind_of RideShare::Driver
    end

    it "throws an argument error with a bad VIN" do
      expect { RideShare::Driver.new(id: 0, name: "George", vin: "33133313331333133") }.must_raise ArgumentError
    end

    it "throws an argument error with a bad VIN value" do
      expect { RideShare::Driver.new(id: 100, name: "George", vin: "") }.must_raise ArgumentError
      expect { RideShare::Driver.new(id: 100, name: "George", vin: "33133313331333133extranums") }.must_raise ArgumentError
    end

    it "has a default status of :AVAILABLE" do
      expect(RideShare::Driver.new(id: 100, name: "George", vin: "12345678901234567").status).must_equal :AVAILABLE
    end

    it "sets driven trips to an empty array if not provided" do
      expect(@driver.trips).must_be_kind_of Array
      expect(@driver.trips.length).must_equal 0
    end

    it "is set up for specific attributes and data types" do
      [:id, :name, :vin, :status, :trips].each do |prop|
        expect(@driver).must_respond_to prop
      end

      expect(@driver.id).must_be_kind_of Integer
      expect(@driver.name).must_be_kind_of String
      expect(@driver.vin).must_be_kind_of String
      expect(@driver.status).must_be_kind_of Symbol
    end
  end

  describe "add_trip method" do
    before do
      pass = RideShare::Passenger.new(
        id: 1,
        name: "Test Passenger",
        phone_number: "412-432-7640",
      )
      @driver = RideShare::Driver.new(
        id: 3,
        name: "Test Driver",
        vin: "12345678912345678",
      )
      @trip = RideShare::Trip.new(
        id: 8,
        driver: @driver,
        passenger: pass,
        start_time: "2016-08-08",
        end_time: "2018-08-09",
        rating: 5,
      )
    end

    it "adds the trip" do
      expect(@driver.trips).wont_include @trip
      previous = @driver.trips.length

      @driver.add_trip(@trip)

      expect(@driver.trips).must_include @trip
      expect(@driver.trips.length).must_equal previous + 1
    end
  end

  describe "average_rating method" do
    before do
      @driver = RideShare::Driver.new(
        id: 54,
        name: "Rogers Bartell IV",
        vin: "1C9EVBRM0YBC564DZ",
      )
      trip = RideShare::Trip.new(
        id: 8,
        driver: @driver,
        passenger_id: 3,
        start_time: "2016-08-08",
        end_time: "2016-08-08",
        rating: 5,
      )
      @driver.add_trip(trip)
    end

    it "returns a float" do
      expect(@driver.average_rating).must_be_kind_of Float
    end

    it "returns a float within range of 1.0 to 5.0" do
      average = @driver.average_rating
      expect(average).must_be :>=, 1.0
      expect(average).must_be :<=, 5.0
    end

    it "returns zero if no driven trips" do
      driver = RideShare::Driver.new(
        id: 54,
        name: "Rogers Bartell IV",
        vin: "1C9EVBRM0YBC564DZ",
      )
      expect(driver.average_rating).must_equal 0
    end

    it "correctly calculates the average rating" do
      trip2 = RideShare::Trip.new(
        id: 8,
        driver: @driver,
        passenger_id: 3,
        start_time: "2016-08-08",
        end_time: "2016-08-09",
        rating: 1,
      )
      @driver.add_trip(trip2)

      expect(@driver.average_rating).must_be_close_to (5.0 + 1.0) / 2.0, 0.01
    end
  end

  describe "total_revenue" do
    before do
      pass = RideShare::Passenger.new(
        id: 1,
        name: "Test Passenger",
        phone_number: "412-432-7640",
      )
      @driver = RideShare::Driver.new(
        id: 3,
        name: "Test Driver",
        vin: "12345678912345678",
      )
      @trip = RideShare::Trip.new(
        id: 8,
        driver: @driver,
        passenger: pass,
        start_time: "2016-08-08",
        end_time: "2018-08-09",
        rating: 5,
        cost: 6.65,
      )
      @driver.add_trip(@trip)
    end

    it "returns the correct number with one trip" do
      expect(@driver.total_revenue).must_equal ((6.65 - 1.65) * 0.8)
    end
  end

  describe "net_expenditures" do
    # You add tests for the net_expenditures method
  end

  describe "start trip" do
    before do
      pass = RideShare::Passenger.new(
        id: 1,
        name: "Test Passenger",
        phone_number: "412-432-7640",
      )
      @driver = RideShare::Driver.new(
        id: 3,
        name: "Test Driver",
        vin: "12345678912345678",
      )
      @trip = RideShare::Trip.new(
        id: 8,
        driver: @driver,
        passenger: pass,
        start_time: "2016-08-08",
        end_time: "2018-08-09",
        rating: 5,
        cost: 6.65,
      )
      # @driver.add_trip(@trip)
    end

    it "Driver status to unavailable" do
      @driver.start_trip(@trip)
      expect(@driver.status).must_equal :UNAVAILABLE
    end

    it "Adds trip to trip array" do
      expect(@driver.trips.count).must_equal 0
      @driver.start_trip(@trip)
      expect(@driver.trips.count).must_equal 1
    end
  end
  describe "inprogress trip errors" do
    before do
      @pass = RideShare::Passenger.new(
        id: 1,
        name: "Test Passenger",
        phone_number: "412-432-7640",
      )
      @driver = RideShare::Driver.new(
        id: 3,
        name: "Test Driver",
        vin: "12345678912345678",
      )
      @trip = RideShare::Trip.new(
        id: 8,
        driver: @driver,
        passenger: @pass,
        start_time: "2016-08-08",
        end_time: "2018-08-09",
        rating: 5,
        cost: 6.65,
      )

      @trip2 = RideShare::Trip.new(
        id: 2,
        driver: @driver,
        passenger: @pass,
        start_time: "2016-08-08",
        end_time: nil,
        rating: nil,
        cost: nil,
      )
      @driver.add_trip(@trip)
    end
    it "checks if total revenue " do
      initial_revenue = @driver.total_revenue
      @driver.add_trip(@trip2)
      second_revenue = @driver.total_revenue

      expect(initial_revenue).must_equal second_revenue
    end

    it "doesn't change the average rating if there's an in-progress trip" do
      initial_rating = @driver.average_rating
      @driver.add_trip(@trip2)
      second_rating = @driver.average_rating

      expect(initial_rating).must_equal second_rating
    end
  end
end
