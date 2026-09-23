class Game < ApplicationRecord
  has_many :backlog_items
  has_many :ratings
end
