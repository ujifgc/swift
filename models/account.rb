#coding:utf-8
ACCOUNT_ROLES = %W(admin designer auditor editor robot user)

class Account
  include DataMapper::Resource
  include DataMapper::Validate
  attr_accessor :password, :password_confirmation

  # Properties
  property :id,               Serial
  property :name,             String
  property :surname,          String
  property :email,            String
  property :crypted_password, String, :length => 70

  # for omniauth
  property :provider,         String
  property :uid,              String

  # Validations
  validates_presence_of      :email
  validates_length_of        :email,    :min => 3, :max => 100
  validates_uniqueness_of    :email,    :case_sensitive => false
  validates_format_of        :email,    :with => /\w+@\w+/
  validates_presence_of      :password,                          :if => :password_required
  validates_presence_of      :password_confirmation,             :if => :password_required
  validates_length_of        :password, :min => 4, :max => 40,   :if => :password_required
  validates_confirmation_of  :password,                          :if => :password_required

  # relations
  has n, :folders
  property :role_id, Integer, :default => 6
  belongs_to :role, 'Account', :required => false

  # hookers
  before :save, :encrypt_password

  before :destroy do |a|
    throw halt  unless a.role
  end

  # instance helpers
  def get_folders
    #!!! do more logic
    self.folders
  end

  def allowed check
    return self.role.allowed(check)  if self.role
    raise Forbidden  if self.id > ACCOUNT_ROLES.length
    check_index = ACCOUNT_ROLES.index(check.to_s)
    self_index  = ACCOUNT_ROLES.index(self.name.to_s)
    return true  if self_index <= check_index
  end

  def has_password?(password)
    ::BCrypt::Password.new(crypted_password) == password
  end

  # class helpers
  def self.authenticate(email, password)
    account = first(:conditions => { :email => email }) if email.present?
    account && account.has_password?(password) ? account : nil
  end

  def self.find_by_id(id)
    get(id) rescue nil
  end

private

  def password_required
    crypted_password.blank? || password.present?
  end

  def encrypt_password
    self.crypted_password = ::BCrypt::Password.create(password) if password.present?
  end

end
