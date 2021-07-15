#ActiveRecord::Base.lock_optimistically = false
passes = Pass.where('acquired_at < :date', date: 10.days.ago).includes(jobs: [:products])
passes.each do |x| 
	x.destroy!
	nil
end

s = Job.where("pass_id is null")
s.each{|x| x.delete if !x.pass}
