class User < Refinery::Core::BaseModel
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
    has_and_belongs_to_many :roles, :join_table => :roles_users
    has_many :plugins, :class_name => "UserPlugin", :order => "position ASC", :dependent => :destroy

    def plugins=(plugin_names)
      if persisted? # don't add plugins when the user_id is nil.
        UserPlugin.delete_all(:user_id => id)

        plugin_names.each_with_index do |plugin_name, index|
          plugins.create(:name => plugin_name, :position => index) if plugin_name.is_a?(String)
        end
      end
    end

    def authorized_plugins
      plugins.collect { |p| p.name } | ::Refinery::Plugins.always_allowed.names
    end

    def add_role(title)
      raise ArgumentException, "Role should be the title of the role not a role object." if title.is_a?(::Role)
      roles << ::Role[title] unless has_role?(title)
    end

    def has_role?(title)
      raise ArgumentException, "Role should be the title of the role not a role object." if title.is_a?(::Role)
      roles.any?{|r| r.title == title.to_s.camelize}
    end

    def can_delete?(user_to_delete = self)
      user_to_delete.persisted? and
      id != user_to_delete.id and
      !user_to_delete.has_role?(:superuser) and
      Role[:refinery].users.count > 1
    end
  end