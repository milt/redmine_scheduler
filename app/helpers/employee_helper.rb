module EmployeeHelper                     #how is a module used?
	class Employee < User
		attr_accessor :name, :email, :wage, :paid

		def initialize(name, email, wage, paid)
			@name = name
			@email = email
			@wage = wage
			@paid = paid
		end

		#what does this mehtod do?
		def to_hash
			{
				:name => @name,
				:email => @email
				:wage => @wage
				:paid => @paid
			}
		end
	end
end
