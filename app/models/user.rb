class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable
  attr_accessible :email,:class_photo,:syllabus_link,:readings_attributes,:importent_links_attributes,:faqs_attributes,:school,:class_name,:class_description,:syllabus, :password, :password_confirmation,:terms_of_service, :remember_me,:username,:avatar,:school_admin_id,:role,:bio,:state,:major,:website,:first_name,:last_name,:reset_password_token,:phone, :zipcode, :father_name,:date_of_birth,:full_address,:guradian_name,:guardian_contact_info,:relation_with_guardain,:emergency_phone,:full_address,:home_phone,:year_of_admission
  has_many :tweets, :dependent => :destroy, :order => "created_at DESC"
  has_many :reports, :dependent => :destroy, :order => "created_at DESC"
  has_many :readings, :dependent => :destroy
  has_many :faqs, :dependent => :destroy
  has_many :favorites, :dependent => :destroy
  has_many :importent_links, :dependent => :destroy
  has_many :studentclasses, :dependent => :destroy
  has_many :cls, :through=> :studentclasses 
  has_many :parentusers, :dependent => :destroy
  has_many :parents, :through => :parentusers
  has_many :teacherclasses
  has_many :cls,:through=>:teacherclasses
  has_many :subjects,:through=>:teacherclasses
  attr_accessor :school
  accepts_nested_attributes_for :readings,  :allow_destroy  => true,:reject_if => :all_blank
  accepts_nested_attributes_for :faqs,  :allow_destroy  => true,:reject_if => :all_blank
  accepts_nested_attributes_for :importent_links,  :allow_destroy  => true,:reject_if => :all_blank
  
  validates :full_address,:relation_with_guardain,:guardian_contact_info,:home_phone,:year_of_admission, :presence => {:if => :role? }
 # validates :emergency_phone,:home_phone, :presence => {:if => :phone_valid?} #format: { with: /\d{3}-\d{3}-\d{4}/, message: "bad format" }}
  # validates_format_of :emergency_phone,:home_phone, with: /\A(\d{10}|\(?\d{3}\)?[-. ]\d{3}[-.]\d{4})\z/, :presence => {:if => :phone_valid?}
  validates :emergency_phone,:home_phone, :length => {:minimum => 10, :maximum => 15},:presence => {:if => :phone_valid?}, :format => { :with => /\A\S[0-9\+\/\(\)\s\-]*\z/i }, :allow_nil  => true

  def phone_valid?
    self.role == "student"
  #self.emergency_phone.numericality == true
   # message: " Phone numbers must be in xxx-xxx-xxxx format",
    # format: { :with => /\A\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})\Z/, message: " Phone numbers must be in xxx-xxx-xxxx format" }
  end

 def role?
  self.role == "student"
end

has_attached_file :avatar,
:whiny => false,
:storage => :s3,
:s3_credentials => "#{Rails.root}/config/s3.yml",
:path => "uploaded_files/profile/:id/:style/:basename.:extension",
:bucket => "edupost",
:styles => {
  :original => "900x900>",
  :default => "280x190>",
  :other => "96x96>" } if (Rails.env == 'production')
  has_attached_file :avatar,:styles => {:original => "900x900>", :default => "280x190>" } if Rails.env == 'development'
  has_attached_file :syllabus_link,
  :whiny => false,
  :storage => :s3,
  :s3_credentials => "#{Rails.root}/config/s3.yml",
  :path => "uploaded_files/profile/:id/:style/:basename.:extension",
  :bucket => "edupost",
  :styles => {
    :original => "900x900>",
    :default => "280x190>",
    :other => "96x96>" } if (Rails.env == 'production')
    has_attached_file :syllabus_link,:styles => {:original => "900x900>", :default => "280x190>" } if Rails.env == 'development'

    has_attached_file :class_photo,
    :whiny => false,
    :storage => :s3,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :path => "uploaded_files/profile/:id/:style/:basename.:extension",
    :bucket => "edupost",
    :styles => {
      :original => "900x900>",
      :default => "280x190>",
      :other => "96x96>" } if (Rails.env == 'production')
      has_attached_file :class_photo,:styles => {:original => "900x900>", :default => "280x190>" } if Rails.env == 'development'
      validates :username,:uniqueness => true,:format => {:with => /^[\w\-@]*$/ , :message => "Only use letters, numbers with no spaces"}, :on => :update
      belongs_to :school_admin
      has_many :teacher_attendances,  :dependent => :destroy
      has_many :attendances, :dependent => :destroy
      has_many :sent_follows, :class_name => "Follow", :foreign_key => :user_id, :dependent => :destroy
      has_many :received_follows, :class_name => 'Follow', :foreign_key => :receiver_id,:dependent => :destroy
      has_many :given_marks, :class_name => "Markreport",:foreign_key => :user_id, :dependent => :destroy
      has_many :received_marks, :class_name => "Markreport", :foreign_key => :receiver_id, :dependent => :destroy
      
      has_many :given_posts, :class_name => "Teachertweet",:foreign_key => :user_id, :dependent => :destroy
      has_many :received_posts, :class_name => "Teachertweet", :foreign_key => :receiver_id, :dependent => :destroy
      
      has_many :given_attendences, :class_name => "Attendance",:foreign_key => :user_id, :dependent => :destroy
      has_many :received_attendences, :class_name => "Attendance", :foreign_key => :receiver_id, :dependent => :destroy
      
      has_many :favorites, :dependent => :destroy
 # validates :emrgency_phone,:home_phone, :presence => true, :numericality => true,format: { with: /\A\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})\Z/,
 #    message: "number must be in xxx-xxx-xxxx format" }

 validate :email_should_not_exist_in_school_admin,:email_should_not_exist_in_admin
 validates_acceptance_of :terms_of_service, :message => "In order to use the service, You must first agree to the terms and conditions", :on => :update
 before_update :lowercase_name

 before_post_process :resize_images
 after_create :sent_invitation
  # Helper method to determine whether or not an attachment is an image.
  def image?
    syllabus_link_content_type =~ %r{^(image|(x-)?application)/(bmp|gif|jpeg|jpg|pjpeg|png|x-png)$}
  end

  def lowercase_name
    self.username = self.username.downcase if self.username != nil
  end

  def email_should_not_exist_in_school_admin
    student = SchoolAdmin.find_by_email(self.email)
    return true unless student.present?
    self.errors.add(:email, "is already taken.")
    return false
  end

  def email_should_not_exist_in_admin
    student = Admin.find_by_email(self.email)
    return true unless student.present?
    self.errors.add(:email, "is already taken")
    return false
  end

  def generate_password_reset_code
    self.reset_password_token = Digest::SHA2.hexdigest(Time.now.to_s)
    self.reset_password_sent_at = Time.now
    save
  end

  def favorite_for(tweet)
    self.favorites.find_by_tweet_id(tweet)
  end

  def fullname
    (self.first_name+' '+self.last_name) if !self.first_name.blank? and !self.last_name.blank?
  end
  
  def sent_invitation
   UserMailer.send_notification(self).deliver
 end

 private

 def resize_images
  return false unless image?
end
end
