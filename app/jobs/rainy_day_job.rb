class RainyDayJob < ApplicationJob
  queue_as :default

  def perform(just_set_up = nil)
    text_users unless just_set_up
    @scheduled_time = early_next_morning
    RainyDayJob.set(wait_until: @scheduled_time).perform_later
    send_admin_text
  end

  private

  def send_admin_text
    MyTwillioClient.api.account.messages.create(
      from: '+12028834286',
      to: "+1#{ENV['ADMIN_PHONE_NUMBER']}",
      body: "Thirsty Plants has scheduled RainyDayJob for #{@scheduled_time}"
    )
  end

  def text_users
    RainyDay.generate_rainy_days.each do |rainy_day|
      send_rainy_day_texts(rainy_day)
    end
  end

  def early_next_morning
    self.class.early_next_morning
  end

  def self.early_next_morning
    Time.use_zone("Mountain Time (US & Canada)") { 1.day.from_now.beginning_of_day + 5.hours }
  end

  def users_with_phone_numbers
    User.where.not(telephone: nil)
  end

  def send_rainy_day_texts(rainy_day)
    rainy_day.gardens.each do |garden|
      MyTwillioClient.api.account.messages.create(rainy_day_text(garden, rainy_day))
    end
  end

  def rainy_day_text(garden, rainy_day)
    RainyDayTexter.rainy_day_text(garden, rainy_day.chance_of_rain)
  end
end