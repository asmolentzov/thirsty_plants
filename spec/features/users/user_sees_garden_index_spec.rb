require 'rails_helper'

describe 'as a logged-in user, I can see the garden index page' do
  it "should see garden details", :vcr do
    user = create(:user)
    user_2 = create(:user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    garden_1 = create(:garden, owners: [user])
    garden_2 = create(:garden, owners: [user_2])
    garden_3 = create(:garden, owners: [user])

    visit gardens_path

    expect(page).to have_content("#PlantLife")
    expect(page).to have_content("#{user.first_name}'s Greenery")

    within "#garden-#{garden_1.id}" do
      expect(page).to have_content(garden_1.name)
      expect(page).to have_link("View Your Garden")
    end

    expect(page).to_not have_content(garden_2.name)
    expect(page).to_not have_content(garden_2.zip_code)

    within "#garden-#{garden_3.id}" do
      expect(page).to have_content(garden_3.name)
      click_link("View Your Garden")
      expect(current_path).to eq(garden_path(garden_3))
    end

  end
  it "sees weather data", :vcr do
    user = create(:user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    garden = create(:garden, owners: [user], name: "Backyard", zip_code: 80218)
    visit gardens_path

    today = Time.now
    within(".weather-card-#{garden.id}") do
      expect(page).to have_content("Weather in #{garden.name} (#{garden.zip_code}):")
      expect(page).to have_css('.weather_day', count: 7)
      expect(page).to have_content("#{today.strftime('%A')}")
      expect(page).to have_content("#{(today + 1.days).strftime('%A')}")
      expect(page).to have_content("#{(today + 2.days).strftime('%A')}")
      expect(page).to have_content("#{(today + 3.days).strftime('%A')}")
      expect(page).to have_content("#{(today + 4.days).strftime('%A')}")
      expect(page).to have_content("#{(today + 5.days).strftime('%A')}")
      expect(page).to have_content("#{(today + 6.days).strftime('%A')}")
    end
  end
  it "sees plant information", :vcr do
    user = create(:user)
    garden = create(:garden, name: "Back Yard", zip_code: 80206, owners: [user])
    plant_1 = create(:plant, name: "Petunia", times_per_week: 1, garden: garden)
    plant_2 = create(:plant, name: "Sunflower", times_per_week: 3, garden: garden)
    plant_3 = create(:plant, name: "Dahlia", times_per_week: 5, garden: garden)

    garden_2 = create(:garden, name: "Front Yard", zip_code: 80206, owners: [user])
    plant_4 = create(:plant, name: "Morning Glory", times_per_week: 5, garden: garden_2)
    plant_5 = create(:plant, name: "Rose", times_per_week: 3, garden: garden_2)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    visit gardens_path

    within "#garden-#{garden.id}" do
      expect(page).to have_content("#{garden.name}")
      expect(page).to have_content(plant_1.name)
    end
    within "#garden-#{garden_2.id}" do
      expect(page).to have_content(plant_4.name)
    end
  end
  it 'only sees its own gardens', :vcr do
    user = create(:user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    garden = create(:garden, owners: [user])
    garden_2 = create(:garden, owners: [user])

    other_garden = create(:garden)

    visit gardens_path

    expect(page).to have_content(garden.name)
    expect(page).to have_content(garden_2.name)
    expect(page).to_not have_content(other_garden.name)
  end
end
