FactoryBot.define do
  factory :post do
    title { "MyString" }
    body { "MyText" }
    user { nil }
    after(:build) do |post|
      post.tag_list = "test-tag" if post.tags.empty?
    end
  end
end
