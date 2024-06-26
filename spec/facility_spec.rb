require 'spec_helper'

RSpec.describe Facility do
  before(:each) do
    @facility = Facility.new({name: 'DMV Tremont Branch', address: '2855 Tremont Place Suite 118 Denver CO 80205', phone: '(720) 865-4600'})
    @facility_1 = Facility.new({name: 'DMV Tremont Branch', address: '2855 Tremont Place Suite 118 Denver CO 80205', phone: '(720) 865-4600'})
    @facility_2 = Facility.new({name: 'DMV Northeast Branch', address: '4685 Peoria Street Suite 101 Denver CO 80239', phone: '(720) 865-4600'})
    @vehicle = Vehicle.new({vin:'', year:'', make:'', model:'', engine:''})
    @cruz = Vehicle.new({vin: '123456789abcdefgh', year: 2012, make: 'Chevrolet', model: 'Cruz', engine: :ice} )
    @bolt = Vehicle.new({vin: '987654321abcdefgh', year: 2019, make: 'Chevrolet', model: 'Bolt', engine: :ev} )
    @camaro = Vehicle.new({vin: '1a2b3c4d5e6f', year: 1969, make: 'Chevrolet', model: 'Camaro', engine: :ice} )
    @registrant = Registrant.new(@name, @age, @permit = false)
    @registrant_1 = Registrant.new('Bruce', 18, true)
    @registrant_2 = Registrant.new('Penny', 16)
    @registrant_3 = Registrant.new('Tucker', 15)
  end

  describe '#initialize' do
    it 'can initialize' do
      expect(@facility).to be_an_instance_of(Facility)
      expect(@facility.name).to eq('DMV Tremont Branch')
      expect(@facility.address).to eq('2855 Tremont Place Suite 118 Denver CO 80205')
      expect(@facility.phone).to eq('(720) 865-4600')
      expect(@facility.services).to eq([])
    end
  end

  describe '#add service' do
    it 'can add available services' do
      expect(@facility.services).to eq([])
      @facility.add_service('New Drivers License')
      @facility.add_service('Renew Drivers License')
      @facility.add_service('Vehicle Registration')
      expect(@facility.services).to eq(['New Drivers License', 'Renew Drivers License', 'Vehicle Registration'])
    end
  end

# VEHICLE REGISTRATION
  describe 'regular vehicle registration' do
    it 'can register a regular vehicle' do
      @facility_1.add_service("Register Vehicles")
      expect(@facility_1.collected_fees).to eq(0)
      @facility_1.register_vehicle(@cruz)

      expect(@cruz.registration_date).to eq(Date.today)
      expect(@cruz.plate_type).to eq(:regular)
      expect(@facility_1.registered_vehicles).to eq([@cruz])
      expect(@facility_1.collected_fees).to eq(100)
    end
  end

  describe 'vintage vehicle registration' do
    it 'can register a vintage vehicle' do
      @facility_1.add_service("Register Vehicles")
      @facility_1.register_vehicle(@cruz)
      expect(@facility_1.collected_fees).to eq(100)
      @facility_1.register_vehicle(@camaro)

      expect(@camaro.registration_date).to eq(Date.today)
      expect(@camaro.plate_type).to eq(:antique)
      expect(@facility_1.registered_vehicles).to eq([@cruz, @camaro])
      expect(@facility_1.collected_fees).to eq(125)
    end
  end

  describe 'electric vehicle registration' do
    it 'can register an electric vehicle' do
      @facility_1.add_service("Register Vehicles")
      @facility_1.register_vehicle(@cruz)
      expect(@facility_1.collected_fees).to eq(100)
      @facility_1.register_vehicle(@camaro)
      expect(@facility_1.registered_vehicles).to eq([@cruz, @camaro])
      @collected_fees = 125
      @facility_1.register_vehicle(@bolt)

      expect(@bolt.registration_date).to eq(Date.today)
      expect(@bolt.plate_type).to eq(:ev)
      expect(@facility_1.registered_vehicles).to eq([@cruz, @camaro, @bolt])
      expect(@facility_1.collected_fees).to eq(325)
    end
  end
  
# GETTING A DRIVER'S LICENSE
  describe 'getting a drivers license' do
    it 'takes the written test' do
      expect(@registrant_1.license_data).to eq({:written => false, :license => false, :renewed => false})
      expect(@registrant_1.permit?).to be true 
      @facility_1.add_service("Written Test")
      @facility_1.administer_written_test?(@registrant_1)
      expect(@facility_1.administer_written_test?(@registrant_1)).to be true
      expect(@registrant_1.license_data).to eq({:written => true, :license => false, :renewed => false})
      
      expect(@registrant_2.license_data).to eq({:written => false, :license => false, :renewed => false})
      expect(@registrant_2.age).to eq(16)
      expect(@registrant_2.permit?).to be false
      expect(@facility_1.administer_written_test?(@registrant_2)).to be false
      @registrant_2.earn_permit
      expect(@facility_1.administer_written_test?(@registrant_2)).to be true
      expect(@registrant_2.license_data).to eq({:written => true, :license => false, :renewed => false})

      expect(@registrant_3.license_data).to eq({:written => false, :license => false, :renewed => false})
      expect(@registrant_3.age).to eq(15)
      @registrant_3.earn_permit
      expect(@registrant_3.permit?).to be true
      expect(@facility_1.administer_written_test?(@registrant_3)).to be false
    end

    it 'takes the road test' do
      expect(@facility_1.administer_road_test?(@registrant_3)).to be false
      @registrant_3.earn_permit
      expect(@facility_1.administer_road_test?(@registrant_3)).to be false
      expect(@registrant_3.license_data).to eq({:written => false, :license => false, :renewed => false})

      expect(@facility_1.administer_road_test?(@registrant_1)).to be false
      @facility_1.add_service("Written Test")
      @facility_1.add_service('Road Test')
      expect(@facility_1.services).to eq(["Written Test", "Road Test"])

      expect(@facility_1.administer_road_test?(@registrant_1)).to be true
      expect(@registrant_1.license_data).to eq({:written => true, :license => true, :renewed => false})
    end

    it 'renews their license' do
      @facility_1.add_service("Written Test")
      @facility_1.add_service('Road Test')
      
      @facility_1.administer_written_test?(@registrant_1)
      @facility_1.administer_road_test?(@registrant_1)
      expect(@registrant_1.license_data).to eq({:written => true, :license => true, :renewed => false})
    
      @facility_1.add_service('Renew License')
      expect(@facility_1.services).to eq ["Written Test", "Road Test", "Renew License"]
      expect(@facility_1.renew_drivers_license?(@registrant_1)).to be true
      expect(@registrant_1.license_data).to eq({:written=>true, :license=>true, :renewed=>true})
    end
  end

end
