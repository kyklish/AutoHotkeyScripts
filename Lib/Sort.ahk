Sort(ByRef oArray) ; сортировка расческой
{
	iSize := oArray.Length()
	bEnd := false
	fpDivFactor := 1.247330950103979
	iStep := iSize
	while (!bEnd) {
		iStep := iStep // fpDivFactor
		iStep := Round(iStep) ;if Places is omitted or 0, Number is rounded to the nearest integer
		if (iStep < 1) {
			iStep := 1
		}
		if (iStep = 1) {
			bEnd := true
		}
		i := 1
		while (i + iStep < iSize + 1) {
			if (oArray[i] > oArray[i + iStep]) {
				SwapA(oArray, i, i + iStep) ;regular Swap() not working for array elements
				bEnd := false
			}
			++i
		}
	}
}
