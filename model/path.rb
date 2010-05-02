class Path
	attr_reader :length

	def initialize(parameterization, length)
		@parameterization = parameterization
		@length = length
	end

	def point(distance)
		@parameterization.call(distance) unless distance > length
	end
end
