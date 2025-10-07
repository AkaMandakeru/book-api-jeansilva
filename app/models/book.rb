class Book < ApplicationRecord
  enum :status, { available: 0, reserved: 1 }
end
