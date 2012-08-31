class User < ActiveRecord::Base
  # new columns need to be added here to be writable through mass assignment
  attr_accessible :username, :email, :password, :password_confirmation, :usergroup_id, :post_count, 
                  :last_post_at, :last_post_id, :last_visit_at

  attr_accessor :password
  before_save :prepare_password

  has_many :posts, :dependent => :nullify
  has_many :topics, :dependent => :nullify

  has_one :usergroups
  
  validates_presence_of :username
  validates_uniqueness_of :username, :email, :allow_blank => true
  validates_format_of :username, :with => /^[-\w\._@]+$/i, :allow_blank => true, :message => "should only contain letters, numbers, or .-_@"
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  validates_presence_of :password, :on => :create
  validates_confirmation_of :password
  validates_length_of :password, :minimum => 4, :allow_blank => true

  # login can be either username or email address
  def self.authenticate(login, pass)
    user = find_by_username(login) || find_by_email(login)
    return user if user && user.password_hash == user.encrypt_password(pass)
  end

  def encrypt_password(pass)
    BCrypt::Engine.hash_secret(pass, password_salt)
  end

  private

  def prepare_password
    unless password.blank?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = encrypt_password(password)
    end
  end
  
  def is_admin?
    return current_user.usergroup_id == 6 ? true : false
  end

  def is_super_mod?
    return current_user.usergroup_id == 5 ? true : false
  end

  def is_mod?
    return current_user.usergroup_id == 7 ? true : false
  end
  
  def is_banned?
    return current_user.usergroup_id == 8 ? true : false
  end

end
