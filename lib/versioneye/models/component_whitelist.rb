class ComponentWhitelist < Versioneye::Model

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,             type: String
  field :default,          type: Boolean, default: false
  field :components,       type: Array, default: []

  belongs_to :user

  validates_presence_of :name, :message => 'is mandatory!'

  index({user_id: 1, name: 1},  { name: "user_id_name", background: true, unique: true })

  scope :by_user, ->(user) { where(user_id: user[:_id].to_s) }
  scope :by_name, ->(name)  { where(name:  name ) }

  def to_s
    name
  end

  def to_param
    name
  end

  def update_from params
    self.name = params[:name]
  end

  def self.fetch_by user, name
    self.by_user(user).by_name(name).first
  end

  def add element
    self.components << element.downcase.gsub(" ", "") if !is_on_list?(element)
  end

  def remove element
    self.components.delete element
  end

  def is_on_list? element
    return true if self.components.include?(element)

    components.each do |component|
      return true if element.match( /\A#{component}/ )
    end

    false
  end

  def auditlogs
    Auditlog.where(:domain => "ComponentWhitelist", :domain_id => self.id.to_s).desc(:created_at)
  end

end