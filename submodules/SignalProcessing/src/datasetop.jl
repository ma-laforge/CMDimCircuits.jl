#SignalProcessing: Dataset operations
#-------------------------------------------------------------------------------

import MDDatasets: xshift

#Shifts y-values of a dataset by +/-noffset steps:
#TODO: support circular shifts (optional arg)
#-------------------------------------------------------------------------------
function yshift(d::DataTime, noffset::Index)
	noffset = value(noffset)
	xt = d.data.xt
	xt = MDDatasets.shift(xt, noffset)
	return DataTime(d.data.t, xt)
end

#Shifts x-values of a dataset by +/-noffset steps:
#==TODO: Improve support of time shifts
This operation seems succeptible to roundoff errrors.
Maybe we should describe t range differently to better support time shifts.
QUESTION: Should t=0 always be guaranteed to be included in range?
==#
function xshift(d::DataTime, noffset::Index)
	noffset = value(noffset)
	t = d.data.t
	Δt = step(t)*noffset
	return DataTime(t+Δt, copy(d.data.xt))
end


#Last line
