class Helper
  @TEST_USERNAME = 'rspecUser'
  @TEST_EMAIL = 'rspecEmail'
  @TEST_PASSWORD = 'rspecPassword'
  @TEST_RSN = 'Skroomoomlie'

  def self.TEST_USERNAME
    @TEST_USERNAME
  end

  def self.TEST_EMAIL
    @TEST_USERNAME
  end

  def self.TEST_PASSWORD
    @TEST_USERNAME
  end

  def self.TEST_RSN
    @TEST_USERNAME
  end

  def self.populate_user_table
    other_user_data = [
      ['User1', 'password1', 'test1@email.com', 'Lynx Titan'],
      ['User2', 'password1', 'test2@email.com', 'Lynx Titan'],
      ['User3', 'password1', 'test3@email.com', 'Lynx Titan'],
      ['User4', 'password1', 'test4@email.com', 'Lynx Titan'],
      ['User5', 'password1', 'test5@email.com', 'Lynx Titan'],
      ['User6', 'password1', 'test6@email.com', 'Lynx Titan'],
      ['User7', 'password1', 'test7@email.com', 'Lynx Titan'],
      ['User8', 'password1', 'test8@email.com', 'Lynx Titan'],
      ['User9', 'password1', 'test9@email.com', 'Lynx Titan'],
    ]

    first_user = other_user_data.first
    User.create_user({
      username: first_user[0],
      password: BCrypt::Password.create(first_user[1]),
      email: first_user[2],
      rsn: first_user[3],
    })
    
    other_user_data.drop(1).each do |row|
      User.create_test_user({
        username: row[0],
        password: BCrypt::Password.create(row[1]),
        email:    row[2], 
        rsn:      row[3]
      })
    end
  end
end
