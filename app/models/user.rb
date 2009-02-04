require 'digest/sha1'
class User < ActiveRecord::Base
  validates_presence_of :email
  validates_uniqueness_of :email, :only => :new
  attr_accessor :password_confirmation
  
  belongs_to :city
  has_many :emissions

    # lookup the user and check the password
    # set user to nil if user doesn’t exist
    # or password doesn’t match
    def self.login(email, password)
        user = User.find(:first, :conditions => ['email = ?' , email])
        if user
            expected_password = encrypted_password(password, user.password_salt)
            if user.password_hash != expected_password
                user = nil
            end
        end
        user
    end

    # password getter
    def password
       @password
    end

    #password setter
        def password=(pwd)
        @password = pwd
        create_new_salt
        self.password_hash = User.encrypted_password(self.password, self.password_salt)
    end

    # make sure we leave at least one user in the database
    def safe_delete
        transaction do
            destroy
            if User.count.zero?
                raise "Cannot delete last user"
            end
        end
    end
    
    private

    # create the salt we will use when encrypting the password
    def create_new_salt
        self.password_salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp
    end

    # returs the hash for the password using the salt provided
    def self.encrypted_password(password, salt)
        string_to_hash = password + salt
        Digest::SHA1.hexdigest(string_to_hash)
      end
 


end