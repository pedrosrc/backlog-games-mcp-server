class User < ApplicationRecord
  has_many :backlog_items
end
