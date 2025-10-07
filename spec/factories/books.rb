FactoryBot.define do
  factory :book do
    title { Faker::Book.title }
    status { :available }
    reserved_by { nil }
    author { Faker::Book.author }
    published_at { Faker::Date.between(from: 50.years.ago, to: Date.today) }
  end
end
