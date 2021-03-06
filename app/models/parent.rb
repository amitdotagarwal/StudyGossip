class Parent < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
 attr_accessor :school
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,:school,:school_admin_id,:first_name,:last_name,:reset_password_token
  # attr_accessible :title, :body
  belongs_to :school_admin
  has_many :parentusers,:dependent => :destroy
  has_many :users, :through => :parentusers
  validates :first_name,:last_name,:email, :presence => true
   def generate_password_reset_code
    self.reset_password_token = Digest::SHA2.hexdigest(Time.now.to_s)
    self.reset_password_sent_at = Time.now
    save
  end
end

