#coding:utf-8
ACCOUNT_GROUPS = %W(admin designer auditor editor robot user)

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
  property :group_id, Integer, :default => 6
  belongs_to :group, 'Account', :required => false

  # hookers
  before :save, :encrypt_password

  before :destroy do |a|
    throw halt  unless a.group
  end

  # instance helpers
  def get_folders
    #!!! do more logic
    Folder.all
  end

  def allowed( check )
    return self.group.allowed(check)  if self.group
    raise Forbidden  if self.id > ACCOUNT_GROUPS.length
    check_index = ACCOUNT_GROUPS.index(check.to_s)
    self_index  = ACCOUNT_GROUPS.index(self.name.to_s)
    return true  if self_index <= check_index
  end
  alias allowed? allowed

  def role
    self.group ? self.group.role : self.name
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
