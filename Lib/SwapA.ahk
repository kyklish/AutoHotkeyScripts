SwapA(ByRef oArray, i, j) ;swap array elements
{
	temp := oArray[i]
	oArray[i] := oArray[j]
	oArray[j] := temp
}